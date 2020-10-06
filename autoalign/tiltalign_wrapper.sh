#!/bin/bash
USAGE="""
Wrapper function for calling tiltalign...

\n\e[7mtiltalign_wrapper.sh\e[0m <\e[36mmodel_file\e[0m> <\e[36mtilt_angle_file\e[0m> <\e[36mrotation_angle\e[0m> <\e[36munbinned_pixel_size_nm\e[0m> <\e[36moutput_tilt_angle_file\e[0m> <\e[36moutput_transform_file\e[0m>
"""




if [ -z "$1" ]
then
	echo -e $USAGE
	exit 0
else
	MODEL_FILE=$1
	TILT_ANGLE_FILE=$2
	ROTATION_ANGLE=$3
	UNBINNED_PIXEL_SIZE=$4
	OUTPUT_TILT_ANGLE_FILE=$5
	OUTPUT_XF_FILE=$6
fi


tiltalign -ModelFile $MODEL_FILE \
-ImagesAreBinned	1 \
-OutputModelFile	3d_fiducial_model.3dmod \
-OutputResidualFile	residual_model.resid \
-OutputFidXYZFile	fiducials.xyz \
-OutputTiltFile	$OUTPUT_TILT_ANGLE_FILE \
-OutputXAxisTiltFile	xtiltfile.xtilt \
-OutputTransformFile	$OUTPUT_XF_FILE \
-OutputFilledInModel model_nogaps.fid \
-RotationAngle	$ROTATION_ANGLE \
-UnbinnedPixelSize	$UNBINNED_PIXEL_SIZE \
-TiltFile	$TILT_ANGLE_FILE \
-AngleOffset	0.0 \
-RotOption	-1 \
-RotDefaultGrouping	5 \
-TiltOption	0 \
-TiltDefaultGrouping	5 \
-MagReferenceView	1 \
-MagOption	0 \
-MagDefaultGrouping	4 \
-XStretchOption	0 \
-SkewOption	0 \
-XStretchDefaultGrouping	7 \
-SkewDefaultGrouping	11 \
-BeamTiltOption	0 \
-XTiltOption	0 \
-XTiltDefaultGrouping	2000 \
-ResidualReportCriterion	0.5 \
-SurfacesToAnalyze	1 \
-MetroFactor	0.25 \
-MaximumCycles	1000 \
-KFactorScaling	1.0 \
-NoSeparateTiltGroups	1 \
-AxisZShift	0.0 \
-ShiftZFromOriginal      1 \
-TargetPatchSizeXandY	700,700 \
-MinSizeOrOverlapXandY	0.5,0.5 \
-MinFidsTotalAndEachSurface	8,3 \
-FixXYZCoordinates	0 \
-LocalOutputOptions	1,0,1 \
-LocalRotOption	3 \
-LocalRotDefaultGrouping	6 \
-LocalTiltOption	5 \
-LocalTiltDefaultGrouping	6 \
-LocalMagReferenceView	1 \
-LocalMagOption	3 \
-LocalMagDefaultGrouping	7 \
-LocalXStretchOption	0 \
-LocalXStretchDefaultGrouping	7 \
-LocalSkewOption	0 \
-LocalSkewDefaultGrouping	11 \
-RobustFitting \
> tiltalign.stdout

get_tasolution.py tiltalign.stdout


