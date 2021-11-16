function import_ctffind
try
	command = ['cp ' install_loc '/ctffind_wrappers/CTFFIND4_settings_template.csh ./CTFFIND_settings.csh'];
	system(command);
catch
	disp('Set the variable install_loc as the install location of this package');
end


    



