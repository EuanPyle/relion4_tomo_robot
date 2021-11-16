function generate_tilt_order(ts_dir, scheme, max_tilt_angle, tilt_increments, n_flip)

% Generates ideal placeholder tilt order file

template_tlt=tilt_template(scheme, max_tilt_angle, tilt_increments, n_flip);

%%% List of already processed tilt-series
processed = {};

while true
        
[ts_directory, processed] = next_dir(ts_dir, processed);
        
if ischar(ts_directory)
	autoalign_sleep(processed)
	continue
end
    	
current_ts = fullfile(ts_directory.folder, ts_directory.name);

% Go into folder in TS folder

working_dir = pwd;

cd(current_ts);

% Reads .tlt files and removes tilts which are missing

tlt = dread(strcat(ts_directory.name,'.tlt'));

missing_tilt_idx = find(~ismember(template_tlt(:,2),tlt));

correct_tlt = template_tlt;

correct_tlt(missing_tilt_idx,:) = []; 

% Writes csv file with correct name

csvwrite([ts_directory.name '.csv'],correct_tlt);

cd(working_dir);

end
end
