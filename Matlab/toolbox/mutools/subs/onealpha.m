
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out,delta] = onealpha(sysg,blk,alphav,pertsize,perctol)

 [nblk,dum] = size(blk);
 [mtype,mrows,mcols,mnum] = minfo(sysg);
 cperf = blk(nblk,1);
 rperf = blk(nblk,2);
 m11row = mrows - rperf;
 m11col = mcols - cperf;
 if blk(nblk,2) == 0
   rperf = blk(nblk,1);
 end
 alphav = abs(alphav);

 xl = [];
 xu = [];
 yl = [];
 yu = [];
 delta = [];
 bestdelta = [];
 dist = inf;
 for i=1:length(alphav)
    alpha = alphav(i);
    lfac = diag([ones(1,mrows-rperf) sqrt(alpha)*ones(1,rperf)]);
    rfac = diag([ones(1,mcols-cperf) sqrt(alpha)*ones(1,cperf)]);
    malpha = mmult(lfac,sysg,rfac);
    [bnds,dvec,sens,pvec] = mu(malpha,blk,'csw');
    uppbnd = pkvnorm(sel(bnds,1,1));
    lowbnd = pkvnorm(sel(bnds,1,2));
    if abs(1/lowbnd-pertsize)/pertsize < perctol
        if strcmp(mtype,'vary')
            delta = dypert(pvec,blk,bnds,[1:nblk-1]);
            ndelta = hinfnorm(delta);
            if abs(ndelta(1,1)-pertsize) < dist
                bestdelta = delta;
                dist = abs(ndelta(1,1)-pertsize);
            end
        elseif strcmp(mtype,'cons')
            delta = unwrapp(pvec,blk);
            delta = delta(1:m11col,1:m11row);
            ndelta = norm(delta);
            if abs(ndelta-pertsize) < dist
                bestdelta = delta;
                dist = abs(ndelta-pertsize);
            end
        end
    end
    xl = [xl;1/lowbnd];
    yl = [yl;lowbnd/alpha];
    xu = [xu;1/uppbnd];
    yu = [yu;uppbnd/alpha];
 end
delta = bestdelta;
out = [xl yl xu yu];