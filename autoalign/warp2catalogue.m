%%% This makes a Dynamo catalogue which has the 'deconvolved' tomogram as
%%% the visualisation tomogram but particle cropping will be performed on
%%% the warp 3d-ctf corrected tomogram

function warp2catalogue(warp_reconstruction_dir, reconstruction_apix)
	mrc_files = dir(fullfile(warp_reconstruction_dir, '*.mrc'));
	vll_name = 'warp2catalogue.vll';

	f = fopen(vll_name,'wt');
	for k = 1:length(mrc_files)
  		basename = mrc_files(k).name;
  		cropping_volume = fullfile(warp_reconstruction_dir, basename);
  		deconv_name = fullfile(warp_reconstruction_dir, 'deconv', basename);
  		fprintf(f, '%s\n', deconv_name);
  		fprintf(f, '* cropFromFile = %s\n', cropping_volume);
  		fprintf(f, '* cropFromElsewhere = 1\n');
  		fprintf(f, '* label = %s\n', basename);
  		fprintf(f, '* apix = %.3f\n\n', reconstruction_apix);
	end
	fclose(f)
	
	dcm -create warp_catalogue -fromvll warp2catalogue.vll
	delete warp2catalogue.vll
end
