function [directory, processed] = next_dir(warp_imod_dir, processed)
    % get stack directories
    stack_directories = get_directories(warp_imod_dir);

    for idx = 1:size(stack_directories, 1)
        directory = stack_directories(idx);
        
        % return current directory if not in list of processed directories
        if ~any(strcmp(directory.name, processed))
            [basename, stack, rawtlt] = ts_info_from_dir(directory);
            
            % add current basename to list of processed dirs
            processed{end + 1} = basename;
            return
        end
    end
    
    directory = '';
end

