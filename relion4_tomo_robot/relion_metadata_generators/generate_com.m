function generate_com(ts_dir, x_dim, y_dim, thickness)
    
%This will generate the tilt.com and newst.com files needed for RELION 4. 
    
%You can either choose to use your own tilt and newst.com templates after a quick etomo reconstruction, or to use the template provided
    
%Using our template should be fine for most, but if you are getting errors or strange reconstructions, it may be best to use your own template gnerated by IMODs etomo program
    
%%% List of already processed tilt-series
processed = {};
        
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

if isfile(newst_com) & isfile(tilt_com)

while true
        
	[ts_directory, processed] = next_dir(ts_dir, processed);
        
        if ischar(ts_directory)
                autoalign_sleep(processed)
                continue
        end
    	
	current_ts = fullfile(ts_directory.folder, ts_directory.name);
	
	com_file_spoofer(current_ts, x_dim, y_dim, thickness, newst_com, tilt_com);
end

else
	disp('Cannot generate either newst.com or tilt.com file. If you gave a path to the newst or tilt.com files, check it is correct.');
end
    


