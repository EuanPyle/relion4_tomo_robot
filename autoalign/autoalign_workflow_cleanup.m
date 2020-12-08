function warp_dir_name = autoalign_workflow_cleanup(workflow_folder, warp_dir_name)
    %%%%% cleanup unnecessary files in workflow folder and rename to have proper name for Warp

    % File names
    align_folder = fullfile(workflow_folder, 'align');
    config_folder = fullfile(workflow_folder, 'configFiles');
    detection_folder = fullfile(workflow_folder, 'detection');
    intermediate_markers_folder = fullfile(workflow_folder, 'markersIntermediate');
    markers_model_file_imod = fullfile(workflow_folder, 'workingMarkers.mod');
    nominal_tilt_angles = fullfile(workflow_folder, 'workingMarkers.tlt');
    
    % Try to remove not needed folders
    try
        rmdir(align_folder, 's');
        rmdir(config_folder, 's');
        rmdir(detection_folder, 's');
        rmdir(intermediate_markers_folder, 's');
    catch
        
    end
    
    % model file name in warp directory
    new_markers_file = [warp_dir_name, '.mod'];
    [filepath, name, ext] = fileparts(new_markers_file);
    new_markers_file = [name, ext];
    
    % rawtlt file name in warp directory
    new_rawtlt_file = [warp_dir_name, '.rawtlt'];
    [filepath, name, ext] = fileparts(new_rawtlt_file);
    new_rawtlt_file = [name, ext];

    % move files into right places
    movefile(markers_model_file_imod, fullfile(workflow_folder, new_markers_file));
    movefile(nominal_tilt_angles, fullfile(workflow_folder, new_rawtlt_file));
    
    % rename workflow folder to final resting place
    movefile(workflow_folder, warp_dir_name);
end