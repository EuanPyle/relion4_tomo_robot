function generate_tilt_order(ts_dir, scheme, max_tilt_angle, tilt_increments, n_flip)
% Generates ideal placeholder tilt order file
% generate_tilt_order(ts_dir, scheme, max_tilt_angle, tilt_increments, n_flip)
% e.g. generate_tilt_order('ts_directory', 'dose_sym', 60, 3, 2)
% ts_dir - directory containing tilt series directories
% scheme can either be 'dose_sym' for dose symmetric tilt schemes, 'bidi_+ve' for bidirectional tilt schemes where the positive angles were aquired first (e.g. first images taken were angles: 0,3,6,9), 'bidi_-ve' for bidirectional tilt schemes where the negative angles were aquired first (e.g. first images taken were angles: 0,-3,-6,-9).
% max_tilt_angle is the maximum positive tilt angle in your tilt series. For a tilt series collected between -60 and +60 degrees you would enter 60.
% tilt_increments is the smallest angular increase between each tilt, e.g. for a tilt scheme first images taken were angles: 0,3,-3 -6 6 9 -9 -12; the tilt increment would be 3. 
% n_flip is for dose_symmetric tilt schemes and refers to the number of tilts before the angular sign 'flips'. e.g. for a tilt scheme first images taken were angles: 0,3,-3 -6 6 9 -9 -12; n_flip would equal 2. For a tilt scheme first images taken were angles: 0,3,6,-3,-6,-9,9; n_flip would equal 3. For bidirectional tilt schemes this input should be left either blank: [], or any number you wish.

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
