%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % % This algorithm applies 2D image segmentation and convolution to locate
% % % and isolate the dark circles (fibres) from the picture. There are four
% % % parameters that usually regulate the accuracy and precision of the
% % % analysis: Area_filter is used to filter out the small vesicles that are
% % % not part of the fibre; windowSize denotes to the kernal size (e.g. 3*3
% % % rectangle) for image convolution; neighbor_num specifies the number of
% % % neighbors you would like to choose for determinging the distance of
% % % separate fibers nearby. Please refer to the excel file to find the
% % % optimized parameters for each condition. The purpose of not using
% % % consistant variables is to maximize the number of fibers (>90%) that
% % % could be measured.
% % % 
% % % The output consist of three pieces: average of distance between fiber
% % % centers; average cross-sectional area of fibers; average distance
% % % between fibers from edge to edge

clearvars; close all; warning off

% Parameters
SensitivityValue = 0.9; % range from 0.9-1
Area_filter_1 = 10;
Area_filter_2 = 100; % range from 50-200
windowSize = 3;
neighbor_num = 6;

% File Loading
cell_file = uigetfile('*.tif','Select Actin Images')
I = imread(cell_file);
imshow(I)

BW = imbinarize(I,'adaptive','sensitivity',SensitivityValue);
BW_com = imcomplement(BW);
figure()
imshow(BW_com)

% extra part
BW_remove = bwareaopen(BW_com,Area_filter_1);
figure()
imshow(BW_remove)

kernel = ones(windowSize)/windowSize^2;
blurredImage = conv2(double(BW_remove), kernel, 'same');
figure()
imshow(blurredImage)

BW_remove_1 = bwareaopen(blurredImage,Area_filter_2);
imedge = edge(logical(BW_remove_1),'canny');
imedge = imclose(imedge,strel('square',4));
figure()
imshow(imedge)

implane = imfill(imedge,'holes');
figure()
imshow(implane)

BW_remove_2 = bwareaopen(implane,Area_filter_2);
% BW_remove_2 = bwareaopen(logical(blurredImage),Area_filter_2);

imLabel = bwlabel(BW_remove_2);
stats = regionprops(imLabel,'all');
figure()
imshow(BW_remove_2)
hold on

index = [1:size(stats)];
centers = [];
for i = 1:size(stats,1)
    centers = cat(1,centers,stats(i).Centroid);
    if stats(i).Solidity < 0.6 || stats(i).Area < 10
        plot(stats(i).Centroid(1),stats(i).Centroid(2),'r*');
        hold on
        index(i)=0;
        centers(end,:)=[];
    end
end
hold off

index = nonzeros(index);
implane_2=ismember(imLabel,index);
figure()
imshow(implane_2)
stats_2 = regionprops(implane_2,'FilledArea');

for i=1:size(centers,1)
    centers_temp = centers;
    centers_temp(i,:) = [];
    Idx = knnsearch(centers_temp,centers(i,:),'K',neighbor_num);
    for j=1:size(Idx,2)
        center_dist_temp(j) = norm(centers(i,:)-centers_temp(Idx(j),:));
    end
    center_dist(i) = mean(center_dist_temp);
end

% Data output
average_centered_distance = mean(center_dist);
average_hole_area = mean([stats_2.FilledArea]);
boundary_distance = average_centered_distance-sqrt(average_hole_area)/pi*2;
output = [];
output(1,1) = average_centered_distance;
output(1,2) = average_hole_area;
output(1,3) = boundary_distance;

imwrite(implane_2,[cell_file(1:end-4) '_filter.jpg'])