function tiltalign(ts_folder, rotation_angle, pixel_size_angstrom)
    %%%%% Runs tiltalign on the .mod and .tlt files files in a tilt series directory
    %%% requires tiltalign_wrapper.sh to be on the path
    %%% tiltalign wrapper uses get_tasolution.py
    
    % Go to tilt series directory
    working_directory = pwd;
    cd(ts_folder);
    
    % Extract basename of files
    [p, n, ext] = fileparts(ts_folder);
    basename = [n, ext];
    
    % Generate filenames for model, tilt angles and output tlt and xf files
    % Calc pixel size in nm
    model_file = [basename, '.mod'];
    tilt_angle_file = [basename, '.rawtlt'];
    pixel_size_nm = pixel_size_angstrom / 10;
    output_tilt_angle_file = [basename, '.tlt'];
    output_xf_file = [basename, '.xf'];
    
    % Call tiltalign_wrapper.sh to generate necessary transforms for tomogram reconstruction
    command = ['tiltalign_wrapper.sh ', model_file, ' ', tilt_angle_file, ' ', num2str(rotation_angle), ' ', num2str(pixel_size_nm), ' ', output_tilt_angle_file, ' ', output_xf_file];
    [status,cmdout] = system(command);
    check_status_cmdout(status, cmdout)
    
    
    % Return to working directory
    cd(working_directory);
    
end
