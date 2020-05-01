%%% Function to be run in 'imod' directory output by warp

function dautoalign4warp(apix, fiducial_diameter_nm, nominal_rotation_angle, workflows_folder)
    base_folder = pwd;
    files = dir(base_folder);
    dir_flags = [files.isdir];
    directories = files(dir_flags);
    
    PATH = getenv('PATH');
    setenv('PATH', [PATH ':/home/aburt/bin/bash:/home/aburt/bin/python']);
    
    for i = 1:length(directories)
        basename = directories(i).name;
        stack = fullfile(basename, [basename, '.st']);
        rawtlt = fullfile(basename, [basename, '.rawtlt']);
   
        if contains(basename, '.mrc')
            try
                final_dir_name = align(stack, basename, rawtlt, apix, fiducial_diameter_nm, workflows_folder)
                tiltalign_warp(final_dir_name, nominal_rotation_angle, apix)
            catch
                fprintf('failed on: %s\n', basename)
            end
        end
    end

    delete tmp.tlt;
    delete tmp.csv;

    info_file_paths = fullfile(workflows_folder, '*', 'info', 'fitting.doc');
    command = ['cat ', info_file_paths, ' | grep rms && grep total\ markers'];
    system(command)
end

%%% Local functions
function final_dir_name = align(stack, workflow_name, tilt_angles, apix, fiducial_diameter_nm, workflows_folder)
    %%% Set up alignment workflow
    u = dtsa(workflow_name, '--nogui', '-path', workflows_folder, 'fp', 1);
    
    % Enter Parameters
    u.enter.tiltSeries(stack);
    copyfile(tilt_angles, 'tmp.tlt');
    u.enter.tiltAngles('tmp.tlt');
    
    u.enter.settingAcquisition.apix(2.7);
    u.enter.settingComputing.parallelCPUUse(1);
    u.enter.settingComputing.cpus('*')
    
    fiducial_diameter_px = (fiducial_diameter_nm * 10) / apix;
    fiducial_radius_px = fiducial_diameter_px / 2;
    fiducial_radius_px = round(fiducial_radius_px);
    
    u.enter.settingDetection.beadRadius(fiducial_radius_px);
    u.enter.settingDetection.maskRadius(fiducial_radius_px * 1.5);
    u.enter.templateSidelength(fiducial_radius_px * 4);
    u.enter.settingDetection.detectionBinningFactor(1);
    
    u.area.indexing.step.tiltGapFiller.parameterSet.residualsThreshold(5);
    u.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(5);
    
    %%% Run workflow up to refinement
    u.run.area.uptoRefinement('-skipProcessed');
    
    %%% Create IMOD format model
    workflow_folder = fullfile(workflows_folder, strrep(workflow_name, '.mrc', '.AWF'));
    markers_file = fullfile(workflow_folder, 'workingMarkers.dms');
    model_file = fullfile(workflow_folder, 'workingMarkers.mod');
    dms2mod(markers_file, model_file, stack);
    
    %%% Cleanup
    final_dir_name = cleanup(workflow_folder)
end

function dms2mod(markers_dms_file, model_file, image_file)
    %%% Reading marker file
    m = dread(markers_dms_file);
    
    %%% Extract useful objects
    markers = m.shapes;
    n_markers = size(markers, 2);
    
    tilt_angles = m.nominalTiltAngles;
    n_tilt_angles = size(tilt_angles, 1);
    
    %%% Extraction of coordinates in IMOD format (contour, x, y, z)
    output = [];
    for contour_idx = 1:n_markers
        current_contour = markers(1, contour_idx);
        xy = current_contour.coordinates;
        
        for z_idx = 1:size(xy, 2)
            c_xy = xy{z_idx};
            if size(c_xy, 1) > 0
                x = c_xy(1);
                y = c_xy(2);
                z = z_idx - 1;
                output = [output; contour_idx, x, y, z];
            end
        end
    end
    
    %%% Write text file containing points in IMOD format
    writematrix(output, 'tmp.csv', 'Delimiter', 'tab');
    
    %%% Run point2model to obtain IMOD format model file
    command = ['point2model -ci 5 -w 1 -co 120,120,255 -image ', image_file, ' tmp.csv ', model_file]
    system(command)
    
    %%% Write out tilt angles
    tilt_angle_file = strrep(model_file, '.mod', '.tlt')
    writematrix(tilt_angles, tilt_angle_file, 'FileType', 'text')
end

function warp_dir_name = cleanup(workflow_folder)
    warp_dir_name = strrep(workflow_folder, '.AWF', '.mrc');
    
    align_folder = fullfile(workflow_folder, 'align');
    config_folder = fullfile(workflow_folder, 'configFiles');
    detection_folder = fullfile(workflow_folder, 'detection');
    intermediate_markers_folder = fullfile(workflow_folder, 'markersIntermediate');
    markers_model = fullfile(workflow_folder, 'workingMarkers.mod');
    nominal_tilt_angles = fullfile(workflow_folder, 'workingMarkers.tlt');
    
    try
        rmdir(align_folder, 's');
        rmdir(config_folder, 's');
        rmdir(detection_folder, 's');
        rmdir(intermediate_markers_folder, 's');
    catch
        
    end
    
    new_markers_file = [warp_dir_name, '.mod'];
    [filepath, name, ext] = fileparts(new_markers_file);
    new_markers_file = [name, ext];
    
    new_rawtlt_file = [warp_dir_name, '.rawtlt'];
    [filepath, name, ext] = fileparts(new_rawtlt_file);
    new_rawtlt_file = [name, ext];

    movefile(markers_model, fullfile(workflow_folder, new_markers_file));
    movefile(nominal_tilt_angles, fullfile(workflow_folder, new_rawtlt_file));
    
    movefile(workflow_folder, warp_dir_name)
end

function tiltalign_warp(warp_folder, rotation_angle, pixel_size_angstrom)
    %%% requires tiltalign_wrapper.sh to be on the path
    %%% tiltalign wrapper uses get_tasolution.py
    working_directory = pwd;
    cd(warp_folder)
    
    [p, n, ext] = fileparts(warp_folder);
    basename = [n, ext];
    
    model_file = [basename, '.mod'];
    tilt_angle_file = [basename, '.rawtlt'];
    pixel_size_nm = pixel_size_angstrom / 10;
    output_tilt_angle_file = [basename, '.tlt'];
    output_xf_file = [basename, '.xf'];
    
    command = ['tiltalign_wrapper.sh ', model_file, ' ', tilt_angle_file, ' ', num2str(rotation_angle), ' ', num2str(pixel_size_nm), ' ', output_tilt_angle_file, ' ', output_xf_file];
    system(command);
    
    cd(working_directory)
    
end