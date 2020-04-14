close all 
clear all
clc
matlab_folder = pwd;

main_folder = uigetdir();
cd(main_folder);
files = dir('*ZP38*');

for  i = 1:size(files,1)
tic
    [~,shortfile] = fileparts(files(i).name);
display(['Generating .stl file for ' shortfile])
org_image_dir = strcat(main_folder,'\',shortfile);
cd(org_image_dir)

dir_post_processing_img = strcat(org_image_dir,'\','Post processing images');
dir_stl_files = strcat(org_image_dir,'\','Stl files');
    
    if exist( dir_stl_files, 'dir')~=7
        mkdir(dir_stl_files);
    end

    
    
scale_factor = 1;
file_name = strcat(shortfile,'_1_.stl');
cd(dir_post_processing_img)
name = strcat(shortfile,'_post_processed_vessels.tif');
vess_bin = imreadfast(name);

closed_image = vess_bin>0;
img = vess_bin>0;


image_dilate = dilation(img,4,'elliptic');
image_erosion = erosion(image_dilate,3,'elliptic');



       labeled_image = label(image_erosion, 2, 100000,0);
       region_stats = regionprops3(uint16(labeled_image),'Volume');
       allVol = [region_stats.Volume];
      [sortedAreas, sortIndexes] = sort(allVol, 'descend');
      
      label_largest_region = sortIndexes(1);
        
        label_regionone = labeled_image==label_largest_region;
        fill_label_region = fillholes(label_regionone);
        
        image_downsize = imresize3(uint8(fill_label_region),scale_factor);
        
        gridDATA = double(image_downsize>0);
        gridX = [0:1:(size(image_downsize,1)-1)];
        gridY = [0:1:(size(image_downsize,2)-1)];
        gridZ = [0:1:(size(image_downsize,3)-1)];

cd(dir_stl_files)        
[~,~] = CONVERT_voxels_to_stl(file_name,gridDATA,gridX,gridY,gridZ,'binary');

bin_file_name = strcat(shortfile,'_bin_vess_network_BIN_MESH_crop.tif');
bin_file_downsize_name = strcat(shortfile,'_bin_vess_network_downsized_BIN_MESH_crop.tif');

fill_label_region = uint8(fill_label_region);
image_downsize = uint8(image_downsize);

num_slices = size(fill_label_region,3);
num_slices_2 = size(image_downsize,3);

imwrite(uint8(fill_label_region(:,:,1)),bin_file_name);
        
   for p = 2:num_slices
            imwrite(uint8(fill_label_region(:,:,p)),bin_file_name, 'WriteMode','append');
   end

imwrite(uint8(image_downsize(:,:,1)),bin_file_downsize_name);
        
   for p = 2:num_slices_2
            imwrite(uint8(image_downsize(:,:,p)),bin_file_downsize_name, 'WriteMode','append');
   end   

toc        
end
        
        
        