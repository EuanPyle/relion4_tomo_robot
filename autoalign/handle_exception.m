function handle_exception(matlab_exception)
    % Handle specific cases with advice
    if contains(matlab_exception.message, 'point2model')
    	autoalign_warn('Make sure IMOD is visible in the path from the MATLAB shell by typing\n !point2model\n')
    elseif contains(matlab_exception.message, 'writematrix')
    	autoalign_warn('writematrix is not available in your version of MATLAB, please update to MATLAB r2019a or later')
    end
    
    % Warn anyway - silent warnings != good
    autoalign_warn(matlab_exception.message)
    autoalign_warn('Attempting to continue...')
end

