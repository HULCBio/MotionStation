% function [T, invT, S, s]=ham2schr(a,b1,c1,epr);
%
% HAM2SCHR decomposes the Hamiltonian matrix
%
%     H= [-a'    -c1*c1]
%        [b1*b1   a ]
%
% into 3 spectral subspaces: Left half-plane, , jw-axis,
% and Right half-plane so that block-diagonal=S=invT*H*T.
%
% See Also: SDEQUIV, SDHFNORM, and SDHFSYN

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [T, invT, S, s]=ham2schr(a,b1,c1,epr);

[J,Ab]=balance([-a'  -c1'*c1; b1*b1'  a]);
[v,t,flgout,reig_min]=csord(Ab,epr,0,0,0);
n=max(size(t));
lhp_eig=0; % number of open LHP eigenvalues
axis_eig=0; %number of imaginary axis eigenvalues
eig_count=1;
while eig_count <= n, % determine size of each subspace
	if real(t(eig_count,eig_count)) < -epr,
		lhp_eig=lhp_eig+1;
	else
		if real(t(eig_count,eig_count)) < epr
			axis_eig=axis_eig+1;

		else
			eig_count=n;
		end
	end
	eig_count=eig_count+1;
end

%
% t=[H1 H3]   H1 has the negative eigenvalues of t
%   [0  H2]   H2 contains non-negative eigenvalues
%
% diagonalize t to get [H1 0]
%                      [0 H2]
%
if lhp_eig~=0, % negative eigenvalues exist
	H1=t(1:lhp_eig,1:lhp_eig);
	H2=t(lhp_eig+1:n,lhp_eig+1:n);
	H3=t(1:lhp_eig,lhp_eig+1:n);
	X=axxbc(H1,-H2,-H3);
	% X=[X1 X2]
	X1=X(:, 1:axis_eig);
	X2=X(:, axis_eig+1:n-lhp_eig);
else % t has no negative eigenvalues
	H1 = [];	% Added for matlab v5
	H2=t;
	X=[];X1=[];X2=[];
end

%
% H2=[h1 h3]  h1 contains the jw axis spectra
%    [0  h2]  h2 contains rhp spectra
%
% diagonalize t to get [h1 0]
%                      [0 h2]
%
if (axis_eig~=0)&((n-axis_eig-lhp_eig)~=0), % axis and rhp spectra
	h1=t(lhp_eig+1:lhp_eig+axis_eig, lhp_eig+1:lhp_eig+axis_eig);
	h2=t(lhp_eig+axis_eig+1:n, lhp_eig+axis_eig+1:n);
	h3=t(lhp_eig+1:lhp_eig+axis_eig, lhp_eig+axis_eig+1:n);
	y=axxbc(h1, -h2, -h3);
	L=[eye(lhp_eig) X1  X1*y+X2;
	zeros(axis_eig,lhp_eig) eye(axis_eig) y;
	zeros(n-axis_eig-lhp_eig,axis_eig+lhp_eig) eye(n-axis_eig-lhp_eig)];
	invL=[eye(lhp_eig) -X1  -X2;
	zeros(axis_eig,lhp_eig) eye(axis_eig) -y;
	zeros(n-axis_eig-lhp_eig,axis_eig+lhp_eig) eye(n-axis_eig-lhp_eig)];
	Hnn=[h1 zeros(axis_eig, n-lhp_eig-axis_eig);
	    zeros(n-axis_eig-lhp_eig,axis_eig) h2];


else % only one of axis and rhp spectra
	L=[eye(lhp_eig) X; zeros(n-lhp_eig,lhp_eig) eye(n-lhp_eig)];
	invL=[eye(lhp_eig) -X; zeros(n-lhp_eig,lhp_eig) eye(n-lhp_eig)];
	Hnn=H2;
end

%
%        [H1  0  0]
% S=L\tL=[0  h1  0]
%        [0   0 h2]
%
S=[H1 zeros(lhp_eig,n-lhp_eig);
zeros(n-lhp_eig, lhp_eig) Hnn];

T=J*v*L;
invT=L\v'/J;
s=[lhp_eig   axis_eig   n-lhp_eig-axis_eig];
%
%