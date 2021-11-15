install_loc = 'XXX_INSTALL_LOC_XXX';
PATH = getenv('PATH');
addpath(install_loc);
setenv('PATH', [install_loc, ':' PATH]);
clear PATH
disp("Successfully activated 'autoalign_dynamo'!")

