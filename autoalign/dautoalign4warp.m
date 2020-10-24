function dautoalign4warp(warp_imod_dir, apix, fiducial_diameter_nm, nominal_rotation_angle, output_folder)
    %%%%% Automatic on-the-fly alignment of a set of tilt series from Warp
    %%% Parameters
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - fiducial diameter in nanometers
    % nominal rotation angle - estimated tilt axis angle (CCW rotation from Y-axis)
    % output folder - a folder in which to store the 
    
    %%% List of already processed tilt-series
    processed = {};
    
    %%% Attempt to 
    while true
        [ts_directory, processed] = next_dir(warp_imod_dir, processed);
        
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
                final_dir_name = autoalign(stack, basename, rawtlt, apix, fiducial_diameter_nm, output_folder);
                tiltalign(final_dir_name, nominal_rotation_angle, apix)
            catch ME
                handle_exception(ME)
            end
            autoalign_aux_cleanup()
            autoalign_summarise(output_folder)
        end
    end
    
end



