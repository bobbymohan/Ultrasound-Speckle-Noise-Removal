clc;
clear all;
close all;

%getting an input image 

[fname , path]=uigetfile('.jpg', 'Select an Ultrasound Image');
fname=strcat(path,fname);
I=imread(fname);
% I=rgb2gray(I);
figure, 
imshow(I);
title('Input Ultrasound Image');

%anisotropic diffusion filtering

J1=imdiffusefilt(I,'NumberOfIteration',10,'Connectivity','maximal','ConductionMethod','exponential');
figure,imshow(J1);
title('Anisotropic Diffusion Filtered Image');

%two level 2D wavelet transform

[p,q,r,s]=dwt2(J1,'haar');
[p1,p2,p3,p4]=dwt2(p,'haar');
y=[uint8(p1), uint8(p2);uint8(p3),uint8(p4)];

figure, imshow(y);
title('Two level 2D Wavelet Transformed Images');

%processing decomposed images

%approx-p1
y1=imguidedfilter(p1);
figure, imshow(y1);
title('Processed Approx Image');

%vertical-p2
y2=imbinarize(p2);
figure, imshow(y2);
title('Processed Vertical Image');

%horizontal-p3
y3=imbinarize(p3);
figure, imshow(y3);
title('Processed Horizontal Image');

%diagonal-p4
y4=imguidedfilter(p4);
figure, imshow(y4);
title('Processed Diagonal Image');

%reconstruction

x=idwt2(y1,y2,y3,y4,'haar');

%exponential transform

x1=im2double(x);
E=exp(x1);
expT=(E/max(E(:)))*255;

I4 = FrostFilter(J1,getnhood(strel('disk',5,0)));

sharpcoeff = [ 0 0 0; 0 1 0; 0 0 0];
I5 = imfilter(I4,sharpcoeff,'symmetric');
figure, 
imshow(I5);
title('Denoised Image');

%performance verification

peaksnr=psnr(I5,I);
meansqerror=immse(I5,I);
ssimval=ssim(I5,I);