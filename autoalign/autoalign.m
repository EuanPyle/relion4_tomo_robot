function final_dir_name = autoalign(stack, workflow_name, tilt_angles, apix, fiducial_diameter_nm, workflows_folder)
    %%% Parameter descriptions
    % stack - filepath of tilt series stack in mrc format
    % workflow_name - name of workflow to be saved
    % tilt_angles - filepath to text file containing tilt angles (IMOD format tlt/rawtlt)
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - diameter of fiducials in nanometers
    % workflows folder - directory in which to save the workflow

    %%% Prep names for marker and model files
    [p, basename, ext] = fileparts(workflow_name);
    workflow_folder = fullfile(workflows_folder, strcat(basename, '.AWF'));
    markers_file = fullfile(workflow_folder, 'workingMarkers.dms');
    model_file = fullfile(workflow_folder, 'workingMarkers.mod');

    %%% Set up alignment workflow
    workflow = dtsa(workflow_name, '--nogui', '-path', workflows_folder, 'fp', 1);
    
    %%% Calculate fiducial radius in unbinned pixels
    fiducial_diameter_px = (fiducial_diameter_nm * 10) / apix;
    fiducial_radius_px = fiducial_diameter_px / 2;
    fiducial_radius_px = round(fiducial_radius_px);

    % Copy tilt angles to temporary file 
    % (does not accept .rawtlt files so do this to force .tlt extension)
    copyfile(tilt_angles, 'tmp.tlt');

    % Assign workflow parameters
    % files
    workflow.enter.tiltSeries(stack);
    workflow.enter.tiltAngles('tmp.tlt');
    
    % computing params
    workflow.enter.settingComputing.parallelCPUUse(1);
    workflow.enter.settingComputing.cpus('*')
    workflow.enter.settingDetection.detectionBinningFactor(1);

    % acquisition settings
    workflow.enter.settingAcquisition.apix(apix);
    
    % relevant lengths for bead detection
    workflow.enter.settingDetection.beadRadius(fiducial_radius_px);
    workflow.enter.settingDetection.maskRadius(fiducial_radius_px * 1.5);
    workflow.enter.templateSidelength(fiducial_radius_px * 4);
    
    % Trim markers (aiming to keep as many good observations, later trimmed by IMOD)
    workflow.area.indexing.step.tiltGapFiller.parameterSet.residualsThreshold(5);
    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(5);
    
    %%% Run workflow up to refinement
    workflow.run.area.uptoRefinement();
    
    %%% Create IMOD format model
    dms2mod(markers_file, model_file, stack);
    
    %%% Cleanup
    final_dir_name = autoalign_workflow_cleanup(workflow_folder);
end