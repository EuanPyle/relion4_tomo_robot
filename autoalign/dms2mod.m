function dms2mod(markers_dms_file, model_file, image_file)
    %%%%% Convert Dynamo markers (.dms files) into IMOD format model files (.mod)
    %%%%% Requires MATLAB >= r2019a
    %%%%% Requires Dynamo >= 1.1.478
    %%%%% Requires IMOD >= 4.10.37
    %%% Reading marker file
    m = dread(markers_dms_file);
    
    %%% Extract useful objects
    markers = m.shapes;
    n_markers = size(markers, 2);
    
    tilt_angles = m.nominalTiltAngles;
    n_tilt_angles = size(tilt_angles, 1);
    
    %%% Extraction of coordinates in array resembling IMOD format (contour, x, y, z)
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
    writematrix(real(output), 'tmp.csv', 'Delimiter', 'tab');
    
    %%% Run point2model to obtain IMOD format model file
    command = ['point2model -ci 5 -w 1 -co 120,120,255 -image ', image_file, ' tmp.csv ', model_file];
    [status, cmdout] = system(command);
    check_status_cmdout(status, cmdout);
    
    %%% Write out tilt angles
    tilt_angle_file = strrep(model_file, '.mod', '.tlt');
    writematrix(tilt_angles, tilt_angle_file, 'FileType', 'text');
end