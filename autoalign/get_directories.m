function directories = get_directories(path)
    files = dir(path);
    dir_flags = [files.isdir];
    directories = files(dir_flags);
    directories(ismember( {directories.name}, {'.', '..'})) = [];
end

