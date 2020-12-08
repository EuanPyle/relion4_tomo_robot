function autoalign_summarise(output_folder)
    info_file_paths = fullfile(output_folder, '*', 'info', 'fitting.doc');
    command = ['cat ', info_file_paths, " | grep rms | awk '{print $2}' > ",fullfile(output_folder, 'rms.txt')];
    command = strjoin(command);
    system(command);
    
    m = csvread(fullfile(output_folder, 'rms.txt'));
    mean_rms = mean(m);
    min_rms = min(m);
    max_rms = max(m);
    std_rms = std(m);
    
    fprintf('Updated RMSD stats for experimental bead positions vs. projection model\nmin: %.2f\nmax: %.2f\nmean: %.2f\nsdev: %.2f\n', min_rms, max_rms, mean_rms, std_rms);
end


