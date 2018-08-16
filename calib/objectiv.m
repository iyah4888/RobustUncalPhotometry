function [loss] = objectiv(x, data_2xN)
%OBJECTIV Summary of this function goes here
%   Detailed explanation goes here
    loss = sqrt((sum(bsxfun(@minus, data_2xN, x(1:2)).^2,1) - x(3)).^2);
end

