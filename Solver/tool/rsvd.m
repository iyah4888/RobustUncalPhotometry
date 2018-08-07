function [ U, D, V ] = rsvd( A, target )
%RSVD Summary of this function goes here
%   Detailed explanation goes here
    global gOmega;

    [m, n] = size(A);
    
    if isempty(gOmega)
%             gOmega = sprandn(m,n,0.1);
            gOmega = randn(m,n);
    end
    
    K = min(target, n);
    maxrank = min(m,n);
    randidx = randi(maxrank-K+1);
    
    Omega = gOmega(randidx:randidx+K-1,:);
%     Omega = randn(n, l);

    Y = A*Omega';
%     [Q, ~, ~] = qr(Y,0);

%     d = abs (get_diag (R)) ;
%     tol = 20 * (m+n) * eps (max (d));
%     r = sum (d > tol) ;
%     if (r < maxrank)
%         Q = Q (:, 1:r) ;
%     end
        
    % Power iteration
%     for q = 1:1
%         Y_hat = (Q'*A)';
%         [Qyt, ~] = qr(Y_hat,0);
%         Y = A*Qyt;
%         [Q, ~] = qr(Y,0);
        [Q, ~] = qr(A*(A'*Y), 0);
%     end
    
%     [Q, ~] = qr(Y, 0);
    B = Q'*A*Q;
    [Uhat, D, V] = svd(B);
    d = diag(D);
	cur_rank = sum(d>1e-8);
    D = diag(d(1:cur_rank));
%     [Uhat, D, V] = lansvd(B, l, 'L');
%     [Uhat, D, V] = qdwhsvd(B);
    U = Q*Uhat(:,1:cur_rank);
    
    if nargout > 2
        V = Q*V;   
    end
end

