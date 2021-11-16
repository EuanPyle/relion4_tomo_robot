install_loc = 'XXX_INSTALL_LOC_XXX';
PATH = getenv('PATH');
addpath(['XXX_INSTALL_LOC_XXX' '/autoalign']);
addpath(['XXX_INSTALL_LOC_XXX' '/ctffind_wrappers']);
addpath(['XXX_INSTALL_LOC_XXX' '/relion_metadata_generators']);
setenv('PATH', [install_loc, ':' PATH]);
setenv('PATH', [[install_loc,'/autoalign'], ':' PATH]);
clear PATH
disp("Successfully activated 'relion_tomo_robot'!")

