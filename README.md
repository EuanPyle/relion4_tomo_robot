## Automated Workflow From Tilt Series to Reconstructed Tomograms for RELION 4.0 

#### Motivation

This package takes you all the way from an image stack and a rawtlt file to tomograms reconstructed by RELION in a semi-automated (honest!) manner. This pipeline is designed for datasets where you have lots of tomograms (with fiducial markers) and you want to perform subtomogram averaging to a high resolution.

#### Outline

First, we use **dautoalign4relion** (partially based on [autoalign4warp by Alister Burt](https://github.com/alisterburt/autoalign_dynamo)) to carry out automated TSA. We have made significant modifications to the Dynamo TSA scripts which reduce the residual motion of the fiducial markers to a minimum. Annecdotally, we have found that this function performs TSA as well as carefully manually picking gold beads in IMOD but in far less time.

Then we use **generate_com** to create the newst.com and tilt.com files required by RELION 4.

We then use **generate_tilt_order** to tell RELION the order in which the tilt scheme was collected in (e.g. bidirectional or dose symmetric).

We then estimate the CTF of the stacks by running **import_ctf** then using a CTFFIND4 wrapper called **ctffind_wrapper**.

We then generate a tomograms_descr.star using **generate_tomograms_descr**.

#### You can now import into [RELION](https://relion.readthedocs.io/en/release-4.0/STA_tutorial/ImportTomo.html)! 

We have integrated a wrapper of RELION's [relion_tomo_reconstruct_tomogram](https://relion.readthedocs.io/en/release-4.0/Reference/STA/Programs/reconstruct_tomogram.html#program-tomo-reconstruct-tomogram) function called **generate_tomograms** to generate tomograms. 

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

default mode XYZXYZYXYZYXYZYXYZ

fast_mode is the 'standard' version of the Dynamo automated TSA. It will run faster than the default version of this package (~10-15 minutes per tilt-series). However, you will get a larger average residual movement per fiducial marker (i.e. the TSA is will be less well-aligned).

Whether the average residual movement per fiducial marker matters or not to you depends on the resolution you hope to achieve. For high(er)-resolution work (10A or less), we recommend the default version. For lower resolution work, fast_mode may be suitable.


dautoalign4relion takes approx. 45 minutes to 1 hour per tomogram. If this is too slow for you, we have included a 'fast mode' which takes ~15 minutes per tomogram but will give you higher residual motion of the fiducial markers (i.e. the TSA will be less accurate). dautoalign4relion will output IMOD metadata from the TSA. 

RELION 4 also requires a csv file for each tilt series describing the order in which the images were taken. If you have collected your data using a dose-symmetric or bidirectional tilt scheme, you can use generate_tilt_order for each of these files. For other tilt series aquistions schemes, it won't be too hard to generate these yourself, or just contact me and I might add them.

RELION 4 also requires CTF estimation for each tilt series. We have included a wrapper (import_ctffind and ctffind_wrapper) for CTFFIND to generate CTF estimations for each tilt series with image masked, if desired.
