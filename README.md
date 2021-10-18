## Automated fiducial-based tilt-series alignment for RELION4 in Dynamo

This is based on [autoalign4warp by Alister Burt](https://github.com/alisterburt/autoalign_dynamo)

#### Workflow from raw data to aligned tilt-series

#### Motivation

Yes please.

#### Outline

#### Particle picking in Dynamo?

#### Installation
#### Requirements
- Dynamo (1.1.478 or later) activated in MATLAB
- IMOD (VERSION)
- MATLAB (R2019a or later)
- Python (3.0 or later)

#### Download and install

#### Activation and Running

default mode XYZXYZYXYZYXYZYXYZ

fast_mode is the 'standard' version of the Dynamo automated TSA. It will run faster than the default version of this package (~10-15 minutes per tilt-series). However, you will get a larger average residual movement per fiducial marker (i.e. the TSA is will be less well-aligned).

Whether the average residual movement per fiducial marker matters or not to you depends on the resolution you hope to achieve. For high(er)-resolution work (10A or less), we recommend the default version. For lower resolution work, fast_mode may be suitable.

***ESSENTIAL INFORMATION, READ BEFORE STARTING***

It is essential to check the quality of the TSA by examining the markers picked by Dynamo TSA at the end of the process. XZYXYZYXYZXYZYXYZYXZYXZ

