function com_file_spoofer(ts_dir, x_dim, y_dim, thickness, newst_com, tilt_com)

newst_com = fileread(newst_com);
tilt_com = fileread(tilt_com);

if isnumeric(x_dim)
	x_dim=num2str(x_dim);
end

if isnumeric(y_dim)
	y_dim=num2str(y_dim);
end

if isnumeric(thickness)
	thickness=num2str(thickness);
end

%Finds the TS number in the template com files
temp_ts_number_id = extractBetween(newst_com,'_','.');
temp_ts_number_id = temp_ts_number_id{1};

%Finds the TS number in the folder of where the com files will be left
ts_number_id = split(ts_dir,'/');
idx = length(ts_number_id);
ts_number_id = ts_number_id{idx};
ts_number_id = split(ts_number_id,'_');
idx = length(ts_number_id);
ts_number_id = ts_number_id{idx};

%Replaces template TS_ number in com files with correct TS_ number from folder

newst_com = strrep(newst_com,['_' temp_ts_number_id '.'],['_' ts_number_id '.']);
tilt_com = strrep(tilt_com,['_' temp_ts_number_id '.'],['_' ts_number_id '.']);

newst_com = strrep(newst_com,['_' temp_ts_number_id '_'],['_' ts_number_id '_']);
tilt_com = strrep(tilt_com,['_' temp_ts_number_id '_'],['_' ts_number_id '_']);

%Finds the image dimensions in the template com files

dimensions_string=extractBetween(tilt_com,'FULLIMAGE ','SUBSETSTART');
dimensions_string=str2num(dimensions_string{:});

temp_y_dim = dimensions_string(1);
temp_x_dim = dimensions_string(2);

%Replaces image dimensions in com files
newst_com = strrep(newst_com,num2str(temp_x_dim),x_dim);
tilt_com = strrep(tilt_com,num2str(temp_x_dim),x_dim);
newst_com = strrep(newst_com,num2str(temp_y_dim),y_dim);
tilt_com = strrep(tilt_com,num2str(temp_y_dim),y_dim);

%Replaces template thickness with desired thickness
thickness_string=extractBetween(tilt_com,'FULLIMAGE ','SUBSETSTART');
temp_thickness=str2num(thickness_string{:});

newst_com = strrep(newst_com,num2str(temp_thickness),thickness);
tilt_com = strrep(tilt_com,num2str(temp_thickness),thickness);

%Writes out new com files

wd = pwd;

cd(ts_dir)

fid = fopen('newst.com','w');
fprintf(fid, '%s',newst_com);
fclose(fid);

fid = fopen('tilt.com','w');
fprintf(fid, '%s',tilt_com);
fclose(fid);

cd(wd)
    
end
