#!/bin/csh -x

set strip1 = `basename $1`

set strip=`echo $1 | sed 's/.mrc//'`
set suffix = "_output.mrc"
set DESTDIR = $strip$suffix

$3  
$1 
no
$DESTDIR 
$2 
300.0 
2.7 
0.07 
512 
50.0 
5.0 
5000.0 
50000.0 
500.0 
100.0 
no
###
###
###
# 300=Voltage kV
# 2.7=Spherical Aberration
# 0.07 #Relative amplitude contrast
# 512 #Size of spectrum (box size) in px
# 50.0 #Minimum resolution in target function in A
# 5.0 #Maximum resolution in target function in A
# 5000.0 #Lower bound of initial defocus search in A
# 60000.0 #Upper bound of initial defocus search in A
# 500.0 #Step size of initial search for defocus
# 100.0 #Astigmatism restraint
# no # Apply phase shift?
###
###
###
