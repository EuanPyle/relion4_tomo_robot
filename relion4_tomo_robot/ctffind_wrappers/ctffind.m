function ctffind(current_ts, apix, x_di, y_di, mask_size, ctffind_install);

tomo_name = split(current_ts,'/');
tomo_name = tomo_name{end};

%Find the tilts present and their numbers in the image stack
tilt_range_table=dread([current_ts '/' tomo_name '.tlt']); 

tilt_range_table(:,2)=1:length(tilt_range_table);

%Define image mask area
image_mask_size_percentage=mask_size./100;

if x_di > y_di
x_dim = x_di;
y_dim = y_di;
else
x_dim = y_di;
y_dim = x_di;
end

central_patch = round(y_dim.*image_mask_size_percentage);  

dimx = central_patch; 
dimxmin = round((x_dim./2)-(dimx/2)); 
dimxmax = round((x_dim./2)+(dimx/2)); 

%Rotates mask area so that it always fits over the same area throughout the tilt-series
windows = tilt_range_table(:,[1,2]); 

for w = 1:size(windows,1)
    angle = windows(w,1);
    dimy = cosd(angle)*central_patch;
    dimymin = round((y_dim./2)-(dimy/2)); 
    dimymax = round((y_dim./2)+(dimy/2)); 
    windows(w,3) = dimymin;
    windows(w,4) = dimymax;
end

disp(['Targeting ' tomo_name ' for cropping input to CTFFIND4...']);

% read tilt file generated for each new stack:
    
tiltsIndex = windows(:,2);
    
disp(['Calculating size of patch at each angle present:']);
    
cropped_stack=[];
cropped_stack_filt=[];

tomon_stack = dread([current_ts '/' tomo_name '.st']); 
    
for slices=1:size(tomon_stack,3)
        
        slice = tomon_stack(:,:,slices);
        index = tiltsIndex(slices,1);
        angle = windows(index,1)
        dimymin = windows(index,3);
        dimymax = windows(index,4);
        
        tilt_stats = dstd(slice);
        tilt_mean = tilt_stats(1).mean;
        tilt_std = tilt_stats(1).std;
        tilt_normd = ((slice(:,:) - tilt_mean)/tilt_std);
        
        %normalised to mean of zero and std of 1
        tilt_mean_filled = zeros(size(slice));
        tilt_mean_filled_stats = dstd(tilt_normd);
        tilt_mean = tilt_mean_filled_stats(1).mean;
        tilt_mean_filled(:,:) = tilt_mean;
    
        % append to cropped tilt series
        tilt_mean_filled(dimxmin:dimxmax,dimymin:dimymax)=tilt_normd(dimxmin:dimxmax,dimymin:dimymax);
   
        
        % apply filtering to smoothen edges
        filter_patch = zeros(size(slice));
        filter_patch(dimxmin:dimxmax,dimymin:dimymax)=1;
        filter_patch_gauss = imgaussfilt(filter_patch,5);
        tilt_mean_filled=tilt_mean_filled.*filter_patch_gauss;
        cropped_stack_filt =  cat(3,cropped_stack_filt,tilt_mean_filled);
        
end
disp('Writing CTFFIND input stack to CTFfind4In.mrc')
dwrite(cropped_stack_filt,[current_ts '/CTFFIND/CTFfind4In.mrc']);
    
% run CTFFIND4
disp('Running CTFFIND4...')
[status,result] = system(['./CTFFIND_settings.csh ' current_ts '/CTFFIND/CTFfind4In.mrc ' num2str(apix) ' ' ctffind_install]);

disp(['Finished for ' tomo_name]); 
    
end
