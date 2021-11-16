#!/bin/csh -x

input = $1

set strip1 = `basename $1`

set strip=`echo $1 | sed 's/.mrc//'`
set suffix = "_output.mrc"
set DESTDIR = $strip$suffix

time $3 << eof #CTFFIND install location
$1 #Input
no
$DESTDIR #Output
$2 #Angstrom per pixel
###
### Parameters to change (start)
###
300.0 #Voltage kV
2.7 #Spherical aberration in mm
0.07 #Relative amplitude contrast
512 #Size of spectrum (box size) in px
50.0 #Minimum resolution in target function in A
5.0 #Maximum resolution in target function in A
5000.0 #Lower bound of initial defocus search in A
50000.0 #Upper bound of initial defocus search in A
500.0 #Step size of initial search for defocus
100.0 #Astigmatism restraint
###
### Parameters to change (end)
###
no
eof

