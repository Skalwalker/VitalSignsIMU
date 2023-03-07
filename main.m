% Description:  Extract the heart rate and respiratory rate of from
%               the 3-axis of the accelerometer and gyroscope. To read 
%               detailed info about the extraction process, go to
%               pipeline.m. This file perform the experimentation on the
%               data folder. It can run the pipeline on a single experiment
%               and plot the process or it can run on a whole data set. If
%               the option is to execute the whole dataset, the dataset is
%               processed with the amount of num_repetitions and the mean
%               absolute error, root mean squared error and accuracy are
%               calculated.
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
clear variables
warning('off','MATLAB:table:ModifiedAndSavedVarnames')

% Experimental Parameters
single_experiment = 0;            % Flag to execute on one file or on all data
ica_num_components = 4;           % Nuber of components to use in the ICA
sensor_type = 'full';             % Type of sensors to use
data_file = "RENATA21RR76-85BPM";   % File name - in case of single file
data_folder = './data';           % Path to data folder, used when executed all data
num_repetitions = 30;             % Number of times to execute the experiment over the collection of the data

% Sampling Rate 500Hz
Fs = 500;

if single_experiment
    % Read file
    log_file_name(data_file);
    data_csv = readtable(data_file);
    
    % Calculate Heart Rate and Respiratory Rate
    [hr, rr] = pipeline(data_csv, Fs, sensor_type, ica_num_components, 1);
    
    % Get True values from file name
    [rr_true, hr_min_true, hr_max_true] = regexName(data_file);
    % Log the results
    log_single_results(hr, rr, hr_min_true, hr_max_true, rr_true)
else
    % Get a list of all files in the folder with the desired file name pattern.
    file_pattern = fullfile(data_folder, '*.csv'); % Change to whatever pattern you need.
    files = dir(file_pattern);
    
    % Initiate trial results vectors
    mae_rr_list = zeros(num_repetitions, 1);
    rmse_rr_list = zeros(num_repetitions, 1);
    acc_rr_list = zeros(num_repetitions, 1);
    mae_hr_list = zeros(num_repetitions, 1);
    rmse_hr_list = zeros(num_repetitions, 1);


    for rep=1:num_repetitions
        % Initialize results lists
        rr_true_list = zeros(length(files), 1);
        hr_true_list = zeros(length(files), 1);
        hr_pred_list = zeros(length(files), 1);
        rr_pred_list = zeros(length(files), 1);
        
        for i = 1:length(files)
            % Open file
            data_file_name = files(i).name;
            log_file_name(data_file_name);
            data_csv = readtable(data_file_name);
    
            % Get true values from the name
            [rr_true, hr_min_true, hr_max_true] = regexName(data_file_name);
            rr_true_list(i) = rr_true;
            hr_true_list(i) = (hr_max_true + hr_min_true)/2;
        
            % Get Hearth Rate and Respiratory Rate from pipeline
            [hr, rr] = pipeline(data_csv, Fs, sensor_type, ica_num_components, 0);
            log_single_results(hr, rr, hr_min_true, hr_max_true, rr_true)
        
            % Assign preditions
            rr_pred_list(i) = rr;
            hr_pred_list(i) = hr;
    
            fprintf("\n");
        end
    
        % Calculate Respiratory Rate Metrics
        [rr_mae, rr_rmse, rr_acc] = metrics(rr_true_list, rr_pred_list);
        log_metrics(rr_mae, rr_rmse, rr_acc, "Respirartory Rate", 1);
    
        % Calculate Heart Rate Metrics
        [hr_mae, hr_rmse, hr_acc] = metrics(hr_true_list, hr_pred_list);
        log_metrics(hr_mae, hr_rmse, hr_acc, "Hearth Rate", 0);
        
        % Save trial results
        mae_rr_list(rep) = rr_mae;
        rmse_rr_list(rep) = rr_rmse;
        acc_rr_list(rep) = rr_acc;
        mae_hr_list(rep) = hr_mae;
        rmse_hr_list(rep) = hr_rmse;
    end

    % Calculate final experimental results
    final_mae_rr = sum(mae_rr_list)/num_repetitions;
    final_rmse_rr = sum(rmse_rr_list)/num_repetitions;
    final_acc_rr = sum(acc_rr_list)/num_repetitions;
    final_mae_hr = sum(mae_hr_list)/num_repetitions;
    final_mse_hr = sum(rmse_hr_list)/num_repetitions;

    % Log final experimental results
    log_metrics(final_mae_rr, final_rmse_rr, final_acc_rr, "Final Respiratory Rate", 1)
    log_metrics(final_mae_hr, final_mse_hr, 0, "Final Hearth Rate", 0)
end

function log_metrics(mae, rmse, acc, signal_type, acc_flag)
% Syntax:       log_metrics(mae, rmse, acc, signal_type, acc_flag)
%
% Inputs:       mae is the mean absolute error value
%
%               rmse is the resulting root means square error value
%
%               acc is the resulting accuracy value
%
%               signal_type is a string to add to the printing
%
%               acc_flag tells whether to print the accuracy (only makes
%               sense to the respiratory rate)
%               
% Description:  Print the resulting metrics
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    fprintf(1, '\n\n%s MAE: %f\n', signal_type, mae);
    fprintf(1, '%s RMSE: %f\n', signal_type, rmse);
    if acc_flag
        fprintf(1, '%s Accuracy: %f\n', signal_type, acc);
    end
end

function log_file_name(f_name)
% Syntax:       log_file_name(f_name)
%
% Inputs:       f_name is the name of the file
%               
% Description:  Print the name of the file
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    fprintf(1, 'Processing File: %s\n', f_name);
end

function log_single_results(hr, rr, hr_min_true, hr_max_true, rr_true)
% Syntax:       log_single_results(hr, rr, hr_min_true, hr_max_true, rr_true)
%
% Inputs:       hr is the predicted heart rate 
%               
%               rr is the predicted respiratory rate
%               
%               hr_min_true is the true minimum heart rate of the subject
%
%               hr_max_true is the true maximum heart rate of the subject
%
%               rr_true is the true respiratory rate of the subject
%               
% Description:  Print the predicted results and the true values
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
   hr_true = (hr_max_true + hr_min_true)/2;
   fprintf(1, 'Predicted RR: %d (True: %d)\n', rr, rr_true);
   fprintf(1, 'Predicted HR: %f (Med: %f, Min: %d , Max: %d)\n', hr, hr_true, hr_min_true, hr_max_true);
end
