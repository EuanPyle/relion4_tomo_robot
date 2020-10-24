function check_status_cmdout(status, cmdout)
    if status == 0
        return
    end
    orig_state = warning;
    warning('on');
    warning(cmdout);
    warning(orig_state)
end

