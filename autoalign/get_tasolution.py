#!/usr/bin/env python
import sys

if len(sys.argv) == 1:
	print('provide filename as argument')
else:
	filename = sys.argv[1]
	

def check_line(line, printing):
	start_cue = 'At minimum tilt, rotation angle is'
	end_cue = '3-D point coordinates (with centroid zero)'
	
	if start_cue in line:
		printing = True
	elif end_cue in line:
		printing = False
	
	return printing
	

with open(filename) as f:
	lines_to_keep = []
	printing = False
	lines = f.readlines()
	for line in lines:
		printing = check_line(line, printing)
		if printing:
			lines_to_keep.append(line)

with open('taSolution.log', 'w') as f:
	f.writelines(lines_to_keep)
	
print('saved taSolution.log')
 
