function ts_dir_name_full = autoalign_workflow_cleanup(workflow_folder, ts_dir_name, workflows_folder)
    %%%%% cleanup unnecessary files in workflow folder and rename to have proper name 
    
    % File names
    ts_dir_name_full = fullfile(workflows_folder, ts_dir_name)
    test_dir_name = fullfile(workflows_folder, strcat('test',ts_dir_name,'.AWF'))
    align_folder = fullfile(workflow_folder, 'align')
    config_folder = fullfile(workflow_folder, 'configFiles')
    detection_folder = fullfile(workflow_folder, 'detection')
    intermediate_markers_folder = fullfile(workflow_folder, 'markersIntermediate')
    markers_model_file_imod = fullfile(workflow_folder, 'workingMarkers.mod')
    nominal_tilt_angles = fullfile(workflow_folder, 'workingMarkers.tlt')
    
    % Try to remove not needed folders
    try
        rmdir(align_folder, 's')
        rmdir(config_folder, 's')
        rmdir(detection_folder, 's')
        rmdir(intermediate_markers_folder, 's')
	rmdir(test_dir_name, 's')
    catch
        
    end
    
    % model file name in ts directory
    new_markers_file = [ts_dir_name, '.mod'];
    [filepath, name, ext] = fileparts(new_markers_file);
    new_markers_file = [name, ext];
    
    % rawtlt file name in ts directory
    new_rawtlt_file = [ts_dir_name, '.rawtlt'];
    [filepath, name, ext] = fileparts(new_rawtlt_file);
    new_rawtlt_file = [name, ext];

    % move files into right places
    movefile(markers_model_file_imod, fullfile(ts_dir_name_full, new_markers_file));
    movefile(nominal_tilt_angles, fullfile(ts_dir_name_full, new_rawtlt_file));
   
    % move intermediate dynamo workflow folder to final folder with correct name
    movefile(workflow_folder, ts_dir_name_full);
end
