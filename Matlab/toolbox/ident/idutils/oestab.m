function As = oestab(A,lam,matrix)
%OESTAB Help function to ARX and GNNEW 
%   As = OESTAB(A,LAM;MATRIX)
%
%   If MATRIX == 1, A is a matrix, that is modelfied so that the returned As has all
%   eigenvalues inside |z|<LAM.
%
%  If MATRIX = 0, A is a polynomial that is modified in a similar way.

%   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.3 $Date: 2001/04/06 14:21:54 $

if nargin < 3
	matrix = 0;
end
if nargin < 2
	lam = 1;
end
if min(size(A))>1
	matrix = 1;
end
if matrix
	[V,D]=eig(A);
	if cond(V)>10^8, 
		[V,D]=schur(A);[V,D]=rsf2csf(V,D);
	end
	test = max(abs(diag(D)))<lam;
	if test
		As=A;
		return,
	end
	[n,n]=size(D);
	for kk=1:n
 		if abs(D(kk,kk))>lam,D(kk,kk)=lam/abs(D(kk,kk))*D(kk,kk);end
	end
	As=real(V*D*inv(V));
else
	vs = roots(A);
	for kk = 1:length(vs)
		if abs(vs(kk))>lam,vs(kk) = lam/abs(vs(kk))*vs(kk);end
	end
	As = real(poly(vs));
end
