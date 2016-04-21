% function [rowd,rowg] = a2ynrow(dar,dac,garc,gacr,blk,beta)
function [rowd,rowg] = a2ynrow(dar,dac,garc,gacr,blk,beta)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

    [nblk,dum] = size(blk);
    blkp = ptrs(abs(blk));
    mcolp = blkp(:,1);
    mrowp = blkp(:,2);
    nc = mcolp(nblk+1)-1;
    nr = mrowp(nblk+1)-1;
    dynl = zeros(nr,nr);
    dynr = zeros(nc,nc);
    gynl = zeros(nr,nr);
    gynm = zeros(nr,nc);
    gynr = zeros(nc,nc);
    dfl = zeros(nr,nr);
    dfr = zeros(nc,nc);
    gfm = zeros(nr,nc);
    gfr = zeros(nc,nc);
    cds = [];
    rds = [];
    scalds = [];
    gs = [];

    for i=1:nblk
        if blk(i,1) < -1 & blk(i,2)==0
            bd = -blk(i,1);
            da = dar(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1);
            ga = garc(mrowp(i):mrowp(i+1)-1,mcolp(i):mcolp(i+1)-1);
            df = sqrtm(da);
            gf = (1/beta)*(df\ga/df);
            dfl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = df;
            dfr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = df;
            gfm(mrowp(i):mrowp(i+1)-1,mcolp(i):mcolp(i+1)-1) = gf;
            gfr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = gf;

            [evc,evl] = eig(gf);
            gp = real(evl);
            gynl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = gp;
            gynm(mrowp(i):mrowp(i+1)-1,mcolp(i):mcolp(i+1)-1) = gp;
            gynr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = gp;
            gpd = diag(gp);
            dp = diag(sqrt(sqrt(ones(bd,1)+gpd.*gpd)))*evc'*df;
            dynr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dp;
            dynl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dp;
            gs = [gs gpd.'];
            rds = [rds (reshape(dp,bd*bd,1)).'];
        elseif blk(i,1)>1 & blk(i,2)==0
            bd = blk(i,1);
            da = dar(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1);
            df = sqrtm(da);
            dfl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = df;
            dfr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = df;
            dp = df;
            dynr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dp;
            dynl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dp;
            cds = [cds (reshape(dp,bd*bd,1)).'];
        elseif blk(i,1)>0 & blk(i,2)>0
            rdim = blk(i,2);
            cdim = blk(i,1);
            da = dar(mrowp(i),mrowp(i));
            df = sqrt(real(da));
            dfl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = df*eye(rdim);
            dfr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = df*eye(cdim);
            dp = df;
            dynr(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dp*eye(cdim);
            dynl(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dp*eye(rdim);
            scalds = [scalds dp];
        elseif  blk(i,1)==1 & blk(i,2)==0
            da = dar(mrowp(i),mrowp(i));
            df = sqrt(real(da));
            dfl(mrowp(i),mrowp(i)) = df;
            dfr(mcolp(i),mcolp(i)) = df;
            dp = df;
            dynr(mcolp(i),mcolp(i)) = dp;
            dynl(mrowp(i),mrowp(i)) = dp;
            scalds = [scalds dp];
        elseif  blk(i,1)==-1
            bd = -blk(i,1);
            da = dar(mrowp(i),mrowp(i));
            ga = real(garc(mrowp(i),mcolp(i)));
            df = sqrt(real(da));
            gf = (1/beta)*(ga/da);
            dfl(mrowp(i),mrowp(i)) = df;
            dfr(mcolp(i),mcolp(i)) = df;
            gfm(mrowp(i),mcolp(i)) = gf;
            gfr(mcolp(i),mcolp(i)) = gf;
            gp = real(gf);
            dp = sqrt(sqrt(1+gp*gp))*df;
            gynl(mrowp(i),mrowp(i)) = gp;
            gynm(mrowp(i),mcolp(i)) = gp;
            gynr(mcolp(i),mcolp(i)) = gp;
            dynr(mcolp(i),mcolp(i)) = dp;
            dynl(mrowp(i),mrowp(i)) = dp;
            gs = [gs gp];
            rds = [rds dp];
        end
    end
    rowd = [rds cds scalds];
    rowg = [gs];
%   save pmy gynl gynm gynr dynl dynr
%   save ftd dfl dfr gfm gfr