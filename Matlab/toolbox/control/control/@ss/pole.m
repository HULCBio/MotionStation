function p = pole(sys)
%POLE  Compute the poles of LTI models.
%
%   P = POLE(SYS) computes the poles P of the LTI model SYS (P is 
%   a column vector).
%
%   For state-space models, the poles are the eigenvalues of the A 
%   matrix or the generalized eigenvalues of the (A,E) pair in the 
%   descriptor case.
%
%   If SYS is an array of LTI models with sizes [NY NU S1 ... Sp],
%   the array P has as many dimensions as SYS and P(:,1,j1,...,jp) 
%   contains the poles of the LTI model SYS(:,:,j1,...,jp).  The 
%   vectors of poles are padded with NaN values for models with 
%   relatively fewer poles.
%
%   See also DAMP, ESORT, DSORT, PZMAP, ZERO, LTIMODELS.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/04/10 06:00:52 $


% REVISIT: Following should work provided that
%  eig(A,[]) = eig(A)
%  eig(A,E) complex conjugate

s = size(sys);
Nx = size(sys,'order');
Nxmax = max(Nx(:));

% Compute poles
p = zeros([Nxmax 1 s(3:end)]);
for k=1:prod(s(3:end))
    if isempty(sys.e{k})
        pk = eig(sys.a{k});
    else
        pk = eig(sys.a{k},sys.e{k});
    end
    nx = length(pk);
    p(1:nx,1,k) = pk;
    p(nx+1:Nxmax,1,k) = NaN;
end
