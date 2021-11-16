function [basename, stack, rawtlt] = ts_info_from_directory(directory)
    basename = directory.name;
    ts_folder = fullfile(directory.folder, directory.name);
    if isfile(fullfile(ts_folder, [basename, '.st']))
    	stack = fullfile(ts_folder, [basename, '.st']);
    elseif fullfile(ts_folder, [basename, '.mrc'])
    	stack = fullfile(ts_folder, [basename, '.mrc']);
    else
    	disp('Not recognised file extension. Must be either .st or .mrc');
	return
    end
    rawtlt = fullfile(ts_folder, [basename, '.rawtlt']);
end

