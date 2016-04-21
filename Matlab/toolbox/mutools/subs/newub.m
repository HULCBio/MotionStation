% function [bnds,alpha,ubflag] = ...
%	newub(dMd,jg,gamc,gamr,bnds,csc,csr,bitol,gapui,gapul)
%       Not intended to be called by the user.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  function [bnds,alpha,ubflag] = ...
 	newub(dMd,jg,gamc,gamr,bnds,csc,csr,bitol,gapui,gapul)

%	bisect (bitol = 0.01 or so) or do something else (e.g. bitol = -0.01)
%	to get a better ub, and maybe an even better alpha.
%       Authors:  Matthew P. Newlin and Peter M. Young


if nargin<8,	disp('   newub.m called incorrectly')
		return
end

ub = bnds(1);
alpha = ub;
ubflag = 0;
plb = max([bnds(2) ub*1e-6]);
gamcr = gamc*gamr';
gam2 = jg.*gamcr;
M2   = dMd.*gamcr;

if bitol>=100*eps

dist = abs(ub/plb);
if dist>100*eps
numbi = min([ceil(log(log(dist)/log(1+bitol))/log(2)) 11]);
for ii = 1:numbi
        dist = sqrt(dist);
        if norm((M2/(ub/dist)) - gam2)<1
                ub = ub/dist;
        end
	alpha = min([alpha,ub]);
end
end     % if dist

else

if gapul<1e-6,	return,		end
if gapui<1e-6,	return,		end
if ub<1e-6,	return,		end
bet1 = 1/(plb*gapul);
sM = M2*bet1;
sig1 = norm(sM - gam2);
if sig1>1
        bet2 = gapui/ub;
		if bet2<10*eps,         save .newuberr
			disp( '   Please send .newuberr to MPN & PMY')
			error('   Problem in newub.m')
		end % if bet2
        sM = M2*bet2;
        sig2 = norm(sM - gam2);
   if sig2<1
	ub = min([ub 1/bet2]);
		if (sig1-sig2)<10*eps
			bnds(1) = ub;	alpha = ub;	return
		end % if (sig1
        bet3 = bet2 + (1-sig2)*(bet1-bet2)/(sig1-sig2);
		if abs(bet3)<10*eps,	save .newuberr
			disp( '   Please send .newuberr to MPN & PMY')
			error('   Problem in newub.m')
		end % if abs(bet3
        sM = M2*bet3;
        sig3 = norm(sM - gam2);
        if sig3<1
                ub = min([ub 1/bet3]);
		if (sig1-sig3)<10*eps
			bnds(1) = ub;   alpha = ub;     return
		end % if (sig1
		bet4 = bet3 + (1-sig3)*(bet1-bet3)/(sig1-sig3);
		    if abs(bet4)<10*eps,	save .newuberr
			disp( '   Please send .newuberr to MPN & PMY')
		        error('   Problem in newub.m')
		    end % if abs(bet4
                alpha = 1/bet4;
        else	% if sig3<1
		dist = abs(ub*bet3);
		if dist>1.01
		numbi = min([ceil(log(log(dist)/log(1-bitol))/log(2)) 11]);
			for ii = 1:numbi
				dist = sqrt(dist);
				if norm((M2/(ub/dist)) - gam2)<1
					ub = ub/dist;
				end % if norm
			end % for ii
		end     % if dist
        end	% if sig3
   else	% if sig2
	ubflag = -1;
   end	% if sig2
else 	% if sig1
  	ubflag = -2;
        ub = min([ub,1/bet1]);
end	% if sig1
alpha = min([alpha,ub]);

end	% if bitol
bnds(1) = ub;