# Workflow to prep data for M
1. Follow the  <a href="http://www.warpem.com/warp/?page_id=378">Warp user guide</a> to take you from frames to tilt-series
2. Navigate to the 'imod' directory warp created and run 
`dautoalign4warp`
3. Import the results into warp and generate your tomograms!

`dautoalign4warp` is a function for...
- Automated fiducial detection and recentering based on 2D average of bead across tilt series using Dynamo
 <p align="center">    
     <img src="dynamo_markers.png"
          alt="Automatically detected fiducial markers"
          width=40%
          height=40%
          />
</p>
- Creation of an IMOD model from these bead positions
- Tilt series alignment using the IMOD program tiltalign (fixed tilt angles, solve for one rotation angle)
- Preparation of all results for easy import back into Warp


Do you want to use the <a href="https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Model">geometrical tools</a> in Dynamo to pick particles, imparting prior knowledge about your particle orientation to further subtomogram averaging?

 <p align="center">    
     <img src="filaments.png"
          alt="Filament models with different geometries"
          />
</p>

If so, you may want to use the `warp2catalogue` script to quickly set up a <a href="https://wiki.dynamo.biozentrum.unibas.ch/w/index.php/Catalogue">catalogue</a> of your data, correctly linked for visualisation of Warp's deconvolved tomograms with cropping directly from the 3d-CTF corrected tomogram from warp


## Installation
### Requirements
Dynamo 1.1.478 or later, activated in MATLAB
IMOD (tested on 4.10.35)

### Clone repository
Download this repository or run
`git clone https://github.com/alisterburt/autoalign_dynamo.git` from the command line in the install location

### Add necessary files to PATH
Add the install location to your PATH variable in MATLAB
```
PATH = getenv('PATH');
setenv('PATH', [PATH ':/path/to/installation/location'])
```

### Running
1. Make sure Dynamo is activated in MATLAB (`dynamo_activate`)
2. Navigate to the `imod` directory created by Warp when you exported tilt-series as stacks for IMOD
3. run `dautoalign4warp(<pixel_size_angstrom>, <fiducial_diameter_nm>, <nominal_rotation_angle>, <output_folder>)`

This will align your tilt-series and tidy everything up ready for import back into Warp.

Enjoy!
