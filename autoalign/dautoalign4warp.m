function dautoalign4warp(apix, fiducial_diameter_nm, nominal_rotation_angle, output_folder)
    %%%%% Automatic alignment of a set of tilt series from Warp
    % Function to be run in 'imod' directory output by warp
    
    %%% Parameters
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - fiducial diameter in nanometers
    % nominal rotation angle - estimated tilt axis angle (CCW rotation from Y-axis)
    % output folder - a folder in which to store the 
    
    %%% Gather directories in imod dir
    base_folder = pwd;
    files = dir(base_folder);
    dir_flags = [files.isdir];
    directories = files(dir_flags);
    
    %%% Find stack files and automatically align, run tiltalign, sort everything for warp
    for i = 1:length(directories)
        basename = directories(i).name;
        stack = fullfile(basename, [basename, '.st']);
        rawtlt = fullfile(basename, [basename, '.rawtlt']);
   
        if contains(basename, '.mrc')
            try
                final_dir_name = align(stack, basename, rawtlt, apix, fiducial_diameter_nm, output_folder)
                tiltalign(final_dir_name, nominal_rotation_angle, apix)
            catch
                fprintf('failed on: %s\n', basename)
            end
        end
    end
    % Cleanup
    delete tmp.tlt;
    delete tmp.csv;
    
    % Print info about quality of alignment to console
    info_file_paths = fullfile(output_folder, '*', 'info', 'fitting.doc');
    command = ['cat ', info_file_paths, ' | grep rms'];
    system(command)
end



