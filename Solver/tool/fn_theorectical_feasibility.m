function [ isfeasible ] = fn_theorectical_feasibility( D, gt_rank, gt_sample_rate)
%FN_CAL_OBJ �� �Լ��� ��� ���� ��ġ
%   �ڼ��� ���� ��ġ
    [n,m] = size(D);
	dof = gt_rank*(n+m-1);
	
	isfeasible = dof/(n*m) <= gt_sample_rate;
    
end

