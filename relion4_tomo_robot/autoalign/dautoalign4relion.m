function dautoalign4relion(ts_dir, apix, fiducial_diameter_nm, nominal_rotation_angle, min_markers, mode)
    % Automatic on-the-fly alignment of a set of tilt series
    % Parameters: dautoalign4relion(ts_dir, apix, fiducial_diameter_nm, nominal_rotation_angle, min_markers, mode)
    % e.g. dautoalign4relion('TS_directory', 1.2, 5, 85, 4, 'default')
    % ts_dir - directory containing tilt series directories
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - fiducial diameter in nanometers
    % nominal rotation angle - estimated tilt axis angle (CCW rotation from Y-axis). This is not the value of the tilt increments of your tilt series!
    % min_markers: An absolute minimum of 3 is required, but 4 is recommended. Dynamo will delete beads based on worse residuals: this sets the minimum number of beads per tilt before stopping deleting beads. 
    %For mode either type: 'default' or 'fast_mode'. Default will give a better alignment but will take longer. 
    
    command = ['point2model'];
    [status,cmdout] = system(command);
    
    if contains(cmdout,'Command not found','IgnoreCase',true);
    	disp('IMOD command point2model not found. Have you remembered to load IMOD in this terminal before opening MatLab?');
	return
    else
    
    %%% List of already processed tilt-series
    processed = {};
    
    %%% Attempt to 
    while true
        [ts_directory, processed] = next_dir(ts_dir, processed);
        
        if ischar(ts_directory)
            autoalign_sleep(processed)
            continue
        end
        
        % get paths to stack and rawtlt file
        [basename, stack, rawtlt] = ts_info_from_dir(ts_directory);
        
        % try to align tilt series
        if isfile(stack)
            try
	    	
                if contains(mode,'default')
			final_dir_name = autoalign(stack, basename, rawtlt, apix, fiducial_diameter_nm, min_markers, ts_dir);
		elseif contains(mode,'fast')
			disp('Running fast_mode');
			final_dir_name = autoalign_original(stack, basename, rawtlt, apix, fiducial_diameter_nm, ts_dir);
		else
			disp('Not correctly specified which version of autoalign you want to use, skipping. Type either: ''default'' or ''fast_mode'' in the dautoalign4relion input');
			return
                end
		disp('Run autoalign successfully!');
		tiltalign(final_dir_name, nominal_rotation_angle, apix);
            catch ME
                handle_exception(ME);
            end
            autoalign_aux_cleanup();
            
        end
    end
    
end





