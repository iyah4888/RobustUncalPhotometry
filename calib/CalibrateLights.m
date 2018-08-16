function [L] = CalibrateLights(directory, center, radius)
% This function is used to calibrate the lighting direction.

% Find all the files in that directory.
  if directory (end) ~= '/'
      fileName = [directory '/'];
  end

%   fileName = [fileName 'chrome.'];
% Calculate the center of the chrome ball.
  maskFileName = [fileName 'mask.png'];
  mask = imread(maskFileName);
%  circle = rgb2gray(circle);

% Calculate the center of the chrome ball.
%   maxval = max( max( circle ) );
%   [circleRow circleCol] = find(circle == maxval);
%   maxRow = max(circleRow);
%   minRow = min(circleRow);
%   maxCol = max(circleCol);
%   minCol = min(circleCol);
%   xc     = double((maxCol + minCol)/2);
%   yc     = double((maxRow + minRow)/2);
%   center = [xc, yc]
%   radius = double((maxRow - minRow)/2)

% R: The reflection direction.
  R = [0 0 1.0];
  L = [];

  xc = center(1);
  yc = center(2);
  
    flist_lightimgs = ls(fullfile(directory, '*.jpg'));
    flag = true(size(flist_lightimgs, 1),1);
%     keyboard;
    for i = 1:size(flist_lightimgs,1)
        if isempty(regexp(flist_lightimgs(i,:), '[0-9]+_[0-9]+.jpg', 'start'))
            flag(i) = false;
        end
    end
    flist_lightimgs = flist_lightimgs(flag, :);
  
% Calculate the lighting direction.

numLights = size(flist_lightimgs,1);
L = zeros(numLights, 3);
mask = im2single(mask);
figure(2);
% axis vis3d;
% campos('auto')
camtarget([0,0,0]);

  for i = 1:numLights
      
      imgFileName = fullfile(directory,flist_lightimgs(i,:));
      image = im2single(imread(imgFileName));
%       
      image = rgb2gray(image).*mask;
      maxval = max( max( image ) );
      [pointRow, pointCol] = find(image == maxval);
      figure(1), imshow(image);
      hold on;
      vl_plotpoint([pointCol, pointRow]');
     
      nSize  = size( pointRow, 1);
      px     = sum(pointCol)/double(nSize);
      py     = sum(pointRow)/double(nSize);
      vl_plotpoint([px, py]');
      
      Nx     =   px - xc;
      Ny     = -(py - yc);
      Nz     = sqrt( radius^2 - Nx^2 - Ny^2 );
      normal = [Nx, Ny, Nz];
      normal = normal/radius;
      NR     = normal(1)*R(1) + normal(2)*R(2) + normal(3)*R(3);
      L(i,:) = 2*NR*normal - R;
      hold off;
      drawnow;
      
      figure(2);
      hold on;
      quiver3(0,0,0, L(i,1), L(i,2), L(i,3));
      hold off;
      drawnow;
  end

% Write the new lighting direction into a test file.
  fid = fopen('calibratedLight.txt', 'w');
  fprintf( fid, '%d \n', numLights);
  for row = 1:numLights
      fprintf(fid, '%s %10.5f %10.5f %10.5f \n', flist_lightimgs(row,:), L(row,1), L(row,2), L(row,3) );
  end
  fclose(fid);
  save('caliblight.mat', 'flist_lightimgs', 'L');
end

