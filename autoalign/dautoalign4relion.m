function dautoalign4relion(ts_dir, apix, fiducial_diameter_nm, nominal_rotation_angle, min_markers,output_folder)
    %%%%% Automatic on-the-fly alignment of a set of tilt series
    %%% Parameters
    % ts_dir - directory containing tilt series directories
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - fiducial diameter in nanometers
    % nominal rotation angle - estimated tilt axis angle (CCW rotation from Y-axis)
    % Dynamo will delete beads based on worse residuals: this sets the minimum number of beads per tilt before stopping deleting beads. An absolute minimum of 3 is required, but 4 is recommended.
    % output folder - a folder in which to store the 
    
    %%% List of already processed tilt-series
    processed = {};
    
    %%% Lower residuals = 'Roadmap' scripts, which fail to produce an .xf file for RELION more often and sometimes only keep fiducial markers on one side of the tilt series, but achieve a lower average residual for the TSA. More reliable = the autoalign function from the original autoalign_dynamo repository
    
    prompt = 'Which version of autoalign would you like to use? Minimised residuals (recommended) (type: residuals) or minimised errors (type: errors). See README for details.'; 
    version = input(prompt,'s');
    
    %%% Attempt to 
    while true
        [ts_directory, processed] = next_dir(ts_dir, processed);
        
        %
        if ischar(ts_directory)
            autoalign_sleep(processed)
            continue
        end
        
        % get paths to stack and rawtlt file
        [basename, stack, rawtlt] = ts_info_from_dir(ts_directory);
        
        % try to align tilt series
        if isfile(stack)
            try
                if version == 'residuals'
			final_dir_name = autoalign(stack, basename, rawtlt, apix, fiducial_diameter_nm, min_markers, output_folder);
		elif version == 'errors'
			final_dir_name = autoalign_original(stack, basename, rawtlt, apix, fiducial_diameter_nm, output_folder);
		else
			disp('Not correctly specified which version of autoalign you want to use, skipping. Type either: residuals or errors when prompted');
                tiltalign(final_dir_name, nominal_rotation_angle, apix)
		end
            catch ME
                handle_exception(ME)
            end
            autoalign_aux_cleanup()
            autoalign_summarise(output_folder)
        end
    end
    
end



