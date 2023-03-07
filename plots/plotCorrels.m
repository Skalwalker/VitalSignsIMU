function plotCorrels(tt, y, lags, correls, Fs)
    figure;
    num_components = size(correls, 1);
    subplot(num_components+1,1,1); 
    plot(tt,y);
    title('Template Signal');
    xlabel('time (s)');
    for i=1:num_components
        subplot(num_components+1,1,i+1); 
        plot(lags(i, :)/Fs, correls(i, :));
        if i == 1
            title('Correlated Signal');
        end
        ylabel("Amplitude")
        xlabel('time (s)');
    end
end