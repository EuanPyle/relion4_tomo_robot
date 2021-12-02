function ctffind_wrapper(ts_dir, ext, apix, mask_size, ctffind_install)
% Wrapper for CTFFIND4. This masks your tilt series according to the tilt of each image so the same area is always used for CTF estimation across the tilt series. 
% YOU MUST RUN: import_ctffind; BEFORE RUNNING THIS PROGRAM
% ctffind_wrapper(ts_dir, ext, apix, mask_size, ctffind_install)
% e.g. ctffind_wrapper('ts_directory','.st', 1.38, 90, '/s/emib/s/ctffind4/v4.0.17/ctffind')
% ts_dir - directory containing tilt series directories
% ext = the extension of your stack file. Only accepts .st and .mrc files e.g. '.st' or '.mrc'
% apix - unbinned pixel size in A
% mask_size - given in percentage of the smaller of the two X/Y dimensions. 100 gives an uncropped image. 90 keeps 90% of the image, keeping the middle. This wrapper can crop your image so the edges of the image are not included in the CTF estimation. This is useful if the edges of you image contain carbon or grid bars. We don't recommend going below 75%.
% ctffind_install - the installation location of ctffind, link to the program itself
  
%%% List of already processed tilt-series
processed = {};

if nargin <= 4
    disp('Not enough input arguments') 
    disp('The function inputs are: % ctffind_wrapper(ts_dir, ext, apix, mask_size, ctffind_install)')
    disp('Type: help ctffind_wrapper; for more information'); 
    return
end

if ~isfile('./CTFFIND_settings.csh')
	disp('Error: Can''t find CTFFIND_settings.csh in this directory. Have you run import_ctffind?');
	return
end

%Check IMOD is loaded
command = ['point2model'];
    [status,cmdout] = system(command);
    
if contains(cmdout,'Command not found','IgnoreCase',true);
    disp('IMOD command point2model not found. Have you remembered to load IMOD in this terminal before opening MatLab?');
    return
end

%Get full ext name
if contains(ext,'st')
	full_ext = '.st';
elseif contains(ext,'mrc')
	full_ext = '.mrc';
else 
	disp('Extension not recognised. At the moment, only .st and .mrc are. Let me know if you''re using another');
        return
end
	
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
	
	ctffind(current_ts, apix, x_dim, y_dim, mask_size, ctffind_install);
end
    



