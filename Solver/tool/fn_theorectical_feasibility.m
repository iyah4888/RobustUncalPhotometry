function [ isfeasible ] = fn_theorectical_feasibility( D, gt_rank, gt_sample_rate)
%FN_CAL_OBJ 이 함수의 요약 설명 위치
%   자세한 설명 위치
    [n,m] = size(D);
	dof = gt_rank*(n+m-1);
	
	isfeasible = dof/(n*m) <= gt_sample_rate;
    
end

