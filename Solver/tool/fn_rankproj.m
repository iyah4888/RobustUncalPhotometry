function [ proj_PSD ] = fn_rankproj( PSD_mat, const_rank )
%FN_RANKPROJ �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
%     [tV, tD] = eig(PSD_mat, 'nobalance');
    [tV, tD] = eig(PSD_mat);
    ddtD = diag(tD);
    if ~issorted(ddtD)
        [sortval, sortidx] = sort(ddtD);
        tV = tV(:, sortidx);
        ddtD = sortval;
    end
%     ddtD(1:end-const_rank) = 1e-8;
    ddtD(end-const_rank+1:end) = 1e6;
    tD = diag(ddtD);
    proj_PSD = tV*tD*tV';
end

