function ctffind_wrapper(ts_dir, apix, x_dim, y_dim, mask_size, ctffind_install)
  
%%% List of already processed tilt-series
processed = {};

if ~isfile('./CTFFIND_settings.csh')
	disp('Error: Can''t find CTFFIND_settings.csh in this directory. Have you run import_ctffind?');
	return
end

while true
        
	[ts_directory, processed] = next_dir(ts_dir, processed);
        
        if ischar(ts_directory)
                autoalign_sleep(processed)
                continue
        end
    	
	current_ts = fullfile(ts_directory.folder, ts_directory.name);
	
	ctffind(current_ts, apix, x_dim, y_dim, mask_size, ctffind_install);
end
    



