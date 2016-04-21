% function [dsysl,dsysr] = msf(clpg,bnds,dvec,sens,blk,diagnos,dflag)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [dsysl,dsysr] = msf(clpg,bnds,dvec,sens,blk,diagnos,dflag)

 if nargin == 5
    diagnos = [];
    dflag = [];
 elseif nargin==6
    dflag = [];
 end

 if isempty(diagnos)
    diagnos = 0;
 end
 if isempty(dflag)
    dflag = 0;  % continuous
 end
 lmagax = 'liv,lm';
 magax = 'liv,m';
 phax = 'liv,p';
 if dflag~=0
    lmagax = 'iv,lm';
    magax = 'iv,m';
    phax = 'iv,p';
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
 dsize = ones(nblk,1);
 if ~isempty(rp)
    bdim(rp,2) = blk(rp,1);
    dsize(rp) = blk(rp,1).*blk(rp,1);
 end
 bp = cumsum([1 1;bdim]);
 pimp = cumsum([1;dsize]);

 [nblk,dum] = size(blk);
 [mtype,mrow,mcol,mnum] = minfo(dvec);
 nd = mcol;
 omega = getiv(dvec);
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
 dmatlorig = dmatl;
 dmatrorig = dmatr;
 currentdl = dmatl;
 currentdr = dmatr;
 syspim = [];
 cursclmat = mmult(currentdl,vrdiv(clpg,currentdr));
 cursclbnd = vnorm(cursclmat);

 if diagnos == 1
    clf
    for i=1:nblk
        si = int2str(i);
        rp = bp(i,2);
        cp = bp(i,1);
        if blk(i,2) == 0 & blk(i,1) > 1
        for j=1:blk(i,1)
         sj = int2str(j);
         for k=1:blk(i,1)
          sk = int2str(k);
          leftrow = rp + j - 1;
          leftcol = rp + k - 1;
          rightrow = cp + j - 1;
          rightcol = cp + k - 1;
          lo = sel(dmatlorig,leftrow,leftcol);
          ln = sel(dmatl,leftrow,leftcol);
          ro = sel(dmatrorig,rightrow,rightcol);
          rn = sel(dmatr,rightrow,rightcol);
          vplot('bode',lo,ln,ro,rn);
          title(['Block ' si '[' sj ' ' sk ']']);
          disp('Paused...');pause;disp('Running...')
         end
        end
        end
    end
    clf
    vplot(magax,sel(bnds,1,1),cursclbnd)
    title('DIAGNOSIS: Mu Upper Bounds and Scaled(GenPhase) Bounds')
    disp('Paused...');pause;disp('Running...')
    clf
 end

 clf
 if isempty(rp)
    comparebnds = axes('position',[.1 .72 .85 .23]);
    plotmag = axes('position',[.1 .41 .85 .23]);
    plotsens = axes('position',[.1 .1 .85 .23]);
 else
    comparebnds = axes('position',[.1 .6 .35 .35]);
    plotmag = axes('position',[.6 .6 .35 .35]);
    plotphase = axes('position',[.6 .1 .35 .35]);
    plotphasehidden = axes('position',[.6 .1 .35 .35],'visible','off',...
        'xlim',[0 1],'ylim',[0 1]);
        hiddentext = text(.5,.5,'No Phase');
        set(hiddentext,'visible','off','horizontalalignment','center');
    plotsens = axes('position',[.1 .1 .35 .35]);
 end

 maxord = 5;
 perctol = 1.03;
 op = 'onlydata';
 iblk = 1;
 irow = 1;
 icol = 1;
 % ord = -1;
 gostop = 1;
 skipchoice = 0;
 firsttime = 1;
 m1 = [];
 m2 = [];
 fitstat = zeros(pimp(nblk+1)-1,1);
 axes(comparebnds);
 vplot(magax,cursclbnd,'--');
 while gostop
    pimpointer = pimp(iblk) + (icol-1)*blk(iblk,1) + (irow-1);
    lfr = bp(iblk,2) + irow - 1;
    lfc = bp(iblk,2) + icol - 1;
    rir = bp(iblk,1) + irow - 1;
    ric = bp(iblk,1) + icol - 1;
    data = sel(dmatl,lfr,lfc);
    wt = sel(sens,1,iblk);
    if strcmp(op,'changedisplay')
        disp(m1);
        sys = xpii(syspim,pimpointer);
        curord = xnum(sys);
        sysg = frsp(sys,data,dflag);
        if curord >= 0
            tt = ['Block[' int2str(iblk) '], Element[' int2str(irow) ' ' int2str(icol) ...
                    '], Order[' int2str(curord) ']'];
        else
            tt = ['(' int2str(iblk) ';' int2str(irow) ' ' int2str(icol) ...
                    ':' 'd)'];
        end
        axes(plotmag)
            vplot(lmagax,data,'-',sysg,'--');
            title(['Magnitude Data and Fit: ' tt])
        if blk(iblk,2)==0 & blk(iblk,1) > 1 & length(rp)>0
            axes(plotphase)
            vplot(phax,data,'-',sysg,'--');
            title(['Phase Data and Fit'])
            set(plotphase,'visible','on');
            set(hiddentext,'visible','off')
        elseif length(rp)>0
            set(plotphase,'visible','off');
            delete(get(plotphase,'children'))
            set(hiddentext,'visible','on')
        end
        axes(plotsens)
            vplot(lmagax,wt);
            title(['Sensitivity'])
        disp(m2);
    elseif strcmp(op,'newfit')
        disp(m1);
        sys = fitsys(data,ord,wt,[],[],dflag);
        curord = ord;
        syspim = ipii(syspim,sys,pimpointer);
        fitstat(pimpointer) = 1;
        sysg = frsp(sys,omega,dflag);
        if blk(iblk,2) == 0
            currentdl = massign(currentdl,lfr,lfc,sysg);
            currentdr = massign(currentdr,rir,ric,sysg);
        else
            lind = bp(iblk,2):bp(iblk+1,2)-1;
            rind = bp(iblk,1):bp(iblk+1,1)-1;
            ll = vdiag(mmult(sysg,ones(1,blk(iblk,2))));
            rr = vdiag(mmult(sysg,ones(1,blk(iblk,1))));
            currentdl = massign(currentdl,lind,lind,ll);
            currentdr = massign(currentdr,rind,rind,rr);
        end
        cursclmat = mmult(currentdl,vrdiv(clpg,currentdr));
        cursclbnd = vnorm(cursclmat);
        axes(comparebnds);
            vplot(magax,sel(bnds,1,1),'-',cursclbnd,'--');
            title('Scaled Bound and MU')
        axes(plotmag)
            vplot(lmagax,data,'-',sysg,'--');
            tt = ['(' int2str(iblk) ';' int2str(irow) ' ' int2str(icol) ...
                    ':' int2str(curord) ')'];
            title(['Mag Data and Fit: ' tt])
        if blk(iblk,2)==0 & blk(iblk,1) > 1 & length(rp)>0
            axes(plotphase)
            vplot(phax,data,'-',sysg,'--');
            title(['Phase Data and Fit'])
            set(plotphase,'visible','on');
            set(hiddentext,'visible','off')
        elseif length(rp)>0
            set(plotphase,'visible','off');
            delete(get(plotphase,'children'))
            set(hiddentext,'visible','on')
        end
        disp(m2);
    elseif strcmp(op,'status')
        disp(m1)
        for i=1:nblk
            si = int2str(i);
            if blk(i,2)==0
                disp(['Block ' si ':']);
                for j=1:blk(i,1)
                    str = [];
                    sj = int2str(j);
                    for k=1:blk(i,1)
                        sk = int2str(k);
                        pp=pimp(i)+(j-1)*blk(i,1)+(k-1);
                        ind_d = xpii(syspim,pp);
                        if isempty(ind_d)
                            os = 'data';
                        else
                            os=int2str(xnum(ind_d));
                        end
                        str=[str '  (' sj ',' sk ')=' os ';'];
                    end
                    disp(['      ' str]);
                end
            else
                pp=pimp(i);
                ind_d = xpii(syspim,pp);
                if isempty(ind_d)
                    os = 'data';
                else
                    os = int2str(xnum(ind_d));
                end
                disp(['Block ' si ': ' os]);
            end
        end
        disp(['AutoPrefit Fit Tolerance: ' num2str(perctol)]);
        disp(['AutoPrefit Maximum Order: ' int2str(maxord)]);
        disp(m2)
    elseif strcmp(op,'onlydata')
        disp(m1);
        curord = -1;
        tt = ['(' int2str(iblk) ';' int2str(irow) ' ' int2str(icol) ...
            ':' 'd)'];
        if firsttime == 1
            firsttime = 0;
            axes(comparebnds);
            vplot(magax,sel(bnds,1,1),'-');
            title('MU Upper Bound')
        end
        axes(plotmag)
            vplot(lmagax,data,'-');
            title(['Magnitude Data: ' tt])
        if blk(iblk,2)==0 & blk(iblk,1) > 1 & length(rp)>0
            axes(plotphase)
            vplot(phax,data,'-');
            title(['Phase Data'])
            set(plotphase,'visible','on');
            set(hiddentext,'visible','off')
        elseif length(rp)>0
            set(plotphase,'visible','off');
            delete(get(plotphase,'children'))
            set(hiddentext,'visible','on')
        end
        axes(plotsens)
            vplot(lmagax,wt);
            title(['Sensitivity'])
        disp(m2);
    elseif strcmp(op,'autofit')
        disp(m1)
        [syspim,fitstat,currentdl,currentdr] = ...
            mudkaf(clpg,bnds,dmatl,dmatr,sens,blk,maxord,perctol,[],dflag);
        disp(m2)
        skipchoice = 1;
    elseif strcmp(op,'hold')
        disp(m1)
        disp(m2)
    elseif strcmp(op,'tryagain')
        disp(m1);
    else
        error('Message not found')
        return
    end
    if ~skipchoice
        c = input('Enter Choice (return for list): ','s');
        if isempty(c)
            c = 'ch';
        end
        [gostop,op,iblk,ord,irow,icol,perctol,maxord,m1,m2] = ...
                    fitchose(c,blk,iblk,irow,icol,fitstat,pimp,curord,...
                perctol,maxord);
    else
        skipchoice = 0;
        op = 'changedisplay';
        gostop = 1;
        m1 = [];
        m2 = [];
        cursclmat = mmult(currentdl,vrdiv(clpg,currentdr));
        cursclbnd = vnorm(cursclmat);
        axes(comparebnds);
            vplot(magax,sel(bnds,1,1),'-',cursclbnd,'--');
            title('Scaled Bound and MU')
    end
 end

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
            if dflag==1
                smpdblk = co2di(extsmp(di2co(dblk)));
            else
                smpdblk = extsmp(dblk);
            end
            if isempty(smpdblk)
                save muerrfil
                disp('D-FIT has failed, error file named MUERRFIL has been saved');
                disp('Contact The Mathworks for mu-Tools support');
                error('Fatal error in DKIT(msf)');
                return
            end
            if diagnos == 1
                disp('D~D-Ds~Ds')
                dd1 = mmult(cjt(smpdblk),smpdblk);
                dd2 = mmult(cjt(dblk),dblk);
                if xnum(dblk) < 12  % XXX
                    linfnorm(msub(dd1,dd2),.00001)
                else
                    dd1g = frsp(dd1,omega,dflag);
                    dd2g = frsp(dd2,omega,dflag);
                    pkvnorm(msub(dd1g,dd2g))
                end
                [bdblk,hsv] = sysbal(smpdblk);  % XXX
                disp('Hankel Singular Values')
                hsv
                disp('Paused...');pause;disp('Running...')
            end
        else
            smpdblk = dblk;
        end
        smpdblkg = frsp(smpdblk,currentdl,dflag);
        if diagnos == 1
            clf
            dll = sel(currentdl,ls:le,ls:le);
            vplot(magax,vsvd(vrdiv(dll,smpdblkg)))
            title(['DIAGNOSIS: Left SV: Block ' int2str(i)])
            disp('Paused...')
            pause
            disp('Running...')
            drr = sel(currentdr,rs:re,rs:re);
            vplot(magax,vsvd(vrdiv(drr,smpdblkg)))
            title(['DIAGNOSIS: Right SV: Block ' int2str(i)])
            disp('Paused...');pause;disp('Running...')
            clf
        end
        dsysl = daug(dsysl,smpdblk);
        dsysr = daug(dsysr,smpdblk);
    else
        dblk = [];
        sys = xpii(syspim,pimp(i));
        if xnum(sys) > 0
            if dflag==1
                smpsys = co2di(extsmp(di2co(sys)));
            else
                smpsys = extsmp(sys);
            end
            if isempty(smpsys)
                save muerrfil
                disp('D-FIT has failed, error file named MUERRFIL has been saved');
                disp('Contact The Mathworks for mu-Tools support');
                error('Fatal error in DKIT(msf)');
                return
            end
            if diagnos == 1
                disp('d~d-ds~ds')
                % XXX
                linfnorm(msub(mmult(cjt(smpsys),smpsys),...
                    mmult(cjt(sys),sys)),.000001)
                disp('Paused...');pause;disp('Running...')
            end
        else
            smpsys = sys;
        end
        for l=1:min(blk(i,:))
            dblk = daug(dblk,smpsys);
        end
        if diagnos == 1
            smpsysg = frsp(smpsys,currentdl,dflag);
            clf
            dll = sel(currentdl,ls,ls);
            vplot(magax,vabs(vrdiv(dll,smpsysg)))
            title(['DIAGNOSIS: Left Abs: Block ' int2str(i)])
            disp('Paused...')
            pause
            disp('Running...')
            drr = sel(currentdr,rs,rs);
            vplot(magax,vabs(vrdiv(drr,smpsysg)))
            title(['DIAGNOSIS: Right Abs: Block ' int2str(i)])
            disp('Paused...');pause;disp('Running...')
            clf
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
 if diagnos == 1
    dsyslg = frsp(dsysl,currentdl,dflag);
    clf
    vplot(magax,vsvd(vrdiv(currentdl,dsyslg)))
    title('DIAGNOSIS: Left SV: Full')
    disp('Paused...');pause;disp('Running...')
    clf
    disp('POLES of DSYSL and DSYSR')
    rifd(spoles(dsysl))
    rifd(spoles(dsysr))
    disp('Paused...');pause;disp('Running...')
    disp('POLES of minv(DSYSL) and minv(DSYSR)')
    rifd(spoles(minv(dsysl)))
    rifd(spoles(minv(dsysr)))
    disp('Paused...');pause;disp('Running and returning...')
 end