function final_dir_name = autoalign(stack, workflow_name, tilt_angles, apix, fiducial_diameter_nm, min_markers, workflows_folder)
    %%% Parameter descriptions
    % stack - filepath of tilt series stack in mrc format
    % workflow_name - name of workflow to be saved i.e. 'TS_298'
    % tilt_angles - filepath to text file containing tilt angles (IMOD format tlt/rawtlt) 
    % apix - pixel size in angstroms of tilt series
    % fiducial_diameter_nm - diameter of fiducials in nanometers
    % Dynamo will delete beads based on worse residuals: this sets the minimum number of beads per tilt before stopping deleting beads. An absolute minimum of 3 is required, but 4 is recommended.
    % workflows folder - directory in which to save the workflow e.g. direct path to 'output;
        
    step=0.2; %Step by which threshold is reduced 
    
    residuals_threshold=10; %For the Tilt Gap Filler. Default 10. 5 or 10 is recommended.  
        
    %Test_TS
    
    clear workflow
    
    %%% Prep names for marker and model files
    [p, basename, ext] = fileparts(workflow_name); %p is the full path to the folder (without folder name included), basename is the file name, ext is the extention.
    workflow_folder = fullfile(workflows_folder, strcat('test', basename, '.AWF')); %Should create a folder called testTS_???.AWF in output
    markers_file = fullfile(workflow_folder, 'workingMarkers.dms');
    model_file = fullfile(workflow_folder, 'workingMarkers.mod');
    
    workflow = dtsa(workflow_name, '--nogui', '-path', workflow_folder, 'fp', 1);

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
    workflow.enter.settingDetection.detectionBinningFactor(1);

    % acquisition settings
    workflow.enter.settingAcquisition.apix(apix);
    
    % relevant lengths for bead detection
    workflow.enter.settingDetection.beadRadius(fiducial_radius_px);
    workflow.enter.settingDetection.maskRadius(fiducial_radius_px * 1.75);
    workflow.enter.templateSidelength(fiducial_radius_px * 5);
    workflow.run.area.detection();

    workflow.area.indexing.step.tiltGapFiller.parameterSet.residualsThreshold(residuals_threshold)
    workflow.run.area.indexing();

    res1=5;
    res2=5;
    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1);
    workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2);
    workflow.area.refinement.step.finalSelection.parameterSet.minimumAmountOfMarkersPerMicrograph(min_markers);
    workflow.run.area.refinement();

    a=workflow.info.markers;
    empty=str2num(regexprep( (a{8}), {'\D*([\d\.]+\d)[^\d]*','[^\d\.]*'},{'$1 ',''}));
    while empty==0;
	    res1=res1-step;
	    res2=res2-step;
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1);
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2);
	    workflow.run.area.refinement();
    
	    a=workflow.info.markers;
	    empty=str2num(regexprep( (a{8}), {'\D*([\d\.]+\d)[^\d]*','[^\d\.]*'},{'$1 ',''}));
    end

    dwrite([res1,res2],[workflow_folder '/target_residual.em']);
    
    clear workflow
    
    %%%%%%%%%

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
    workflow.enter.settingDetection.detectionBinningFactor(1);

    % acquisition settings
    workflow.enter.settingAcquisition.apix(apix);
    
    % relevant lengths for bead detection
    workflow.enter.settingDetection.beadRadius(fiducial_radius_px);
    workflow.enter.settingDetection.maskRadius(fiducial_radius_px * 1.75);
    workflow.enter.templateSidelength(fiducial_radius_px * 5);
    
    workflow.run.area.detection(); 
    
    % Trim markers (aiming to keep as many good observations, later trimmed by IMOD)
    workflow.area.indexing.step.tiltGapFiller.parameterSet.residualsThreshold(residuals_threshold); 
    
    %%%%%%%%%%%%%%%%
    
    workflow.run.area.indexing();
	
    res1b=5;
    res2b=5;

    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1b);
    workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2b);
    workflow.area.refinement.step.finalSelection.parameterSet.minimumAmountOfMarkersPerMicrograph(min_markers);
    workflow.run.area.refinement();


    while res1b>res1+step+0.001 && res2b>res2+step+0.001
	    res1b=res1b-step;
	    res2b=res2b-step;
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1b);
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2b);
	    workflow.run.area.refinement();
	
    end
	
    try 
	workflow.run.step.tiltGapFiller();
	workflow.area.alignment.step.alignWorkingStack.parameterSet.alignmentBinLevel(3);
	workflow.run.area.alignment();
        
 
	%%% Run workflow up to refinement
        %workflow.run.area.uptoRefinement(); %%%%%%
    
        %%% Create IMOD format model
        dms2mod(markers_file, model_file, stack);
    
        %%% Cleanup
        final_dir_name = autoalign_workflow_cleanup(workflow_folder, workflow_name, workflows_folder);
    
    catch
	try
 	clear workflow
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
        workflow.enter.settingDetection.detectionBinningFactor(1);

        % acquisition settings
        workflow.enter.settingAcquisition.apix(apix);
    
        % relevant lengths for bead detection
        workflow.enter.settingDetection.beadRadius(fiducial_radius_px);
        workflow.enter.settingDetection.maskRadius(fiducial_radius_px * 1.75);
        workflow.enter.templateSidelength(fiducial_radius_px * 5);
    
        workflow.run.area.detection(); 
    
        % Trim markers (aiming to keep as many good observations, later trimmed by IMOD)
        workflow.area.indexing.step.tiltGapFiller.parameterSet.residualsThreshold(residuals_threshold); 
    
        %%%%%%%%%%%%%%%%
    
        workflow.run.area.indexing();
	
	res1b=5;
	res2b=5;

	workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1b);
	workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2b);
	workflow.area.refinement.step.finalSelection.parameterSet.minimumAmountOfMarkersPerMicrograph(min_markers);
	workflow.run.area.refinement();


	while res1b>res1+step+0.001 && res2b>res2+step+0.001
	    res1b=res1b-step;
	    res2b=res2b-step;
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalResidualObservation(res1b);
	    workflow.area.refinement.step.trimMarkers.parameterSet.maximalMedianResidualMarker(res2b);
	    workflow.run.area.refinement();
	
	end
	
	workflow.area.alignment.step.alignWorkingStack.parameterSet.alignmentBinLevel(3);
	workflow.run.area.alignment();
	
        %%%%%%%%%
        
        %%% Run workflow up to refinement
        %workflow.run.area.uptoRefinement(); 
    
        %%% Create IMOD format model
        dms2mod(markers_file, model_file, stack);
    
        %%% Cleanup
        final_dir_name = autoalign_workflow_cleanup(workflow_folder, workflow_name, workflows_folder);
    
    catch
	message='Failed on this tomogram';
	dwrite(message,['failed_TSA_' basename '.em']);
end
end
end
