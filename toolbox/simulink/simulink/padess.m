function [abcd, ir, jc] = padess(T,N,needs_scalar_expansion)
%PADESS  Sparse Pade approximation for use with Simulink/Jacobians
% 
%    [abcd_elements, Ir, Jc] = PADESS(DelayTime, Order, needs_scalar_expansion);
%
% returns the nonzero entries of the sparse linear model in abcd_elements,
% and the sparse row and column data in Ir and Jc.  The boolean
% needs_scalar_expansion determines if the Jacobian should be scalar
% expanded.  It is assumed that the expansion is from 1 input.  The number
% of outputs is determined by the number of delays in T.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.8 $
%   Greg Wolodkin 07-21-1999

% N.B. some entries which are zero will be treated as nonzero.

A  = []; B  = []; C  = []; D  = []; 
mA = []; mB = []; mC = []; mD = [];

len = length(T);
if length(N) ~= len
    error('DelayTime and Order vectors must be of equal length.');
end

for i=1:len
    n  = N(i);
    [Ai,Bi,Ci,Di] = local_pade(T(i),n);
    A  = blkdiag(A,Ai);
    B  = blkdiag(B,Bi);
    C  = blkdiag(C,Ci);
    D  = blkdiag(D,Di);
    mA = blkdiag(mA,[ones(1,n); [eye(n-1) zeros(n-1,1)]]);
    mB = blkdiag(mB,[ones(n>0,1);zeros(n-1,1)]);
    mc = zeros(1,n); mc(1:2:n) = 1;
    mC = blkdiag(mC,mc);
    mD = blkdiag(mD,1);
end

if needs_scalar_expansion
    B = B*ones(size(B,2),1);
    mB = mB*ones(size(mB,2),1);
    D = D*ones(size(D,2),1);
    mD = mD*ones(size(mD,2),1);
end

mask    = logical([mA mB; mC mD]);
ABCD    = [A B; C D];
abcd    = ABCD(mask);
[ix,jx] = find(mask);

ir = ix - 1;
jc = 0:length(ir);
jc = jc(find(diff([-1;jx;max(jx)+1])))';

% full(sparse(ix,jx,abcd))

% quick sanity check
ABCD(mask) = 0;
if any(ABCD(:))
    error('Other entries are nonzero!');
end

if sum(mask(:)) ~= max(jc)
    error('Element count is wrong!');
end

%-------------

function [A,B,C,D] = local_pade(T,n);

if T == 0
    A = zeros(n);
    B = zeros(n,1);
    C = zeros(1,n);
    D = 1;
    
else
    a = zeros(1,n+1);   a(1) = 1;
    b = zeros(1,n+1);   b(1) = 1;
    for k = 1:n,
        fact = T*(n-k+1)/(2*n-k+1)/k;
        a(k+1) = (-fact) * a(k);
        b(k+1) = fact * b(k);
    end
    a = fliplr(a/b(n+1));
    b = fliplr(b/b(n+1));   
    
    %     [A,B,C,D] = compreal(a,b);
    [A,B,C,D] = tf2ss(a,b);
end
