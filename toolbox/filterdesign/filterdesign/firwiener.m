function [W,R,P,V,Lam,dLam,kurt] = firwiener(N,x,y)
%FIRWIENER Optimal FIR Wiener filter.
%   B = FIRWIENER(N,X,Y) computes the optimal FIR Wiener filter of order N,
%   given two (stationary) random signals in column vectors X and Y.
%
%   B = FIRWIENER(N,X,Y) where X and Y are matrices, averages over the
%   columns of X and Y when computing the Wiener filter.

%   Author(s): Scott C. Douglas
%   Copyright 1999-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/04/26 19:32:14 $


[ntr,L] = size(x);              
r = zeros(2*(N+1)-1,1);             %  Initial autocorrelation vector
p = r;                          %  Initial cross correlation vector
for k=1:L
    r = r + xcorr(x(:,k),N);  %  Calculate (k)th autocorrelation and accumulate
    p = p +  xcorr(y(:,k),x(:,k),N);  %  Calculate (k)th cross correlation and accumulate
end
R = toeplitz(r(N+1:2*(N+1)-1))/(L*ntr);  %  (L x L) input autocorrelation matrix
P = p(N+1:2*(N+1)-1).'/(L*ntr);          %  (1 x L) cross correlation vector
W = P/R;

if nargout > 3,
    [V,Lam] = eig(R);               %  Find eigenvalue decomposition of R
    dLam = diag(Lam);               %  Specify eigenvalue vector
    if nargout > 6,
        kurt = 0;                       %  Initial kurtosis value
        for i=1:N
            for k=1:L
                xv = filter(V(:,i),1,x(:,k));  %  Calculate (k)th eigenvector filtered signal
                kurt = kurt + mean(xv.^4)/mean(xv.^2)^2 - 3;  %  Estimate kurtosis value
            end
        end
        kurt = kurt/(L*N);              %  Average kurtosis value of eigenvector filtered signals
    end
end
