function autoalign_sleep(processed)
    % Initial message to inform that no new TS found
    msg = sprintf('No new tilt series found at %s\n', datestr(now,'HH:MM:SS'));
    disp(msg);
    
    % Inform about n tilt series processed
    n_processed = size(processed, 2);
    msg = sprintf('%d tilt series processed in this session so far', n_processed);
    disp(msg)
    
    % Sleep
    disp('Going to sleep for 10 minutes...')
    pause(30)
end

