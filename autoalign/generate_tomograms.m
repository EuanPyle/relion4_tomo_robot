function generate_tomograms(ts_dir, tomo_star,binning,threads,no_weight,ctf)

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
	end
end
end

