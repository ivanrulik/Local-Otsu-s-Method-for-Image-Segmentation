%% Local Otsu's method for image segmentation
% By: Ivan Rulik 
% Term: Fall 2021
% Date: 12/09/21
%% Preparation
% Otsu's method is a top/bottom Edge-based Global Thresholding
clear,clc;
try
Img=double((imread(uigetfile("*.pgm")))); % import input image
catch
    exit
end
%% Otsu's Global
[kOpt1,sep_meas1, ImgGOtsu1] = gOtsu(Img);
%% Otsu's Local
[kOpt_lotsu1,sep_meas_lotsu1, ImgLOtsu1] = lOtsu(Img);
%% Present Results
figure(1)
imshow(cast(ImgGOtsu1,"uint8"));
title("Otsu's Global Segmentation, k* = "+ kOpt1 + ", \eta(k*) = "+sep_meas1);
figure(2)
imshow(cast(ImgLOtsu1,"uint8"));
% title("Otsu's Local Segmentation");
figure(3)
subplot(3,1,1), imshow(cast(Img,"uint8")),title("Original Image");
subplot(3,1,2), imshow(cast(ImgGOtsu1,"uint8")),title("Otsu's Global Segmentation");
subplot(3,1,3), imshow(cast(ImgLOtsu1,"uint8")),title("Otsu's Local Segmentation");
%% Functions
% Histogram
function histOut = getImgHist(Img)
[Img_M, Img_N] = size(Img); % get image dimetions
histOut=[0:255;zeros(1,256)];   % output var with intensity & counts/pixel
for j = 1: Img_N
    for i = 1:Img_M
        idx=Img(i,j);
        histOut(2,idx+1)=histOut(2,idx+1)+1;
    end
end
end
% Global Otsu
function [kOpt,sep_meas, ImgGOtsu] = gOtsu(Img)
[Img_M, Img_N] = size(Img); % get image dimentions
testHist = getImgHist(Img); % Array with input image histogram
imgProb = testHist(2,:)./(Img_M*Img_N); % Probability density of the hist.
MG = sum((0:255).*imgProb(1:256));  % gloal mean of intensity values
G_Var =sum((((0:255)-MG.*ones(1,256)).^2).*imgProb);   % global variance
kOpt=0; % variable to store the optimal threshold value to maximize var
MAX_B_C_Var=0;  % temporal var to store maximum variance
for k = 0:255   % loop to evaluate each k valure
P1 = sum(imgProb(1:k));   % probability of codition 1 intensity < k
P2 = sum(imgProb(k+1:255));    % probability of codition 2 intensity > kM1 = 1/P1*sum((0:k-1).*imgProb(1:k)); % mean intensity of condition 1
Mk = sum((0:k-1).*imgProb(1:k)); % mean intensity of condition 2
B_C_Var=(MG*P1-Mk)^2/(P1*(1-P1));  % between-class variance
if(B_C_Var > MAX_B_C_Var)   % evaluate between-class variance to find kOpt
    MAX_B_C_Var = B_C_Var;
    kOpt = k;
end
end
sep_meas=MAX_B_C_Var/G_Var; % separability measure
ImgGOtsu=(Img>=kOpt).*255;  % output image with Outsu's Global segmentation
end
% Local Otsu
function [kOpt_lotsu,sep_meas_lotsu, ImgLOtsu] = lOtsu(Img)
% [1,2,3;
%  4,5,6] 
[Img_M, Img_N] = size(Img); % get image dimentions
div_M=round(Img_M/2);   % get size of the local images to apply Otsu
div_N=round(Img_N/3);   % get size of the local images to apply Otsu
IMG{1}=Img(1:div_M,1:div_N);    % divide original Image into 6
IMG{2}=Img(1:div_M,div_N+1:2*div_N);    % divide original Image into 6
IMG{3}=Img(1:div_M,2*div_N+1:Img_N);    % divide original Image into 6
IMG{4}=Img(div_M+1:Img_M,1:div_N);  % divide original Image into 6
IMG{5}=Img(div_M+1:Img_M,div_N+1:2*div_N);  % divide original Image into 6
IMG{6}=Img(div_M+1:Img_M,2*div_N+1:Img_N);  % divide original Image into 6
kOpt_lotsu = zeros(1,6);    % pre alocate variables with local kOpt
sep_meas_lotsu = zeros(1,6);    % pre alocate variables with local sep. meas.
for i =1:6  % perform Otsu's segmentation in each local image and store
    [kOpt_lotsu(i),sep_meas_lotsu(i), IMGOut{i}] = gOtsu(IMG{i});
end
ImgLOtsu = [IMGOut{1},IMGOut{2},IMGOut{3};
            IMGOut{4},IMGOut{5},IMGOut{6}]; % re-asemble Otsu's output image
end