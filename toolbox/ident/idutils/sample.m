function [A,B,D,K,L] = sample(A,B,C,D,K,T,inters,sample)
%SAMPLE  Sample/unsample linear systems
%
%   [As,Bs,Ds,Ks,Ls] = SAMPLE(A,B,C,D,K,T,InterSample,Mode)
%
%   A,B,C,D,K are the matrices of the system to be sampled/unsampled.
%   T is the sampling interval.
%   InterSample is 'zoh' or 'foh'
%   Mode = 1 (default) means sampling and Mode = 0 means unsample.
%   As,Bs,Cs,Ds,Ks are the resulting system matrices.
%   Ls is the adjustment of the covariance matrix in case of 'foh'
%   sampling, so that the covariance of the new innovations is
%   Ls*Lambda*Ls' where Lambda is the T-adjusted covariance of the
%   noise of the original system.

%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.12.4.1 $ $Date: 2004/04/10 23:20:24 $

[nx,nu]=size(B);
ny=size(D,1);
[nx,nyk]=size(K);
L = eye(nyk);
if nargin <8
    sample = 1;
end
if sample
    switch lower(inters(1))
    case 'z'
        s = expm([[A [B K]]*T; zeros(nu+nyk,nx+nu+nyk)]);
        A = s(1:nx,1:nx);
        B = s(1:nx,nx+1:nx+nu);
        K = s(1:nx,nx+nu+1:nx+nu+nyk);
    case 'f'
        
        nuy = nu+nyk;
        s = expm([[A [B K] zeros(nx,nuy)]*T;[zeros(nuy,nx+nuy),T*eye(nuy)];...
                zeros(nuy,nx+2*nuy)]);
        A = s(1:nx,1:nx);
        gtil = s(1:nx,nx+nuy+1:nx+2*nuy);
        BK = s(1:nx,nx+1:nx+nuy)+(A-eye(nx))*gtil/T;
        B = BK(:,1:nu); K = BK(:,nu+1:nuy);
        D = D+C*gtil(:,1:nu)/T;
        if nyk>0
        L = eye(nyk) + C*gtil(:,nu+1:nuy)/T;
        K = K*pinv(L);
    end
    otherwise
        error('Only ''Zero-order'' hold and ''First-order-hold'' sampling is supported')
    end
    
else
        switch lower(inters(1))

case 'z'
    s = logm([[A [B K]]; [zeros(nu+nyk,nx) eye(nu+nyk,nu+nyk)]])/T;
    if isreal([A B K]), s = real(s); end
    A = s(1:nx,1:nx);
    B = s(1:nx,nx+1:nx+nu);
    K = s(1:nx,nx+nu+1:nx+nu+nyk);
case 'f'
    
    nuy = nu+nyk;
    Ac = logm(A)/T;%%LL traps for bad results
    if any(any(isnan(Ac)))
        error('Conversion failed. Eigenvalues of A in the origin.')
    end
    if isreal(A), Ac = real(Ac); end
    s = expm([[Ac eye(nx) zeros(nx,nx)]*T;[zeros(nx,2*nx),T*eye(nx)];zeros(nx,3*nx)]);
     Gt = s(1:nx,2*nx+1:3*nx);
    Bgen = pinv(s(1:nx,nx+1:2*nx)+(A-eye(nx))*Gt/T);
    
    B = Bgen*B;
    K = Bgen*K;
    D = D - C*Gt*B/T;
    A = Ac; 
    if nyk>0
    L = eye(nyk) - C*Gt*K/T;
    K = K*pinv(L);
end
otherwise
    error('Only ''Zero-order'' hold and ''First-order-hold'' sampling is supported')
end

end
