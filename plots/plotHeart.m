function plotHeart(t_axis, f_axis, heart_wave, heart_wave_filtered, heart_wave_fft)
    figure;
    subplot(3, 1, 1);
    plot(t_axis, heart_wave);
    title('HR Signal Wave');
    xlabel('Time (s)');
    subplot(3, 1, 2);
    plot(t_axis, heart_wave_filtered);
    title('Filtered HR Signal');
    xlabel('Time (s)');
    subplot(3, 1, 3);
    plot(f_axis, abs(heart_wave_fft));
    title('Magnitude Spectrum HR Signal');
    xlabel('Frequency (Hz)');
end