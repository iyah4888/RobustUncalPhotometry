clear all;
close all; clf; addpath(genpath('Solver'));




%% Definition
IMGPATH = '../Photometry_sample/cap3'
IMGSCALE = 1.0/10.0;%
OPTION.USE_PRELOADED_DATA = 0;
OPTION.OUTLIER_FILTER = 1;	% {1,2}
OPTION.COLORCH = 2;
OPTION.CHROMACITY_CANCEL = 1;



RPCA_METHOD = {'TNN_RPCA', 'EB_RPCA_1Side'}; % 
fn_path = @(x) fullfile(IMGPATH, x);
imgread = @(x) imresize(im2double(imread(x)), IMGSCALE);
COLORCH = OPTION.COLORCH;

APARA = fn_config_para('target_rank', 3, 'beta', 1.5);



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
if ~exist('datamat.mat') || ~OPTION.USE_PRELOADED_DATA

	for i = 1:length(seq_img)
	    % curfname = sprintf(fformat, seq_img(i));
	    curfname = fn_path(flist(i).name);
	    % cell_imgs{i} = imgread(curfname) - img_back;
	    cell_imgs{i} = imgread(curfname);

	    labimg = rgb2lab(cell_imgs{i})./100;
	    chroimg = bsxfun(@rdivide, cell_imgs{i}, labimg(:,:,1)+eps);
	    
	    % Chromacity canceling
	    if OPTION.CHROMACITY_CANCEL
	    	grayimg = cell_imgs{i}(:,:,COLORCH)./chroimg(:,:,COLORCH);
	    else
	    	% grayimg = cell_imgs{i}(:,:,COLORCH);
	    	grayimg = rgb2gray(cell_imgs{i});
	    end
	    maxv_arr(i) = max(grayimg(:));
	    imgmat(:, i) = grayimg(:);
	end

	% imgmat = bsxfun(@rdivide, imgmat, maxv_arr);
	imgmat = imgmat./max(maxv_arr);
	save('datamat.mat', 'imgmat');
else
	load('datamat.mat');
end




%% Robust uncalibrated pseudo photometric stereo
disp('Outlier filtering');
[L, E] = feval(RPCA_METHOD{OPTION.OUTLIER_FILTER}, imgmat', APARA);
imgmat = L';
imgmat = bsxfun(@minus, imgmat, mean(imgmat, 2));







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


%% Since the normal is not physically plausible, depth cannot be reconstructed,
% Need calibration or need to solve GBR ambiguity

% mask = ones(size(normal2d));
% mask = mask(:,:,1);
% mask(:,1) = 0; mask(:,end) = 0;
% mask(1,:) = 0; mask(end,:) = 0;

% z = DepthMap( normal2d, mask);
% figure(2), surfl(z); shading interp; colormap gray
