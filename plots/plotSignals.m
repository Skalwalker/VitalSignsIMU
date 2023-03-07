function plotSignals(data_csv, t_axis)
    
    % Plot Gyro Info
    figure;
    subplot(3,2,1);
    plot(t_axis, data_csv.GyroX);
    title('Gyro X');
    xlabel('Time (s)');
    ylabel('rad/s');
    
    subplot(3,2,3);
    plot(t_axis, data_csv.GyroY);
    title('Gyro Y');
    xlabel('Time (s)');
    ylabel('rad/s');
    
    subplot(3,2,5);
    plot(t_axis, data_csv.GyroZ);
    title('Gyro Z');
    xlabel('Time (s)');
    ylabel('rad/s');

    % Plot Acellerometer Info
    subplot(3,2,2);
    plot(t_axis, data_csv.AcellX);
    title('Acell X');
    xlabel('Time (s)');
    ylabel('m/s');

    subplot(3,2,4);
    plot(t_axis, data_csv.AcellY);
    title('Acell Y');
    xlabel('Time (s)');
    ylabel('m/s');

    subplot(3,2,6);
    plot(t_axis, data_csv.AcellZ);
    title('Acell Z');
    xlabel('Time (s)');
    ylabel('m/s');
    

end