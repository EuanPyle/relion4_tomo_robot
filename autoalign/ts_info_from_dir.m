function [basename, stack, rawtlt] = ts_info_from_directory(directory)
    basename = directory.name;
    ts_folder = fullfile(directory.folder, directory.name);
    stack = fullfile(ts_folder, [basename, '.st']);
    rawtlt = fullfile(ts_folder, [basename, '.rawtlt']);
end

