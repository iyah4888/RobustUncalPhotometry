function [A_hat, E_hat, time_n_obj, iter] = TNN_RPCA(D, PARA)

% Modified by Tae-Hyun Oh.
% This code is the implementation of 
% Oh et al., "Partial Sum Minimization of Singular Values in Robust PCA: Algorithm and Applications," TPAMI 2016
% 
% This code is modified from the following implementation.
% 
% Oct 2009
% This matlab code implements the inexact augmented Lagrange multiplier 
% method for Robust PCA.
%
% D - m x n matrix of observations/data (required input)
%
% lambda - weight on sparse error term in the cost function
%
% tol - tolerance for stopping criterion.
%     - DEFAULT 1e-7 if omitted or -1.
%
% maxIter - maximum number of iterations
%         - DEFAULT 1000, if omitted or -1.
% 
% Initialize A,E,Y,u
% while ~converged 
%   minimize (inexactly, update A and E only once)
%     L(A,E,Y,u) = |A|_* + lambda * |E|_1 + <Y,D-A-E> + mu/2 * |D-A-E|_F^2;
%   Y = Y + \mu * (D - A - E);
%   \mu = \rho * \mu;
% end
%
% Minming Chen, October 2009. Questions? v-minmch@microsoft.com ; 
% Arvind Ganesh (abalasu2@illinois.edu)
%
% Copyright: Perception and Decision Laboratory, University of Illinois, Urbana-Champaign
%            Microsoft Research Asia, Beijing

% addpath PROPACK;

[m n] = size(D);
const_rank = PARA.target_rank;

lambda = PARA.beta / sqrt(max(m,n));
tol = PARA.tol;
maxIter = 1000;

% initialize
% Y = D;

Y = zeros( m, n);
norm_two = norm(D, 2);
norm_inf = norm( D(:), inf) / lambda;
dual_norm = max(norm_two, norm_inf);
Y = Y / dual_norm;


A_hat = zeros( m, n);
E_hat = zeros( m, n);
mu = 1.25/norm_two; % this one can be tuned
mu_bar = mu * 1e7;
rho = 1.1;          % this one can be tuned
d_norm = norm(D, 'fro');

iter = 0;
total_svd = 0;
converged = false;
stopCriterion = 1;
sv = 10;

% figure;
% strtitle = sprintf('Rank %d Cases', const_rank);
% title(strtitle);
residual_arr = [];
tic;
while ~converged       
    iter = iter + 1;
    
    %% E
    temp_T = D - A_hat + (1/mu)*Y;
    E_hat = max(temp_T - lambda/mu, 0);
    E_hat = E_hat+min(temp_T + lambda/mu, 0);
    
    %% A
%     if choosvd(n, sv) == 1
%         [U S V] = lansvd(D - E_hat + (1/mu)*Y, sv, 'L');
%     else
        [U S V] = svd(D - E_hat + (1/mu)*Y, 'econ');
%     end
    diagS = diag(S);
    svp = length(find(diagS > 1/mu));
    
    if svp <= const_rank
        dterm = diag( diagS(1:svp) );
    else
        dterm = diag( [diagS(1:const_rank);diagS(const_rank+1:svp) - 1/mu] );
    end
    A_hat = U(:, 1:svp) * dterm * V(:, 1:svp)';    

    total_svd = total_svd + 1;
    
    
    %% Y
    Z = D - A_hat - E_hat;
    Y = Y + mu*Z;
    mu = min(mu*rho, mu_bar);
        
    %% stop Criterion    
    stopCriterion = norm(Z, 'fro') / d_norm;
    
    if stopCriterion < tol
        converged = true;
    end    
    
    
    if ~converged && iter >= maxIter
        disp('Maximum iterations reached') ;
        converged = 1 ;       
    end
end
time_n_obj = zeros(1,2);
time_n_obj(1) = toc;
time_n_obj(2) = fn_obj_l0( A_hat, E_hat );