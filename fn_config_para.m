function [ PARA ] = fn_config_para( varargin )
%FN_CONFIG_PARA 이 함수의 요약 설명 위치
%   자세한 설명 위치

    inp=inputParser;
    inp.addParamValue('lambda1', 1e-8, @(x)isreal(x) && isscalar(x));   
    inp.addParamValue('lambda2', 1e-8, @(x)isreal(x) && isscalar(x));   
    inp.addParamValue('maxiter', 700, @(x)isreal(x) && isscalar(x));
    inp.addParamValue('tol', 1e-7, @(x)isreal(x) && isscalar(x));
    inp.addParamValue('beta', 1, @(x)isreal(x) && isscalar(x)); % balance btw sparsity/rank 
    
    %% For ADMM only
%     inp.addParamValue('rho', 10,  @(x)isreal(x) && isscalar(x)); % 
%     inp.addParamValue('mu', 5, @(x)isreal(x) && isscalar(x)); % numerator of mu
    inp.addParamValue('rho', 1.2,  @(x)isreal(x) && isscalar(x)); % 
    inp.addParamValue('mu', 1.25, @(x)isreal(x) && isscalar(x)); % numerator of mu
    
    
    inp.addParamValue('mu_bar', 1e6, @(x)isreal(x) && isscalar(x)); % 
    inp.addParamValue('maxinnerloop', 50, @(x)isreal(x) && isscalar(x)); % 
    inp.addParamValue('tol_AP', 1e-6, @(x)isreal(x) && isscalar(x)); % tol. for adaptive penalty
    
    %% For target rank constraint methods,
    inp.addParamValue('target_rank', 3, @(x)isreal(x) && isscalar(x)); % tol. for adaptive penalty
    
    %% For matrix completion methods,
    inp.addParamValue('maskidx', [], @(x)isreal(x)); % tol. for adaptive penalty
    
    %% For IRLS-Lp methods (Dr. Lin's TIP15 paper),
%     inp.addParamValue('Lp', 0.001, @(x)isreal(x) && isscalar(x)); % tol. for adaptive penalty
    inp.addParamValue('Lp', 0.01, @(x)isreal(x) && isscalar(x)); % tol. for adaptive penalty
    
    inp.addParamValue('GT', [], @(x)isreal(x)); % for early termination
    
    inp.addParamValue('verbose', false, @(x)isreal(x) && isscalar(x));   
    
    inp.parse(varargin{:});
    PARA = inp.Results;
end

