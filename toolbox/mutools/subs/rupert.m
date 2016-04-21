%function [Q,nq] = rupert(x,y,ic,ir,jc,jr,opt)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [Q,nq] = rupert(x,y,ic,ir,jc,jr,opt)

%	makes a block diagonal matrix that is either
%	block dyadic or unitary depending on opt
%	may return junk if called incorrectly
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin==6 					dyad = 1;
elseif nargin==7 & strcmp(opt,'dyad'),		dyad = 1;
elseif nargin==7 & strcmp(opt,'unitary'),	dyad = 0;
else,	disp('   rupert.m called incorrectly'), return,	end

Q = zeros(length(x),length(y));		nq = [];
if length(x)==0 | length(y)==0,					return,	end
x = x(:);	y = y(:);
normxy = max([norm(x); norm(y)]);
if dyad
	if normxy>0,	x = x/normxy;	y = y/normxy;
	else,		error('   Matlab is bad in rupert.m'),		end
end
if any(size(ic)>[1 Inf])
	Ic = sum(ic);	Ir = sum(ir);
else
	Ic = ic;	Ir = ir;
end
if any(size(jc)>[1 Inf])
	Jc = sum(jc);	Jr = sum(jr);	nJ = length(jc(:,1));
else
	Jc = jc;	Jr = jr;	nJ = 1;
end

LIc = logical(Ic); LIr = logical(Ir);
LJc = logical(Jc); LJr = logical(Jr);

if length(jc)==0,			nJ = 0;				end
if sum(Jc),
  jcJ = jc(:,LJc); LjcJ = logical(jcJ);
  jrJ = jr(:,LJr); LjrJ = logical(jrJ);
end
if sum(Ic),
  icI = ic(:,LIc);
  irI = ir(:,LIr);
end
if any(abs([x; y])==Inf) | (any([x; y]==NaN))
	error('   Inf and NaN are bad in rupert.m'),
end


nq = 0;
%%%%%%%% repeated blocks
if sum(Ic)
	[junk,indm] = max(icI'.*abs(y(LIc)*ones(1,length(ic(:,1)))));
	ym = y(indm);
	xm = x(indm);
	ind0 = find(abs(ym)<=1000*eps);
	ind1 = find(abs(ym) >1000*eps);
	if length([ind0(:);ind1(:)])~=length(ym)
		error('   Matlab is bad in rupert.m')
	end
	iq = 0*ym;
	iq(ind1) = xm(ind1)./ym(ind1);
	nq = max(abs(iq));
	if ~dyad, iq = (iq+(abs(iq)<=10*eps))./abs(iq+(abs(iq)<=10*eps)); end
	Q(LIr,LIc) = diag(diag(irI'*diag(iq)*icI));
end	% if sum(Ic)
%%%%%%%% full blocks
if sum(Jc)
	jy = jcJ'.*(y(LJc)*ones(1,length(jcJ(:,1))));
	jx = jrJ'.*(x(LJr)*ones(1,length(jrJ(:,1))));
	ny = sqrt(sum(abs(jy.^2)));
	nx = sqrt(sum(abs(jx.^2)));
	ind0 = find(ny<=1000*eps);
	ind1 = find(ny >1000*eps);
	if length([ind0(:);ind1(:)])~=length(ny)
		error('   Matlab is bad in rupert.m')
	end
	nj = 0*ny;
	nj(ind1) = nx(ind1)./ny(ind1);
	nq = max([nj nq]);
	nj(ind1) = 1../ny(ind1).^2;
	jQ = jx*diag(nj)*jy';
	if ~dyad
		for ii = 1:nJ
			LjrJi = LjrJ(ii,:); LjcJi = LjcJ(ii,:);
			[u,s,v] = svd(jQ(LjrJi,LjcJi));
			[lu,lv] = size(s);
			jQ(LjrJi,LjcJi) = u*eye(lu,lv)*v';
		end	% for
	end	% if
	Q(LJr,LJc) = jQ;
end	% if sum(Jc)
if dyad
	if nq <= 10*eps
		save .ruperterr
		disp('   unexpected condition in rupert.m')
		disp('   please send .ruperterr to PMY & MPN')
		nq = 1;
	end
	Q = Q/nq;
end