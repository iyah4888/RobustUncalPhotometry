function [ objsum ] = fn_cal_obj( Y, covPhi, covGamma, lambda )
%FN_CAL_OBJ �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
    [n,m] = size(Y);
    objsum = 0;
    for i = 1:m
        covy = (covPhi + diag(covGamma(:,i)) + lambda.*eye(n));
        objsum = objsum + Y(:,i)'*(covy\Y(:,i)) + log(det(covy)+eps);
    end
    objsum = objsum./m./n;
end
% 
% function [ objsum ] = fn_cal_obj( X, S, covPhi, covGamma, lambda )
% %FN_CAL_OBJ �� �Լ��� ��� ���� ��ġ
% %   �ڼ��� ���� ��ġ
%     [n,m] = size(X);
%     objsum = 0;
%     for i = 1:m
%         covy = (covPhi + diag(covGamma(:,i)) + lambda.*eye(n));
%         objsum = objsum + X(:,i)'*(covPhi\X(:,i)) + S(:,i)'*(diag(covGamma(:,i))\S(:,i)) + log(det(covy));
%     end
%     objsum = objsum./m./n;
% end

