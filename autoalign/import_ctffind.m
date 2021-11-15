try
	command = ['cp ' install_loc '/CTFFIND4_settings_template.csh ./CTFFIND_settings.csh'];
	system(command);
catch
	disp('Re-run: install_loc = autoalign_activate; as per the start of the protocol');
end


    



