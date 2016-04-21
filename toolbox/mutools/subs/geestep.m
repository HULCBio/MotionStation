%function [bnds,g,gamr,gamc,jg,gflag] = ...
%	geestep(dMd,bnds,Kc,Kr,kcK,nK,csc,bitol,g,gamr,gamc,jg)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,g,gamr,gamc,jg,gflag] = ...
	geestep(dMd,bnds,Kc,Kr,kcK,nK,csc,bitol,g,gamr,gamc,jg)

%	We start with a balanced matrix dMd.
%	This code can be made to bomb if called incorrectly.
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<8,	disp('   geestep.m called incorrectly')
		return
end

LKc = logical(Kc); LKr = logical(Kr);

if abs(bitol)<=100*eps
	error('   We will not let geestep.m bisect that much')
end

if nargin>8
	gold	= g;
        gamco   = gamc;
        gamro   = gamr;
        jgold   = jg;
end	% if nargin
sizM = size(dMd);
ub = bnds(1);
plb = max([bnds(2) ub*1e-6]);

%	make g = imag diag

gamc = ones(sizM(1),1);
gamr = ones(sizM(2),1);
diM  = imag(diag(dMd(LKc,LKr)));
jg   = zeros(sizM(1),sizM(2));      jg(LKc,LKr) = diag(j*diM);
dMdi = dMd - jg;
diM2 = diM.^2;

if bitol<0,	% only see if imag diag is better than alpha

        gamc(LKc) = (1+(diM2/(ub.^2))).^(-0.25);
        gamr(LKr) = gamc(LKc);
	if norm((dMdi/ub).*(gamc*gamr'))>1
		gflag	= 0;
		g       = gold;
	        gamc    = gamco;
	       	gamr    = gamro;
	        jg      = jgold;
	else
		gflag		= 1;
		g		= diM/ub;
		jg(LKc,LKr)	= diag(j*g);
		gamc(LKc)	= (1+g.*g).^(-0.25);
		gamr(LKr)	= gamc(LKc);
	end	% if norm

else	% if bitol	% bisect

	dist = abs(ub/plb);
	if dist>1.001
	numbi = min([ceil(log(log(dist)/log(1+bitol))/log(2)) 11]);
	for ii = 1:numbi
		dist = sqrt(dist);
		gamc(LKc) = (1+(diM2/((ub/dist).^2))).^(-0.25);
		gamr(LKr) = gamc(LKc);
		if norm((dMdi/(ub/dist)).*(gamc*gamr'))<1
			ub = ub/dist;
		end	% if
	end	% for ii
	end     % if dist
        if ub<bnds(1),
                g	= diM/ub;
        else
                g	= 0*diM;
        end
        jg(LKc,LKr)	= diag(j*g);
        gamc(LKc)	= (1+g.*g).^(-0.25);
        gamr(LKr)	= gamc(LKc);
end	% if bitol

bnds(1) = ub;