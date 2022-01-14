#!/usr/bin/env python

def newstack(TS_number,groups,increment,complete,ts_len,add_zero):
    
    import os, sys, glob       
    
    print("Newstack is stacking tilt series" + str(TS_number) + " with n_flip " + str(groups) + " and angular increment " + str(increment)) 
              
    #Generate tilt scheme
    if add_zero == True:
        tilts_dict = list()
        tilts_dict.append(0)
        count = 0   
        for i in range(2,ts_len,groups): 
            offset = i - (count * groups*2)
            for n in range(0,groups):
                tilts_dict.append(((offset + n) * increment) - increment)
            for n in range(0,groups):
                tilts_dict.append(-((offset + n) * increment))
    
        tilts_dict = tilts_dict[:ts_len-1]
        
    else:
        tilts_dict = list()
        count = 0   
        for i in range(1,ts_len,groups): 
            offset = i - (count * groups*2)
            for n in range(0,groups):
                tilts_dict.append(((offset + n) * increment) - increment)
            for n in range(0,groups):
                tilts_dict.append(-((offset + n) * increment))
    
        tilts_dict = tilts_dict[:ts_len]
        
    # Extract tilt image numbers and order them from low to high
    
    image_numbers = glob.glob('TS_' + TS_number + '/*_Sum.mrc')
    image_numbers_int = list()
    
    for i in range(0,len(image_numbers)):
        image_numbers_int.append(int(image_numbers[i].split('_')[3]))
        image_numbers[i] = image_numbers[i].split('_')[3]
    
    
    image_numbers_len = len(image_numbers[0])
    image_numbers_int = sorted(image_numbers_int)
            
    # For each TS number, match to the angle from tilts_dict in the same idx
    image_tilt_list = [image_numbers_int,tilts_dict]
    
    
    # Order angles from low to high with corresponding image number
    idx_sorting = sorted(range(len(image_tilt_list[1])), key=lambda k: image_tilt_list[1][k])
    sorted_tilts = sorted(image_tilt_list[1])
    count = 0
    
    # Create .rawtlt file
    with open("TS_%s/TS_%s.rawtlt" % (TS_number,TS_number), 'w') as rawtlt:
        for i in sorted_tilts:
            rawtlt.write(str(i) + '\n')
        rawtlt.close
        
    for i in image_tilt_list[0]:
        sorted_tilts[count] = image_tilt_list[0][idx_sorting[count]]
        count = count + 1
    
    count = 0 
    #Go from image number to image name numbers using zfill
    for i in sorted_tilts:
        num_length = len(str(i))
        if image_numbers_len - num_length == 0:
            sorted_tilts[count] = str(i)
            count = count + 1
        elif image_numbers_len - num_length < 0:
            print('Error, tilt number is greater than the original input')
            sys.exit()
        else:
            sorted_tilts[count] = str(i).zfill(image_numbers_len)  
            count = count + 1  
    
    with open("TS_%s/TS_%s.list" % (TS_number,TS_number), 'w') as file_list : # write mode
        file_list.write(str(ts_len) + '\n')
        for i in sorted_tilts:
            file_list.write(glob.glob('TS_' + TS_number + '/' + complete + '_' + TS_number + '_' + i + '*')[0] + '\n') 
            file_list.write('/' + '\n')
            file_list.close
    
    # Run IMODs newstack function
    try:
        os.system('newstack -verbose 1 -FileOfInputs TS_' + TS_number + '/TS_' + TS_number + '.list -OutputFile TS_' + TS_number + '/TS_' + TS_number + '.st \n')
    except:
        print('Error with newstack')
