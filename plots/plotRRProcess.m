function plotRRProcess(rr_signal, rr_filtered, rr_fft, t_axis, f_axis)
    figure;
    subplot(3, 1, 1);
    plot(t_axis, rr_signal);
    title('RR Signal Wave')
    subplot(3, 1, 2);
    plot(t_axis, rr_filtered);
    title('Filtered RR Signal')
    subplot(3, 1, 3);
    plot(f_axis, abs(rr_fft));
    title('Magnitude Spectrum RR Signal')
end