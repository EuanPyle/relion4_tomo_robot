%%% Parameters to set
apix = 2.236;
fiducial_diameter_nm = 10;
workflows_folder = 'dynamo_alignment_workflows'


%%% Main
base_folder = pwd;
files = dir(base_folder);
dir_flags = [files.isdir];
directories = files(dir_flags);


for i = 1:length(directories)
   basename = directories(i).name;
   stack = fullfile(basename, [basename, '.st']);
   rawtlt = fullfile(basename, [basename, '.rawtlt']);
   
   if contains(basename, '.mrc')
       try
          u = align(stack, basename, rawtlt, apix, fiducial_diameter_nm, workflows_folder) 
       catch
           fprintf('failed on: %s\n', basename)
       end
   end
end

delete tmp.tlt
delete tmp.csv


%%% Functions
function u = align(stack, workflow_name, tilt_angles, apix, fiducial_diameter_nm, workflows_folder)
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
    u.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(10);
    
    %%% Run workflow up to refinement
    u.run.area.uptoRefinement();
    
    %%% Create IMOD format model
    workflow_folder = fullfile(workflows_folder, [workflow_name, '.AWF']);
    markers_file = fullfile(workflow_folder, 'workingMarkers.dms');
    model_file = fullfile(workflow_folder, 'workingMarkers.mod');
    dms2mod(markers_file, model_file);
    
end

function dms2mod(markers_dms_file, model_file)
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
    command = ['point2model -ci 5 -w 1 -co 120,120,255 tmp.csv ', model_file]
    system(command)
    
    %%% Write out tilt angles
    tilt_angle_file = strrep(model_file, '.mod', '.tlt')
    writematrix(tilt_angles, tilt_angle_file)
end
