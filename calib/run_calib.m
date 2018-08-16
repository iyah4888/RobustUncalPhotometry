DATAPATH = '../../Photometry_sample/chromeball';
file_amb = 'ball.jpg';

N_iter2click_circleboundary = 3;

fn_path = @(x) fullfile(DATAPATH, x);
img_amb = imread(fn_path(img_amb));
imshow(img_amb);

flist = ls('sample*.mat');
if ~(size(flist, 1) > 0)
    for i = 1:N_iter2click_circleboundary
        p = vl_click(10);
        save(['sample' num2str(randi(1e6)) '.mat'], 'p');
    end
end

%% Load sample points to estimate circle boundary
flist = ls('sample*.mat');
concat_pt2d = [];
for ifile = 1:size(flist, 1)
    load(flist(ifile,:));
    concat_pt2d = cat(2, concat_pt2d, p);
end

hold on;
%% Viz sample points to estimate circle boundary
vl_plotpoint(concat_pt2d);
% hold off;

%% Optimize the circle center and radius
im_sz = size(img_amb);
x_init = [im_sz(2:-1:1)./2 (im_sz(1)/2).^2];  % [x_center, y_center, radius^2]
x_init = x_init';
[x_star, resnorm] = lsqnonlin(@(x) objectiv(x, concat_pt2d), x_init);
%% Draw center point + most right side point.
vl_plotpoint(x_star(1:2));
vl_plotpoint(x_star(1:2)+[sqrt(x_star(3)); 0]);

%% generate mask
% mask = zeros(size(img_amb,1), size(img_amb,2));
[xx, yy] = meshgrid(1:size(img_amb,2), 1:size(img_amb,1));
mask = (xx - x_star(1)).^2 + (yy - x_star(2)).^2 < x_star(3);
imwrite(mask, 'mask.png');


%% Gradient image test => failed.
% img_lab = rgb2lab(img_amb);
% img_amb = im2single(img_amb);
% img_amb = img_amb.^0.5;
% dy = img_amb(1:end-1,:,:)-img_amb(2:end,:,:); dy = cat(1,dy, zeros(1,size(dy,2), 3));
% dx = img_amb(:,1:end-1,:)-img_amb(:,2:end,:); dx = cat(2,dx, zeros(size(dx,1),1, 3));
% grad = sqrt(max(dx.^2 + dy.^2, [], 3));
% imagesc(grad)

CalibrateLights(DATAPATH, x_star(1:2), sqrt(x_star(3)));