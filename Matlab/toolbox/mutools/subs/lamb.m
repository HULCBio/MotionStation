%function [bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr] = ...
%	lamb(bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr,Kc,Kr)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr] = ...
	lamb(bnds,alpha,dMd,dc,dri,g,jg,gamc,gamr,Kc,Kr)

%	lambda formulation to get an ub.
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<9,	disp('   lamb.m called incorrectly')
		return
end

LKc = logical(Kc); LKr = logical(Kr);

sizM	= size(dMd);
onec	= ones(sizM(1),1);
oner	= ones(sizM(2),1);
golc	= gamc;	gchr = gamr;		golr	 = gamr;
dMd	= dMd.*(gamc*(1../gamr'));
g	= g*alpha;
jg(LKc,LKr) = diag(j*g);
g2	= zeros(sizM(2));
g2(LKr,LKr) = diag(g.*g);
M2	= dMd - jg;

bnds(1)	= sqrt(max([max(real(eig(M2'*M2 - g2))) eps]));% maybe shift and svd

alpha   = bnds(1);
g       = g/alpha;
jg(LKc,LKr) = diag(j*g);
gamc(LKc)= ((1+g.*g).^(-0.25));
gamr(LKr)  = gamc(LKc);
gchc	= gamc./golc;
gchr(LKr)  = gchc(LKc);
dc      =  dc./(gchc*onec');
dri     = dri.*(oner*gchr');
dMd     = dMd./(gamc*(1../gamr'));