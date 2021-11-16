function generate_tomograms_descr(ts_dir,ext,dose)
 
processed = {};

if ~isfile('tomograms_descr.star')
    disp('Cannot find tomograms_descr.star in this directory. Re-run autoalign_activate and import_tomograms_descr');
    return
end
    
directory = dir([ts_dir]);
directory = directory(~ismember({directory.name},{'.','..'}));

for i = 1:length(directory)

[ts_directory, processed] = next_dir(ts_dir, processed);
             
current_ts = fullfile(ts_directory.folder, ts_directory.name);

tomo_name = ts_directory.name;
    
if ext == '.st'

    tomo_location = [ts_dir '/' tomo_name '/' tomo_name '.st:mrc']; 

else 
   
    tomo_location = [ts_dir '/' tomo_name '/' tomo_name '.mrc'];
	
end

ctf_file = [ts_dir '/' tomo_name '/CTFFIND/CTFfind4In_output.txt']; 

imod_folder = [ts_dir '/' tomo_name];

order_list = [ts_dir '/' tomo_name '/' tomo_name '.csv'];

x_off=num2str(0);
y_off=num2str(0); 
z_off=num2str(0);

output{i,1}=[tomo_name '   ' tomo_location '   ' ctf_file '   ' imod_folder '   ' num2str(dose) '   ' x_off '   ' y_off '   ' z_off '   ' order_list];
end

writecell(output,'star_text.txt');
    
command = ['cat star_text.txt >> tomograms_descr.star'];
system(command);
command = 'rm star_text.txt';
system(command);


end


