function [heart_rate, respiratory_rate] = pipeline(data, fs, sensor_type, n_components, plot_results)
% Syntax:       [heart_rate, respiratory_rate] = pipeline(data, fs);
%               [heart_rate, respiratory_rate] = pipeline(data, fs, sensor_type);
%               [heart_rate, respiratory_rate] = pipeline(data, fs, sensor_type, n_components);
%               [heart_rate, respiratory_rate] = pipeline(data, fs, sensor_type, n_components, plot_results);
%
% Inputs:       data is a 6 x L containing the 3 axis (x, y, z) of
%               the accelerometer sensor and the 3 axis of the
%               gyroscope sensor
%               
%               fs is the sampling frequency of the data
%          
%               [OPTIONAL] sensor_type = {'full','acell', 'gyro'} specifies
%               which sensor to use, the code allow to use only the acellerometer
%               only the gyroscope, and the combination of both.
%
%               [OPTIONAL] n_components for the fastICA algorithm
%
%               [OPTIONAL] plot_results determines whether to plot.
%               The choices are
%                  
%                       plot_results = 0: no plotting
%                       plot_results = 1: plot enabled
%
% Outputs:      heart_rate is data estimation of the subject heart
%               rate in beats per minute.
%
%               respiratory_rate is data estimation of the subject 
%               respiratory_rate in breaths per minutes
%               
% Description:  Extract the heart rate and respiratory rate of from
%               the 3-axis of the accelerometer and gyroscope. The process
%               starts by using independent component analysys (ICA) on the 
%               data. After n_components are generated and the respiratory
%               rate component is identified. The remaining components are
%               merged using a L2 vector normalization, creating the heart
%               rate wave. Those two waves are thus processed to remove noise
%               with bandpass filters. Finally, we calculate the fourier
%               transform and extract the predominant frequency to estimate
%               the desired values
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%


%%%%%%%%%% Handle function default values 
% Sensor Type Default
if ~exist('sensor_type','var') || isempty(sensor_type)
    % Default select num sensors
    sensor_type = 'full';
end

% Fast ICA components ammount default
if ~exist('n_components','var') || isempty(n_components)
    % Default n_components
    n_components = 3;
end


% Plot type default value
if ~exist('plot_results','var') || isempty(plot_results)
    % Default display plots
    plot_results = 1;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initial Values Setup
Fs = fs;                  % Sample Rate
L = size(data, 1);        % Signal Size
f_axis = (0:L-1)/L*Fs;    % Frequency axis
t_axis = (0:L-1)/Fs;      % Time Axis
data_vec = [];            % Data matrix

% Plot Signal
if plot_results
    plotSignals(data, t_axis);
end

% Initialize 3-axis data for acellerometer
% The values reported by the accelerometers are measured in increments
% of the gravitational acceleration, with the value 1.0 representing an 
% acceleration of 9.8 meters per second (per second)
ax = data.AcellX.' * 9.8;
ay = data.AcellY.' * 9.8;
az = data.AcellZ.' * 9.8;

% Initialize 3-axis data for gyroscope
gx = data.GyroX.';
gy = data.GyroY.';
gz = data.GyroZ.';

% Create proper data matrix based on execution type
if strncmpi(sensor_type,'full',1)
    data_vec = [ax; ay; az; gx; gy; gz];
elseif strncmpi(sensor_type,'acell',1)
    data_vec = [ax; ay; az];
elseif strncmpi(sensor_type,'gyro',1)
    data_vec = [gx; gy; gz];
end

% Perform the fast ICA algorithm
Z_ica = fastICA(data_vec, n_components, 'kurtosis', 0);

%%%%%%%%%% Identify the Respiratory Rate

% Identify RR Wave by Autocorrel
rr_wave_index = find_rr_wave(Z_ica, L, Fs, plot_results);

% Plot Resulting Components
if plot_results
    plotICA(Z_ica, rr_wave_index, t_axis)
end

% Get the proper RR component
rr_wave = Z_ica(rr_wave_index, :);
% Fitler the desired region
rr_wave_filtered = filter_signal_rr(rr_wave, Fs);
% Perform Fourier Transform
rr_wave_fft = fft(rr_wave_filtered);
% Find dominant frequency
rr = find_max(abs(rr_wave_fft), L, Fs);
respiratory_rate = round(rr*60);

if plot_results
   plotRRProcess(rr_wave, rr_wave_filtered, rr_wave_fft, t_axis, f_axis)
end

%%%%%%%%%% Identify the Heart Rate

% Select the Heart data from the components
heart_wave = Z_ica;
heart_wave(rr_wave_index, :) = [];

% Normalize the vector if more than one heart component
if n_components > 2 
    heart_wave = vecnorm(heart_wave);
end


% Filter the heart data using a bandpass butter filter
[b, a] = butter(4, [0.66 3.33]/(Fs/2),'bandpass');
heart_wave_filtered = filter(b, a, heart_wave);

% Calculate fourier transform of heart filter
heart_wave_fft = fft(heart_wave_filtered);

% Plot heart info
if plot_results
    plotHeart(t_axis, f_axis, heart_wave, heart_wave_filtered, heart_wave_fft)
end

% Find dominant heart frequency
hr = find_max(abs(heart_wave_fft), L, Fs);
heart_rate = hr*60;

end


function filtered_signal = filter_signal_rr(signal, Fs)
% Syntax:       filtered_signal = filter_signal_rr(signal, Fs)
%
% Inputs:       signal is the signal to be filtered
%          
%               Fs is the sampling frequency
%
% Outputs:      filtered_signal is the resulting singal filtered in the
%               0.2 to 0.5 Hz, which corresponts to the range of 12 to 30
%               BPM.
%               
% Description:  Filter a signal with a Fs sampling frequency with a 
%               bandpass filter between 0.2 to 0.501 Hz, which 
%               corresponts to the range of 12 to 30 BPM.
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    filtered_signal= bandpass(signal, [0.2 0.501], Fs);
end

function max_value = find_max(fft_mag_data, L,  Fs)
% Syntax:       max_value = find_max(fft_mag_data, L,  Fs)
%
% Inputs:       fft_mag_data is the magnitude of the fourier transform
%               of the signal
%               
%               L is the size of the signal
%          
%               Fs is the sampling frequency
%
% Outputs:      max_value is the dominant frequency of the signal
%               
% Description:  Find the dominant frequency of the magnitude of the 
%               fourier transform of the signal
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    [~, index_value] = max(fft_mag_data);
    max_value = (index_value-1)/L*Fs;
end

function rr_wave_index = find_rr_wave(signal, L, Fs, plot_signals)
% Syntax:       rr_wave_index = find_rr_wave(signal, L, Fs, plot_signals)
%
% Inputs:       signal is the signal to be filtered
%               
%               L is the size of the signal
%          
%               Fs is the sampling frequency
%
%               plot_signals determines whether to plot
%
% Outputs:      rr_wave_index is index of the ICA signal wave
%               component which corresponds to the respiratory rate
%               
% Description:  Find the index of the respiratory rate signal
%               wave in the ICA components.
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
 
    % Create Signosoidal Signal
    tt = linspace(0, 60, L);
    y = sin(2*pi*(20/60)*tt);
    
    num_components = size(signal, 1);
    correls = zeros(num_components, (L*2)-1);
    lags = zeros(num_components, (L*2)-1);
    max_correls = zeros(num_components, 1);
    % Calculate Correlation between signals and templates
    for i=1:num_components
        [C_i,lag_i] = xcorr(y,signal(i, :));  
        correls(i, :) = C_i;
        max_correls(i) = max(C_i);
        lags(i, :) = lag_i;
    end

    % Get signal wave with maximum correlation value
    [~, rr_wave_index] = max(max_correls);
    
     if plot_signals
         plotCorrels(tt, y, lags, correls, Fs)
     end
end