function generate_tomograms(ts_dir, tomo_star,binning,threads,no_weight,ctf)
% A wrapper to tell RELION to generate all of your tomograms in a directory called tomograms/
% generate_tomograms(ts_dir, tomo_star,binning,threads,no_weight,ctf)
% e.g. generate_tomograms('ts_directory', 'ImportTomo/job001/tomograms.star',8,16,'y','n');
% ts_dir - directory containing tilt series directories
% tomo_star - the path to the tomograms.star file generated after importing your tomograms
% binning - the desired (IMOD convention) binning of your tomograms 
% threads - the number of threads dedicated to generating tomograms. If you are unsure, enter 1 but this will be slower
% no_weight - enter 'y' or 'n'; 'y' indicates to relion to use the no_weight flag when generating tomograms. We found this increased contrast which was useful for particle picking. Select 'n' to not use this flag. If passing tomograms to a program which will alter the tomograms further, e.g. IsoNet, select 'n'.
% ctf - enter 'y' or 'n'; 'y' indicates to relion to ctf correct the tomograms. 'n' tells relion to use the --noctf flag. Using the --noctf flag can increase contrast. 

command = ['relion_tomo_reconstruct_tomogram'];
[status,cmdout] = system(command);
    
if contains(cmdout,'Command not found','IgnoreCase',true);
    	disp('relion_tomo_reconstruct_tomogram not found. Have you remembered to load RELION in this terminal before opening MatLab?');
	return
end

%%% List of already processed tilt-series
processed = {};

while true
        
	[ts_directory, processed] = next_dir(ts_dir, processed);
        
	if ischar(ts_directory)
		autoalign_sleep(processed)
		continue
	end
    	
	current_ts = fullfile(ts_directory.folder, ts_directory.name);

	% Run relion_tomo_reconstruct_tomogram
	if (no_weight == 'Y' | no_weight == 'y') & (ctf == 'y' | ctf == 'Y') 
		command = ['relion_tomo_reconstruct_tomogram --t ' tomo_star ' --tn ' ts_directory.name ' --bin ' num2str(binning) ' --j ' num2str(threads) ' --no_weight --o tomograms/' ts_directory.name '.mrc'];
		system(command);
	elseif (no_weight == 'Y' | no_weight == 'y') & (ctf == 'n' | ctf == 'N') 
		command = ['relion_tomo_reconstruct_tomogram --t ' tomo_star ' --tn ' ts_directory.name ' --bin ' num2str(binning) ' --j ' num2str(threads) ' --no_weight --noctf --o tomograms/' ts_directory.name '.mrc'];
		system(command);
	elseif (no_weight == 'N' | no_weight == 'n') & (ctf == 'Y' | ctf == 'y')
		command = ['relion_tomo_reconstruct_tomogram --t ' tomo_star ' --tn ' ts_directory.name ' --bin ' num2str(binning) ' --j ' num2str(threads) ' --o tomograms/' ts_directory.name '.mrc'];
		system(command);
	else
		command = ['relion_tomo_reconstruct_tomogram --t ' tomo_star ' --tn ' ts_directory.name ' --bin ' num2str(binning) ' --j ' num2str(threads) ' --noctf --o tomograms/' ts_directory.name '.mrc'];
	disp('Running without ctf and without the no_weight flag');
	end
end
end

