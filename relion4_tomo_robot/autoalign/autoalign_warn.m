function [outputArg1,outputArg2] = autoalign_warn(msg)
    % Seems like dynamo plays with warning state, capture original state
    orig_state = warning;
    warning('on');
    
    % warn
    warning(msg);
    
    % restore original state
    warning(orig_state);
end

