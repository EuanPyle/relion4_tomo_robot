function generate_metadata(ts_dir,ext,scheme,n_flip,dose,thickness)
%This function will generate the metadata needed for RELION 4, including the newst.com & tilt.com files, the tilt order list, and the tomograms_descr.star file
% Dynamo and IMOD must be loaded in this terminal window for this function to work
% The function inputs are: generate_metadata(ts_dir, ext, tilt_scheme, n_flip, dose, tomo_thickness)
% e.g. generate_metadata('ts_directory','.st','dose_sym',2,3.4,3000) 
% Where: 
%ts_dir = directory containing tilt series directories
% ext = the extension of your stack file. Only accepts .st and .mrc files (e.g. '.st' or '.mrc')
% tilt_scheme = the tilt scheme your data was collected in. This can either be 'dose_sym' for dose symmetric tilt schemes, 'bidi_+ve' for bidirectional tilt schemes where the positive angles were aquired first (e.g. first images taken were angles: 0,3,6,9), 'bidi_-ve' for bidirectional tilt schemes where the negative angles were aquired first (e.g. first images taken were angles: 0,-3,-6,-9)
% n_flip = for dose_symmetric tilt schemes and refers to the number of tilts before the angular sign 'flips'. e.g. for a tilt scheme first images taken were angles: 0,3,-3 -6 6 9 -9 -12; n_flip would equal 2. For a tilt scheme first images taken were angles: 0,3,6,-3,-6,-9,9; n_flip would equal 3. 
% NOTE: For bidirectional tilt schemes n_flip should be left either blank: [], or any number you wish.
% dose = dose per tilt of each image in e/A^2
% tomo_thickness = unbinned thickness of the tomogram to be generated. We tend to use a value of 3000
%%%%% For newst/tilt.com files, you will be prompeted to either choose to use the template provided (recommended) or if the tomograms produced look strange, you can use your own tilt and newst.com templates after a quick etomo reconstruction. Note, the latter way is error prone.
    
%%% List of already processed tilt-series
processed = {};

if nargin <= 5
    disp('Not enough input arguments') 
    disp('The function inputs are: generate_metadata(ts_dir, ext, tilt_scheme, n_flip, dose, tomo_thickness)')
    disp('Type: help generate_metadata; for more information'); 
    return
end

%Check IMOD is loaded
command = ['point2model'];
    [status,cmdout] = system(command);
    
if contains(cmdout,'Command not found','IgnoreCase',true);
    disp('IMOD command point2model not found. Have you remembered to load IMOD in this terminal before opening MatLab?');
    return
end
        
prompt = 'Would you like to use the provided template for the tilt.com and newst.com files (default) (y) or to use your own templates (n)? (y/n) \n:'; 
    
version_com = input(prompt,'s');

if version_com == 'n' | version_com == 'N'
    
    	prompt = 'Provide the path to the newst.com file you wish to use as a template';
    	newst_com = input(prompt,'s');
    	prompt = 'Provide the path to the tilt.com file you wish to use as a template';
    	tilt_com = input(prompt,'s');
else 
	[newst_com_template, tilt_com_template] = template_generator;
	newst_com = './template_newst.com';
	tilt_com = './template_tilt.com';
end

generate_tomograms_descr(ts_dir,ext,dose)

%Get full ext name
if contains(ext,'st')
	full_ext = '.st';
elseif contains(ext,'mrc')
	full_ext = '.mrc';
else 
	disp('Extension not recognised. At the moment, only .st and .mrc are. Let me know if you''re using another');
        return
end

if isfile(newst_com) & isfile(tilt_com)

while true
        
	[ts_directory, processed] = next_dir(ts_dir, processed);
        
        if ischar(ts_directory)
                autoalign_sleep(processed)
                continue
        end
    	
	current_ts = fullfile(ts_directory.folder, ts_directory.name);
	
	%Extract x and y dimensions of image
	
	command = ['header ' strcat(current_ts,'/',ts_directory.name,full_ext)];
	
	[status,header_string] = system(command);
	
	header_string = strsplit(header_string,'\n');
	
	header_string = header_string(contains(header_string,'Number of columns, rows, sections'));
	
	header_string = erase(header_string{:},'Number of columns, rows, sections .....');
	
	header_string = str2num(header_string);
				
	x_dim = header_string(1);
	
	y_dim = header_string(2);
	
	tlt = dread(strcat(current_ts,'/',ts_directory.name,'.tlt'));
	
	tlt_min = abs(tlt(1));
	
	tlt_max = abs(tlt(end));
	
	max_tilt_angle = max(tlt_min,tlt_max);
	
	%Working out the tilt increment - this method may fail if there are lots of excluded views, but tomograms that bad should be thrown away anyway!
	tilt_increments = median(diff(tlt));
		
	com_file_spoofer(current_ts, x_dim, y_dim, thickness, newst_com, tilt_com);
	
	template_tlt=tilt_template(scheme, max_tilt_angle, tilt_increments, n_flip); 
	
	% Reads .tlt files and removes tilts which are missing

	missing_tilt_idx = find(~ismember(template_tlt(:,2),tlt));

	correct_tlt = template_tlt;

	correct_tlt(missing_tilt_idx,:) = []; 

	% Writes csv file with correct name

	csvwrite(strcat(current_ts,'/',ts_directory.name, '.csv'),correct_tlt);
	
end

else
	disp('Cannot generate either newst.com or tilt.com file. If you gave a path to the newst or tilt.com files, check it is correct.');
end
    



