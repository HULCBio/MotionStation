%function [bnds,g,jg,gamc,gamr,dal] = ...
%	newga(dMd,astep,alpha,bnds,g,jg,gamc,gamr,Kc,Kr)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 function [bnds,g,jg,gamc,gamr,dal] = ...
 	newga(dMd,astep,alpha,bnds,g,jg,gamc,gamr,Kc,Kr)

%	Gradient search on g
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<10,	disp('   newga.m called incorrectly')
		return
end

LKc = logical(Kc); LKr = logical(Kr);

dal = 0;
if alpha<=max([100*eps bnds(2)]),	return,				end
astep = real(astep);	if astep==0,	return,				end

sizM	= size(dMd);
[u,s,v] = svd((dMd/alpha-jg).*(gamc*gamr'));
sig	= max([max(diag(s)) 10*eps]);
	if sig<1,	bnds(1) = min([bnds(1) alpha]);			end
ind	= find((diag(s)/sig)>0.95);
if length(ind)>5 | length(ind)==0,	return,				end
u    = u(LKc,ind);
s   = s(ind,ind);
v   = v(LKr,ind);
jgb  = zeros(sizM(1),sizM(2));
gbc = gamc;
gbr = gamr;
ginv = 1../(1+g.*g);
galf = sqrt(ginv)*ones(1,length(ind));
ginv = (g.*ginv)*ones(1,length(ind))/2;

%	calculate partial derivatives, and step

grad = -real(((abs(u).^2 + abs(v).^2).*ginv)*s + j*conj(u).*v.*galf);
	if norm(grad,'fro')<10*eps, 		return,			end
grad2 = grad'*grad;
if abs(det(grad2)) > 1e-20
	gdir = -grad*(grad2\(diag(s)-0.90))*10;	% because Mathworks lies
else
	return
end
radi = real( sig + j*u(:,1)'*(galf(:,1).*v(:,1).*g) )/alpha;
if abs(radi)<10*eps
	% sigmax is independent of alpha
        junk = -grad(:,1)'*gdir;
        if junk<10*eps|norm(junk)==inf|norm(junk)==NaN, return,		end
        scale = -sig/100/junk;
else
	arad = grad(:,1)/radi;
	junk = -arad'*gdir;
	if junk<10*eps|norm(junk)==inf|norm(junk)==NaN, return,		end
	scale = astep/junk;	% so that arad'*delg = astep;
end
delg = -gdir*scale;
	if max(max(delg))>1e6,	delg = 1e6*delg/max(max(delg));		end

%	take a step to decide on the final step size
gb      = g + delg;
jgb(LKc,LKr) = diag(j*gb);
gbc(LKc) = (1+gb.*gb).^(-1/4);
gbr(LKr) = gbc(LKc);
sig1    = norm((dMd/alpha-jgb).*(gbc*gbr'));
	if sig1<1,	bnds(1) = min([bnds(1) alpha]);			end

%	do the parabola
delsig	= grad'*delg;
crap	= max([abs(sig1-sig-delsig(1)) 10*eps]);
steprat = min([100 max([-delsig(1)/2/crap -100])]);

	ii = 0;
while steprat<0.5 & steprat>0
	delg	= delg*max([0.125 steprat]);
	gb      = g + delg;
        jgb(LKc,LKr) = diag(j*gb);
	gbc(LKc) = (1+gb.*gb).^(-1/4);
	gbr(LKr) = gbc(LKc);
	sig1	= norm((dMd/alpha-jgb).*(gbc*gbr'));
		if sig1<1,      bnds(1) = min([bnds(1) alpha]);		end
	delsig	= grad'*delg;
	crap	= max([abs(sig1-sig-delsig(1)) 10*eps]);
	steprat	= -delsig(1)/2/crap;
		ii = ii + 1;	if ii==10,	steprat = 0;		end
end
	ii = 0;
while steprat>1.5 | steprat < 0.0
	delg	= delg*2;
        gb      = g + delg;
	jgb(LKc,LKr) = diag(j*gb);
        gbc(LKc) = (1+gb.*gb).^(-1/4);
	gbr(LKr)    = gbc(LKc);
        sig1	= norm((dMd/alpha-jgb).*(gbc*gbr'));
        	if sig1<1,      bnds(1) = min([bnds(1) alpha]);		end
        delsig	= grad'*delg;
	crap	= max([abs(sig1-sig-delsig(1)) 10*eps]);
        steprat	= -delsig(1)/2/crap;
        if steprat<0.5 & steprat>0,		delg = delg/2;		end
		ii = ii + 1;	if ii==20,	steprat = 0;		end
end


delg	  = delg*steprat;
g         = g + delg;			g = min(1e40,max(-1e40,g));
jg(LKc,LKr) = diag(j*g);
gamc(LKc)  = (1+g.*g).^(-1/4);
gamr(LKr)  = gamc(LKc);
if exist('arad'), dal = arad'*delg/2; else, dal = bnds(1)/50; end