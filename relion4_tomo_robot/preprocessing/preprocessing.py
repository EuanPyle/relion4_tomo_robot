#!/usr/bin/env python

# Raw image naming convention should follow rules: NAME_TSNUMBER_TILTNUMBER_anythingyouwant.mrc or tiff. Your tilt series must start at 0 degrees and be collected in a dose-symmetric scheme

import argparse, os, sys, glob
from os.path import exists
from newstack import newstack

#Defines the program inputs
parser=argparse.ArgumentParser(
    description='''This preprocessing script for tomography is designed for use at Birkbeck College. It may work outside of Birkbeck, but the scripts may require editing.''')

#Optional arguments
parser.add_argument('-r', "--gain_ref", help='Indicate the gain reference file')
parser.add_argument('-tiff', '--tiff_ext', help='Tells MotionCor2 your raw data is in tiff format',action="store_true")
parser.add_argument('-gf', "--gain_flip", help='Sets the -FlipGain setting in MotionCor2. Default = 0. See MotionCor2 -h; and/or consult the microscope operator for details')
parser.add_argument('-gr', "--gain_rot", help='Sets the -RotGain setting in MotionCor2. Default = 0. See MotionCor2 -h; and/or consult the microscope operator for details')
parser.add_argument('-is', "--ignore_stack", help='Skips stacking all the images together, use if your data was not collected in a dose-symmetric tilt scheme, or if your tilt scheme does not start at 0 degrees', action="store_true")
parser.add_argument('-ti', "--tilt_increment", type=int, help='Enter the smallest tilt increment in the tilt series in degrees')
parser.add_argument('-f', "--flip", type=int, help='Indicate the gain reference file')
parser.add_argument('-s', "--super_res", help='Indicates your data was collected in Super Resolution mode as opposed to Counting mode', action="store_true")

args=parser.parse_args()

### ### ###

#Check Python version
if sys.version_info[0] < 3:
    print("Must use Python 3. For BBK users: module load anaconda/v4.8.4")
    sys.exit()

#Test IMOD and MotionCor are loaded
print('Testing IMOD is loaded')
imod_test = os.popen('dm2mrc').read()
if imod_test == '':
    print('Can\'t find dm2mrc, try loading imod outside of this script first. Birkbeck users type: module load imod')
    sys.exit()

print('Testing MotionCor2 is loaded')
mc_test = os.popen('MotionCor2').read()
if mc_test == '':
    print('Can\'t find MotionCor2, try loading MotionCor2 outside of this script first. Birkbeck users type: module load motioncor2/v1.0.5, or if raw files are .tiff, type: module load motioncor2/v1.1.0. If this still doesn\'t work, check you are on the staging server (ssh -X staging)')
    sys.exit()
    
#Warning if tiff files are present but flag was not used
if not(args.tiff_ext) and len(glob.glob('*.tiff')) > 0:
    print('WARNING: .tiff files are detected but you have not used the -tiff flag when running the script. MotionCor will not work for raw.tiff files if you do not use this flag.') 
    answer = input('Do you want to continue? (y/n): ')
    if not(answer == 'y' or answer == 'Y' or answer == 'y ' or answer == 'Y '):
        sys.exit()
	
#Bail if tilt increment or flip was not specified
if not(args.ignore_stack):
    if not(args.tilt_increment):
        print('WARNING: no tilt increment has been specified, which will cause an error when stacking images together. Use -ti [tilt increment] when starting the program. If you only want to motion correct and skip stacking, use the -is flag when starting the program. Type -h for more information')
        sys.exit()
    elif not(args.flip):
        print('WARNING: no dose symmetric flip has been specified, which will cause an error when stacking images together. Use -f [number of images before dose-symmetric scheme flips sign] when starting the program. If you only want to motion correct and skip stacking, use the -is flag when starting the program. Type -h for more information')
        sys.exit()
        sys.exit()

#Warning if no gain reference is specified
if not(args.gain_ref):
    print('WARNING: no gain reference has been specified for motion correction. Provide gain reference using -r [gain_reference_name] when starting the program')
    answer = input('Do you want to continue? (y/n): ')
    if not(answer == 'y' or answer == 'Y' or answer == 'y ' or answer == 'Y '):
        sys.exit()

#Checks reference is in dm4 or mrc
if args.gain_ref and args.gain_ref[-3:] == 'dm4':
    dm4 = True
else:
    dm4 = False
    
#Convert dm4 to mrc
if dm4:
    os.system('dm2mrc ' + args.gain_ref +' SuperRef.mrc')
    
    #Check dm2mrc was sucessful
    if not(exists('SuperRef.mrc')):
        print("Can't detect SuperRef.mrc, stopping. Is dm2mrc (IMOD) working?")
        sys.exit()

#Check naming conventions gives at least 3 files
if not(args.tiff_ext):
    if len(glob.glob('*_*_*_*.mrc')) <= 2:
        print('Can only find 2 or fewer mrc image files to pre-process, are you sure you have your naming convention correct? Try: [Name]_[tilt_series_number]_[tilt_number]_[angle].mrc; e.g. EP_100_001_3deg.mrc')
        little_data = input('Continue? (y/n): ')
        if not(little_data == 'y' or little_data == 'Y' or little_data == 'y ' or little_data == 'Y '):
            sys.exit()

if args.tiff_ext:
    if len(glob.glob('*_*_*_*.tiff')) <= 2:
        print('Can only find 2 or fewer tiff image files to pre-process, are you sure you have your naming convention correct? Try: [Name]_[tilt_series_number]_[tilt_number]_[angle].tiff; e.g. EP_100_001_3deg.tiff')
        little_data = input('Continue? (y/n): ')
        if not(little_data == 'y' or little_data == 'Y' or little_data == 'y ' or little_data == 'Y '):
            sys.exit()
	    
#Create list of unique TSs
if not(args.tiff_ext):
    ts_list = list()
    for i in glob.glob('*_*_*_*.mrc'): 
        tomon = i.split('_')[1]
        ts_list.append(tomon)
    
    for i in glob.glob('TS_*'):
        if os.path.isdir(i):
            tomon = i.split('_')[1]
            ts_list.append(tomon)
    
    ts_list = set(ts_list)

if args.tiff_ext:
    ts_list = list()
    for i in glob.glob('*_*_*_*.tiff'): 
        tomon = i.split('_')[1]
        ts_list.append(tomon)
    
    for i in glob.glob('TS_*'):
        if os.path.isdir(i):
            tomon = i.split('_')[1]
            ts_list.append(tomon)
    
    ts_list = set(ts_list)


#Run MotionCor2, no dose compensation
if not(args.tiff_ext):
    motion_cor_list = glob.glob('*_*_*_*.mrc')
    motion_cor_list = [item for item in motion_cor_list if '_Sum.mrc' not in item]
        
    for i in motion_cor_list:
        
        out_mrc = i.replace('.mrc','_Sum.mrc')
        
        if exists(out_mrc):
            print('MotionCor2 already ran on this, skipping...')
            continue
        
        tomon = out_mrc.split('_')[1]
        
        if exists('TS_' + tomon + '/' + out_mrc):
            print('MotionCor2 already ran on this, skipping...')
            continue
        
        if not(args.gain_ref):
            os.system('MotionCor2 -inMrc ' + i + ' -outMrc ' + out_mrc + ' -Patch 0 0 -Iter 7 -Tol 0.5 -LogFile ' + i + '.log')
            continue
        
	#ID Gain Reference Rot and Flip
        if not(args.gain_rot):
            rot = '-RotGain 0 '
        else:
            rot = '-RotGain ' + args.gain_rot + ' '
        
        if not(args.gain_flip):
            flip = '-FlipGain 0 '
        else:
            flip = '-FlipGain ' + args.gain_flip + ' '
            
        if dm4:
            os.system('MotionCor2 -inMrc ' + i + ' -outMrc ' + out_mrc + ' -Gain SuperRef.mrc -Patch 0 0 -Iter 7 -Tol 0.5 ' + rot + flip + '-LogFile ' + i + '.log')
        else:
            os.system('MotionCor2 -inMrc ' + i + ' -outMrc ' + out_mrc + ' -Gain ' + args.gain_ref + ' -Patch 0 0 -Iter 7 -Tol 0.5 ' + rot + flip + '-LogFile ' + i + '.log')

if args.tiff_ext:
    motion_cor_list = glob.glob('*_*_*_*.tiff')
        
    for i in motion_cor_list:
        
        out_mrc = i.replace('.tiff','_Sum.mrc')
        
        if exists(out_mrc):
            print('MotionCor2 already ran on this, skipping...')
            continue
        
        tomon = out_mrc.split('_')[1]
        
        if exists('TS_' + tomon + '/' + out_mrc):
            print('MotionCor2 already ran on this, skipping...')
            continue
        
        if not(args.gain_ref):
            os.system('MotionCor2 -inTiff ' + i + ' -outTiff ' + out_mrc + ' -Patch 0 0 -Iter 7 -Tol 0.5 -LogFile ' + i + '.log')
            continue
	
        #ID Gain Reference Rot and Flip
        if not(args.gain_rot):
            rot = '-RotGain 0 '
        else:
            rot = '-RotGain ' + args.gain_rot + ' '
        
        if not(args.gain_flip):
            flip = '-FlipGain 0 '
        else:
            flip = '-FlipGain ' + args.gain_flip + ' '
            
        if dm4:
            os.system('MotionCor2 -inTiff ' + i + ' -outMrc ' + out_mrc + ' -Gain SuperRef.mrc -Patch 0 0 -Iter 7 -Tol 0.5 ' + rot + flip + '-LogFile ' + i + '.log')
        else:
            os.system('MotionCor2 -inTiff ' + i + ' -outMrc ' + out_mrc + ' -Gain ' + args.gain_ref + ' -Patch 0 0 -Iter 7 -Tol 0.5 ' + rot + flip + '-LogFile ' + i + '.log')

#Bails if MotionCor2 has not worked
if len(glob.glob('*_*_*_*_Sum.mrc')) == 0 and len(glob.glob('TS_*/*_*_*_*_Sum.mrc')) == 0 and args.tiff_ext:
    print('MotionCor2 has not worked as no _Sum.mrc files exist here, or in TS_ folders. As your input is .tiff files, please check you are using the correct version of MotionCor2. For .tiff files, you must use version 1.1.0 or above.') 
    sys.exit()
    
#Bails if data is not dose symmetric tilt scheme
if args.ignore_stack:
    print('Not placing images into an image stack as indicated by the user')
    sys.exit()

#Extract file naming convention
no_file_len = len(glob.glob('*_*_*_*_Sum.mrc'))
if no_file_len == 0:
    TS_dirs = glob.glob('TS_*')
    for i in TS_dirs:
        no_file_len = len(glob.glob(i + '/*_*_*_*_Sum.mrc'))
        ts_no = i
        if no_file_len > 0:
            break
        elif no_file_len == 0:
            print('Cannot find any _Sum.mrc files. Did motion correction run correctly? You should have *_Sum.mrc files output here, or in TS_* folders. If you do not, check your motioncor2 version >1.1.0 if using tiff files. If it is, and it still will not work, contact me')
    no_file_len = int(no_file_len/2)
    random_select = glob.glob(ts_no + '/*_*_*_*_Sum.mrc')[no_file_len]
    naming = (random_select.split('_')[1])
    naming = naming.split('/')[1]
else:
    no_file_len = int(no_file_len/2)
    random_select = glob.glob('*_*_*_*_Sum.mrc')[no_file_len]
    naming = (random_select.split('_')[0])

for tomon in ts_list:
    #Make directory for each TS
    if not(os.path.isdir('TS_' + tomon)):
        os.mkdir('TS_' + tomon)
    
    #Move correct images into TS directory
    for i in glob.glob('*_' + tomon + '_*_*_Sum.mrc'):
        os.rename(i,'TS_' + tomon + '/' + i)
    
    #Determine number of tilts in each TS
    ts_len = len(glob.glob('TS_' + tomon + '/*_Sum.mrc'))
    
    #Run newstack on this TS
    newstack(tomon,args.flip,args.tilt_increment,naming,ts_len)
    
#Bins from super resolution data
if args.super_res:
    for tomon in ts_list:			       
        os.system('newstack -bin 2 -InputFile TS_' + tomon + '/TS_' + tomon + '.st -OutputFile TS_' + tomon + '/TS_' + tomon + '_bin1.st') 
        
        #Deletes super resolution stack
        if exists('TS_' + tomon + '/TS_' + tomon + '_bin1.st') and exists('TS_' + tomon + '/TS_' + tomon + '.st'):
            os.remove('TS_' + tomon + '/TS_' + tomon + '.st')
            os.rename('TS_' + tomon + '/TS_' + tomon + '_bin1.st', 'TS_' + tomon + '/TS_' + tomon + '.st')

#Move Motion Corrected Images back into main directory
for tomon in ts_list:
    for i in glob.glob('TS_' + tomon + '/*_' + tomon + '_*_*_Sum.mrc'):
        os.rename(i,i.split('/')[1])

