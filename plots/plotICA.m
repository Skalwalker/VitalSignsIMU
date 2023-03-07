function plotICA(icas, rr_wave_index, t_axis)
    figure;
    n_components = size(icas, 1);
    for i = 1:n_components
       subplot(n_components, 1, i);
       plot(t_axis, icas(i, :));
       xlabel('Time') 
       if i == rr_wave_index
           title('Respiratory Rate Component')
       else
           title('Heart Rate Component')
       end
    end
end