% function [syspim,fitstat,fdl,fdr] = ...
%    mudkaf(clpg,bnds,dmatl,dmatr,sens,blk,maxord,perctol,dispflag,discflag)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 function [syspim,fitstat,fdl,fdr] = ...
    mudkaf(clpg,bnds,dmatl,dmatr,sens,blk,maxord,perctol,dispflag,discflag)

 if nargin==8
    dispflag = [];
    discflag = [];
 elseif nargin==9
    discflag = [];
 end

 if isempty(dispflag)
    dispflag = 1;
 end
 if isempty(discflag)
    discflag = 0;
 end

 blk = abs(blk);    % no reals yet
 nblk = size(blk,1);
 for i=1:nblk
    if blk(i,1)==1 & blk(i,2)==0
        blk(i,2) = 1;
    end
 end

 if max(size(maxord)) ~= nblk | min(size(maxord)) ~= 1
    maxord = maxord(1)*ones(nblk,1);
 end
 bdim = blk;
 rp = find(blk(:,2)==0);
 bdim(rp,2) = blk(rp,1);
 bp = cumsum([1 1;bdim]);
 dsize = ones(nblk,1);
 dsize(rp) = blk(rp,1).*blk(rp,1);
 pimp = cumsum([1;dsize]);
 omega = getiv(dmatl);

 uppermu = vunpck(sel(bnds,1,1));
 peakmu = max(uppermu);
 lowcutoff = 0.5;    % needs to be adjustable
 lowtestval = 0.1;
 lowmu_f = find(uppermu<lowcutoff*peakmu);
 low_pts = length(lowmu_f);
 lowmu = xtracti(sel(bnds,1,1),lowmu_f);
 highmu_f = find(uppermu>=lowcutoff*peakmu);
 high_pts = length(highmu_f);
 highmu = xtracti(sel(bnds,1,1),highmu_f);

 curdl = dmatl;
 curdr = dmatr;
 fdl = dmatl;
 fdr = dmatr;
 syspim = [];
 fprintf(1,'Auto Fit in Progress \n');
 for i=1:nblk
    wt = sel(sens,1,i);
    if blk(i,2) == 0 & blk(i,1) > 1
        if dispflag == 1
            fprintf(1,'\t Block %d \n',[i]);
        end
        for j=1:blk(i,1)        % icol
            for k=1:blk(i,1)    % irow
                if dispflag == 1
                 fprintf(1,['\t \t Element[%d %d], MaxOrder=%d, Order ='],...
			[k j maxord(i)]);
                end
                pp = pimp(i) + (j-1)*blk(i,1) + (k-1);
                lfr = bp(i,2) + k - 1;
                lfc = bp(i,2) + j - 1;
                rir = bp(i,1) + k - 1;
                ric = bp(i,1) + j - 1;
                data = sel(dmatl,lfr,lfc);
                haved = 0;
                ord = 0;
                while haved == 0
                    if dispflag == 1
                        fprintf(1,' %d',[ord]);
                    end
                    sys = fitsys(data,ord,wt,[],[],discflag);
                    sysg = frsp(sys,omega,discflag);
                    curdl = massign(curdl,lfr,lfc,sysg);
                    curdr = massign(curdr,rir,ric,sysg);
                    scl_clpg = mmult(curdl,vrdiv(clpg,curdr));
                    nscl_clpg = vnorm(scl_clpg);
                    if ~isempty(lowmu_f)
                        low_nscl = xtracti(nscl_clpg,lowmu_f);
                        lowtest = ...
                          msub(low_nscl,lowmu,lowtestval*peakmu);
                    else
                        lowtest = -1;
                    end
                    high_nscl = xtracti(nscl_clpg,highmu_f);
                    hightest = msub(high_nscl,mscl(highmu,perctol));
                    if ( all(vunpck(lowtest)<0) & ...
                        all(vunpck(hightest)<0) ) | ord >= maxord(i)
                        haved = 1;
                    else
                        ord = ord+1;
                    end
                end
                if dispflag == 1
                    fprintf(1,'\n');
                end
                syspim = ipii(syspim,sys,pp);
                fdl = massign(fdl,lfr,lfc,sysg);
                fdr = massign(fdr,rir,ric,sysg);
                curdl = dmatl;
                curdr = dmatr;
            end
        end
    else
        j = 1;
        k = 1;
        if dispflag == 1
            fprintf(1,'\t Block %d, MaxOrder=%d, Order =',[i maxord(i)]);
        end
        pp = pimp(i) + (j-1)*blk(i,1) + (k-1);
        lfr = bp(i,2) + k - 1;
        lfc = bp(i,2) + j - 1;
        data = sel(dmatl,lfr,lfc);
        haved = 0;
        ord = 0;
        while haved == 0
            if dispflag == 1
                fprintf(1,' %d',[ord]);
            end
            sys = fitsys(data,ord,wt,[],[],discflag);
            sysg = frsp(sys,omega,discflag);
            lind = bp(i,2):bp(i+1,2)-1;
            rind = bp(i,1):bp(i+1,1)-1;
            ll = vdiag(mmult(sysg,ones(1,blk(i,2))));
            rr = vdiag(mmult(sysg,ones(1,blk(i,1))));
            curdl = massign(curdl,lind,lind,ll);
            curdr = massign(curdr,rind,rind,rr);
            scl_clpg = mmult(curdl,vrdiv(clpg,curdr));
            nscl_clpg = vnorm(scl_clpg);
            if ~isempty(lowmu_f)
                low_nscl = xtracti(nscl_clpg,lowmu_f);
                lowtest = ...
                  msub(low_nscl,lowmu,lowtestval*peakmu);
            else
                lowtest = -1;
            end
            high_nscl = xtracti(nscl_clpg,highmu_f);
            hightest = msub(high_nscl,mscl(highmu,perctol));
            if ( all(vunpck(lowtest)<0) & ...
                all(vunpck(hightest)<0) ) | ord >= maxord(i)
                haved = 1;
            else
                ord = ord+1;
            end
        end
        if dispflag == 1
            fprintf(1,'\n');
        end
        syspim = ipii(syspim,sys,pp);
        fdl = massign(fdl,lind,lind,ll);
        fdr = massign(fdr,rind,rind,rr);
        curdl = dmatl;
        curdr = dmatr;
    end
 end
 fitstat = ones(pimp(nblk+1)-1,1);