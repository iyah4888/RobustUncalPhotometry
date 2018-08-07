clear all;
close all; clf; addpath(genpath('Solver'));

%% Definition
IMGPATH = '../Photometry_sample/cap3'
IMGSCALE = 1.0/10.0;%
RPCA_METHOD = {'TNN_RPCA', 'EB_RPCA_1Side'}; % 


fn_path = @(x) fullfile(IMGPATH, x);
imgread = @(x) imresize(im2double(imread(x)), IMGSCALE);
COLORCH = 2;

APARA = fn_config_para('target_rank', 3);



%% Code

flist = dir(fn_path("*.jpg"));

img_back = imgread(fn_path(flist(1).name));
% img_back = imgread('IMG_0008.JPG');
imsz = size(img_back);
% fformat = 'IMG_%04d.JPG';

%% Data loading, form 2D matrix
cell_imgs = {};
% seq_img = 9:16;
seq_img = 1:size(flist,1);
imgmat = zeros(imsz(1)*imsz(2), length(seq_img));
maxv_arr = [];
disp('Loading images...')
for i = 1:length(seq_img)
    % curfname = sprintf(fformat, seq_img(i));
    curfname = fn_path(flist(i).name);
    % cell_imgs{i} = imgread(curfname) - img_back;
    cell_imgs{i} = imgread(curfname);

    labimg = rgb2lab(cell_imgs{i})./100;
    chroimg = bsxfun(@rdivide, cell_imgs{i}, labimg(:,:,1)+eps);
    
    grayimg = cell_imgs{i}(:,:,COLORCH)./chroimg(:,:,COLORCH);
    maxv_arr(i) = max(grayimg(:));
    imgmat(:, i) = grayimg(:);
end

% imgmat = bsxfun(@rdivide, imgmat, maxv_arr);
imgmat = imgmat./max(maxv_arr);
imgmat = bsxfun(@minus, imgmat, mean(imgmat, 2));



%% Robust uncalibrated pseudo photometric stereo
[L, E] = feval(RPCA_METHOD{1}, imgmat', APARA);
imgmat = L';

%% SVD
SVDmode = 1;
if SVDmode == 1
    %% SVD
    [u, d, ~] = svd(imgmat, 'econ');
    % 
    pnormal = u(:,1:3)*diag(1./sqrt(diag(d(1:3,1:3))));
%     pnormal = u(:,1:3);
else
    %% Randomized SVD
    proj = imgmat*randn(size(imgmat, 2), 10);
    [Q,R] = qr(proj, 0);
    [u, d, v] = svd(R);
    Q = Q(:, 1:3)*u(1:3,1:3)*diag(1./sqrt(diag(d(1:3,1:3))));
    pnormal = Q;
end

pnormal = bsxfun(@rdivide, pnormal, sqrt(sum(pnormal.^2, 2)));
if sum(pnormal(:,3)<0) > sum(pnormal(:,3)>=0)
	pnormal = -pnormal;
end
normal2d = (reshape(pnormal, imsz(1), [], 3)+1)*0.5;
imshow(normal2d)
imwrite(normal2d, ['robust_pnormal' num2str(COLORCH) '.jpg']);