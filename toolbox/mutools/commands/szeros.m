% function out = szeros(sys,epp)
%
%   Finds the transmission zeros of a SYSTEM matrix.
%   Occasionally, large zeros are included which may
%   actually be at infinity. Solving for the transmission
%   zeros of a system involves two generalized eigenvalue
%   problems. EPP (optional) defines if the difference between
%   two generalize eigenvalues is small.
%
%   See also: EIG and SPOLES.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

%   Algorithm based on Laub & Moore 1978 paper, Automatica

function out = szeros(sys,epp)
if nargin < 1
	disp('usage: szeros(sys)')
	return
end
if nargin == 1
	epp = eps;
end
[mtype,mrows,mcols,mnum] = minfo(sys);
if mtype == 'syst'
	[a,b,c,d] = unpck(sys);
	if mnum == 0
		disp('SYSTEM has no states')
	end
	sysu = [a b; c d];
	
	% find generalized eigenvalues of a square system matrix
	
	if mrows == mcols
		x = zeros(mnum+mcols,mnum+mcols);
		x(1:mnum,1:mnum) = eye(mnum);
		z = eig(sysu,x);
		comp = computer;
		if strcmp(comp(1:3),'VAX')
			z = z/2;
			zind = find(abs(z)>epp & abs(z)<1/epp);
			out = 2*z(zind);
		else
			out = z(~isnan(z) & finite(z));
		end
	else
		nrm = norm(sysu,1);
		if mrows > mcols
			x1 = [ sysu  nrm*(rand(mnum+mrows,mrows-mcols)-.5)];
			x2 = [ sysu  nrm*(rand(mnum+mrows,mrows-mcols)-.5)];
		else
			x1 = [ sysu; nrm*(rand(mcols-mrows,mnum+mcols)-.5)];
			x2 = [ sysu; nrm*(rand(mcols-mrows,mnum+mcols)-.5)];
		end
		
		x = zeros(size(x1));
		x(1:mnum,1:mnum) = eye(mnum);
		z1 = eig(x1,x);
		z2 = eig(x2,x);
		comp = computer;
		if strcmp(comp(1:3),'VAX')
			z1 = z1/2;
			zind = find(abs(z1)>epp & abs(z1)<1/epp);
			z1 = 2*z1(zind);
		else
			z1 = z1(~isnan(z1) & finite(z1));
		end
		comp = computer;
		if strcmp(comp(1:3),'VAX')
			z2 = z2/2;
			zind = find(abs(z2)>epp & abs(z2)<1/epp);
			z2 = 2*z2(zind);
		else
			z2 = z2(~isnan(z2) & finite(z2));
		end
		nz = length(z1);
		out = zeros(0,1);
		for i=1:nz
			if any(abs(z1(i)-z2) < nrm*sqrt(epp))
				out = [out; z1(i)];
			end
		end
	end
else
	error('matrix is not a SYSTEM matrix')
	return
end
