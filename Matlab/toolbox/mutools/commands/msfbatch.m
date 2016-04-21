% function [dsysl,dsysr] = ...
%    msfbatch(clpg,bnds,dvec,sens,blk,maxord,visflag,dflag)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [dsysl,dsysr] = ...
    msfbatch(clpg,bnds,dvec,sens,blk,maxord,visflag,dflag)

 if nargin==6
    visflag = [];
    dflag = [];
 elseif nargin==7
    dflag = [];
 end

 if isempty(visflag)
    visflag = 0;
 end
 if isempty(dflag)
    dflag = 0;
 end

 blk = abs(blk);    % no reals yet
 nblk = size(blk,1);
 for i=1:nblk
    if blk(i,1)==1 & blk(i,2)==0
        blk(i,2) = 1;
    end
 end

 bdim = blk;
 rp = find(blk(:,2)==0);
 bdim(rp,2) = blk(rp,1);
 bp = cumsum([1 1;bdim]);
 dsize = ones(nblk,1);
 dsize(rp) = blk(rp,1).*blk(rp,1);
 pimp = cumsum([1;dsize]);

 [nblk,dum] = size(blk);
 [mtype,mrow,mcol,mnum] = minfo(dvec);

[dmatl,dmatr] = unwrapd(dvec,blk);

%convert invertible D to Hermtitan, positive-definite D
 for i=1:nblk
    lind = bp(i,2):bp(i+1,2)-1;
    rind = bp(i,1):bp(i+1,1)-1;
    if blk(i,2) == 0
        invd = sel(dmatl,lind,lind);
        hpdd = vsqrtm(mmult(cjt(invd),invd));
        dmatl = massign(dmatl,lind,lind,hpdd);
        dmatr = massign(dmatr,rind,rind,hpdd);
    end
 end
%normalize through very last entry of D
 [mtype,mrow,mcol,mnum] = minfo(dmatl);
 nd = sel(dmatl,mrow,mrow);

 dmatl = sclout(dmatl,1:mrow,vinv(nd));
 [mtype,mrow,mcol,mnum] = minfo(dmatr);
 dmatr = sclout(dmatr,1:mrow,vinv(nd));

 % block-by-block GENPHASE
 for i=1:nblk
    lind = bp(i,2):bp(i+1,2)-1;
    rind = bp(i,1):bp(i+1,1)-1;
    if blk(i,2) == 0
        mrows = bdim(i,1);
        hpdd = sel(dmatl,lind,lind);
        for i=1:mrows
            sd = genphase(sel(hpdd,i,i),dflag);   % pos -> complex
            sdphz = vrdiv(sd,vabs(sd)); % complex, mag=1
            hpdd = sclout(hpdd,i,sdphz);    % scale row
        end
        dmatl = massign(dmatl,lind,lind,hpdd);
        dmatr = massign(dmatr,rind,rind,hpdd);
    else
        hpdd = sel(dmatl,lind(1),lind(1));
        scald = genphase(vabs(hpdd),dflag);
        ll = vdiag(mmult(scald,ones(1,blk(i,2))));
        rr = vdiag(mmult(scald,ones(1,blk(i,1))));
        dmatl = massign(dmatl,lind,lind,ll);
        dmatr = massign(dmatr,rind,rind,rr);
    end
 end
 currentdl = dmatl;
 currentdr = dmatr;
 syspim = [];

 perctol = 1.02;

 [syspim,fitstat,currentdl,currentdr] = ...
            mudkaf(clpg,bnds,dmatl,dmatr,sens,blk,maxord,perctol,visflag,dflag);

 % reconstruct D
 dsysl = [];
 dsysr = [];
 for i=1:nblk
    ls = bp(i,2);
    rs = bp(i,1);
    if blk(i,2) == 0
        le = bp(i+1,2)-1;
        re = bp(i+1,1)-1;
        dblk = [];
        for j=1:blk(i,1)    % col
            syscol = [];
            for k=1:blk(i,1)
                pp = pimp(i) + (j-1)*blk(i,1) + (k-1);
                syscol = abv(syscol,xpii(syspim,pp));
            end
            dblk = sbs(dblk,syscol);
        end
        if xnum(dblk) > 0
            if dflag==0
                smpdblk = extsmp(dblk);
            else
                smpdblk = co2di(extsmp(di2co(dblk)));
            end
            if isempty(smpdblk)
                save muerrfil
                disp('D-FIT has failed, error file named MUERRFIL has been saved');
                disp('Contact The Mathworks for mu-Tools support');
                error('Fatal error in DKIT(msfbatch)');
                return
            end
        else
            smpdblk = dblk;
        end
        smpdblkg = frsp(smpdblk,currentdl,dflag);
        dsysl = daug(dsysl,smpdblk);
        dsysr = daug(dsysr,smpdblk);
    else
        dblk = [];
        sys = xpii(syspim,pimp(i));
        if xnum(sys) > 0
            if dflag==0
                smpsys = extsmp(sys);
            else
                smpsys = co2di(extsmp(di2co(sys)));
            end
            if isempty(smpsys)
                save muerrfil
                disp('D-FIT has failed, error file named MUERRFIL has been saved');
                disp('Contact The Mathworks for mu-Tools support');
                error('Fatal error in DKIT(msfbatch)');
                return
            end
        else
            smpsys = sys;
        end
        for l=1:min(blk(i,:))
            dblk = daug(dblk,smpsys);
        end
        if blk(i,1)<blk(i,2)
            dsysr = daug(dsysr,dblk);
            for l=1:blk(i,2)-blk(i,1)
                dblk = daug(dblk,smpsys);
            end
            dsysl = daug(dsysl,dblk);
        elseif blk(i,1)>blk(i,2)
            dsysl = daug(dsysl,dblk);
            for l=1:blk(i,1)-blk(i,2)
                dblk = daug(dblk,smpsys);
            end
            dsysr = daug(dsysr,dblk);
        else
            dsysl = daug(dsysl,dblk);
            dsysr = daug(dsysr,dblk);
        end
    end
 end