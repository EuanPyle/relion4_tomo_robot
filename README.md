## Automated Workflow to Pre-Process Raw Tomography Data for RELION 4.0 

#### Outline

This package contains functions to automate the processing of raw images from the microscope, all the way to tilt series import and tomograms reconstruction in RELION with a few single line commands using Matlab/Dynamo and Python. 

We have also modified the automated tilt series alignment (TSA) in Dynamo to give much more accurate alignments, reducing the residual motion of fiducial markers to a minimum. Annecdotally, we have found that this function performs TSA as well as carefully manually picking gold beads in IMOD but in far less time.

Currently, the data requirements are that your data is recorded in a dose-symetric tilt scheme starting at 0 degrees, that your data contains fiducial markers, that your raw data follows a common naming convention, and that the raw data are in the .mrc or .tiff file formats. These requirements are subject to change based on user demand.

#### Functions Provided:

First, we use **dautoalign4relion** (partially based on [autoalign4warp by Alister Burt](https://github.com/alisterburt/autoalign_dynamo)) to carry out automated TSA. 

Then we use **generate_metadata** to create the necessary metadata required by RELION 4.

We then estimate the CTF of the stacks by running **import_ctf** then using a CTFFIND4 wrapper called **ctffind_wrapper**.

#### You can now import into [RELION](https://relion.readthedocs.io/en/release-4.0/STA_tutorial/ImportTomo.html)! 

We have integrated a wrapper of RELION's [relion_tomo_reconstruct_tomogram](https://relion.readthedocs.io/en/release-4.0/Reference/STA/Programs/reconstruct_tomogram.html#program-tomo-reconstruct-tomogram) function called **reconstruct_tomo_wrapper** to generate tomograms. 

#### Now you can start picking particles! 

If you use Dynamo to pick particles, you can **convert the Dynamo table to a coordinates star file** using [this package](https://github.com/EuanPyle/dynamo2relion).

#### Installation
#### Requirements
- Dynamo (1.1.478 or later) activated in MATLAB
- IMOD
- MATLAB (R2019a or later)
- Python (3.0 or later)
- CTFFIND4

#### Download and install

#### Activation and Running
