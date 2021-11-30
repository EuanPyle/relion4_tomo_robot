## Automated Workflow to Pre-Process Raw Tomography Data for RELION 4.0 

#### Outline

This package contains functions to automate the processing of raw images from the microscope, all the way to tilt series import and tomograms reconstruction in RELION with a few single line commands using Matlab/Dynamo and Python. 

We have also modified the automated tilt series alignment (TSA) in Dynamo to give much more accurate alignments, reducing the residual motion of fiducial markers to a minimum. Annecdotally, we have found that this function performs TSA as well as carefully manually picking gold beads in IMOD but with considerably less user effort!

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
- Dynamo (tested on v1.1.509) activated in MATLAB
- IMOD (tested on v4.9.0)
- MATLAB (tested on R2020b)
- Python (3.0 or later)
- CTFFIND4 (tested on v4.0.17)
- MotionCor2 (tested on v1.0.5, but >=v1.1.0 should be used if your raw images are .tiff)

#### Download, Activation and Running

A detailed guide on how to use this workflow is given [here](https://docs.google.com/document/d/e/2PACX-1vRmhGvRXRI5WlwpLLzwEkYEW1kWUzTOEUkk5CseWsPaGh8ExvXNqdFvc-2RX3LRD6inVJFoEZUas30_/pub). 

In brief:

```bash
git clone https://github.com/EuanPyle/relion4_tomo_robot.git
cd relion4_tomo_robot
./install.sh
```

This requires git, which can be installed by your package manager if not already present in your system, for example...
```bash
sudo apt-get install git
```

You will be asked where you would like to install the package, the default location is...
```bash
/opt/relion4_tomo_robot
```

If not already, activate/load IMOD, Python 3, and MotionCor2. 

In Matlab, activate Dynamo with dynamo_activate. Activate the tomo_robot with run /path/to/install/relion_robot.m

To see the required/optional inputs for each function:

help [function]

The available functions, in the order they should be used, are: **dautoalign4relion**, **generate_metadata**, **import_ctf**, **ctffind_wrapper**, and after importing tomograms into RELION, **reconstruct_tomo_wrapper**.
