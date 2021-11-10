function dautoalign4relion(ts_dir, apix, fiducial_diameter_nm, nominal_rotation_angle, min_markers)
    %%%%% Automatic on-the-fly alignment of a set of tilt series
    %%% Parameters
    % ts_dir - directory containing tilt series directories
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - fiducial diameter in nanometers
    % nominal rotation angle - estimated tilt axis angle (CCW rotation from Y-axis)
    % Dynamo will delete beads based on worse residuals: this sets the minimum number of beads per tilt before stopping deleting beads. An absolute minimum of 3 is required, but 4 is recommended.
    
    command = ['point2model'];
    [status,cmdout] = system(command);
    
    if contains(cmdout,'Command not found','IgnoreCase',true);
    	disp('IMOD command point2model not found. Have you remembered to load IMOD in this terminal before opening MatLab?');
	return
    else
    
    %%% List of already processed tilt-series
    processed = {};
        
    prompt = 'Which version of autoalign would you like to use? Type: default or fast_mode \n \nThe default version where the residual movement of the fiducials is minimised (recommended) (type: default) or fast mode where the residual movement of the fiducial markers will be higher but the alignment will finish much faster (type: fast_mode). See README for details. \n \n:'; 
    
    version_auto = input(prompt,'s');
    
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
	    	
                if strcmp(version_auto,'default')
			final_dir_name = autoalign(stack, basename, rawtlt, apix, fiducial_diameter_nm, min_markers, ts_dir);
		elseif strcmp(version_auto,'fast_mode')
			disp('Running fast_mode');
			final_dir_name = autoalign_original(stack, basename, rawtlt, apix, fiducial_diameter_nm, ts_dir);
		else
			disp('Not correctly specified which version of autoalign you want to use, skipping. Type either: default or fast_mode when prompted');
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





