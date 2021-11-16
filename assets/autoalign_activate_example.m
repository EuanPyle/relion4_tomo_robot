install_loc = 'XXX_INSTALL_LOC_XXX';
PATH = getenv('PATH');
addpath([install_loc '/autoalign']);
addpath([install_loc '/ctffind_wrappers']);
addpath([install_loc '/relion_metadata_generators']);
setenv('PATH', [install_loc, ':' PATH]);
clear PATH
disp("Successfully activated 'autoalign_dynamo'!")

