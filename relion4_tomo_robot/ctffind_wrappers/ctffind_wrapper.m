function ctffind_wrapper(ts_dir, apix, x_dim, y_dim, mask_size, ctffind_install)
% Wrapper for CTFFIND4. This masks your tilt series according to the tilt of each image so the same area is always used for CTF estimation across the tilt series. 
% YOU MUST RUN: import_ctffind; BEFORE RUNNING THIS PROGRAM
% ctffind_wrapper(ts_dir, apix, x_dim, y_dim, mask_size, ctffind_install)
% e.g. ctffind_wrapper('ts_directory', 1.38, 5760, 4092, 75, '/s/emib/s/ctffind4/v4.0.17/ctffind')
% ts_dir - directory containing tilt series directories
% apix - unbinned pixel size in A
% x_dim - unbinnded x dimensions of tilt series image stack
% y_dim - unbinnded y dimensions of tilt series image stack
% mask_size - given in percentage. 100 gives an uncropped image. 75 keeps 75% of the image, keeping the middle. This wrapper can crop your image so the edges of the image are not included in the CTF estimation. This is useful if the edges of you image contain carbon or grid bars. 
% ctffind_install - the installation location of ctffind, link to the program itself
  
%%% List of already processed tilt-series
processed = {};

if ~isfile('./CTFFIND_settings.csh')
	disp('Error: Can''t find CTFFIND_settings.csh in this directory. Have you run import_ctffind?');
	return
end

while true
        
	[ts_directory, processed] = next_dir(ts_dir, processed);
        
        if ischar(ts_directory)
                autoalign_sleep(processed)
                continue
        end
    	
	current_ts = fullfile(ts_directory.folder, ts_directory.name);
	
	ctffind(current_ts, apix, x_dim, y_dim, mask_size, ctffind_install);
end
    



