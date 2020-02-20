# Sarcomeric-deficits-underlie-MYBPC1-associated-myopathy-with-myogenic-tremor

This algorithm applies 2D image segmentation and convolution to locate
and isolate the dark circles (fibres) from the picture. There are four
parameters that usually regulate the accuracy and precision of the
analysis: Area_filter is used to filter out the small vesicles that are
not part of the fibre; windowSize denotes to the kernal size (e.g. 3*3
rectangle) for image convolution; neighbor_num specifies the number of
neighbors you would like to choose for determinging the distance of
separate fibers nearby. Please refer to the excel file to find the
optimized parameters for each condition. The purpose of not using
consistant variables is to maximize the number of fibers (>90%) that
could be measured.

The output consist of three pieces: average of distance between fiber
centers; average cross-sectional area of fibers; average distance
between fibers from edge to edge

Author: Runchen Zhao
