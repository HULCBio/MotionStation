function [mubnd,var,dc,dr,gcr,grc] = bub(m,blk,Dinitbnd,Ginitbnd,pmu,diagnose,clevel)
%function [mubnd,var,dc,dr,gcr,grc] = bub(m,blk,Dinitbnd,Ginitbnd,pmu,diagnose,clevel)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

    mth = []; lmat = []; rmat = []; pmat = []; qmat = []; xv = [];
    ma = []; wmat = []; smat = []; yv = []; mr = []; hmat = []; jmat = [];
    zv = []; sizecd = []; cmat = []; dmat = []; vv = []; csbsd = [];
    csbsdt = []; tmat = [];

    scalc = find(blk(:,1)==1 & blk(:,2)==0);
    if ~isempty(scalc)
        blk(scalc,2) = ones(length(scalc),1);
    end

    [la,ra,pa,qa,wa,sa,ha,ja,ca,da,ta,lb,rb,pb,qb,wb,sb,hb,jb,cb,db,tb,...
        tx,ty,tz,tv,dgpoint] = mucnvert(m,blk);
    fulldblks = find(dgpoint(:,1)~=0);
    fullgblks = find(dgpoint(:,2)~=0);
    scaldblks = find(dgpoint(:,5)~=0);
    scalgblks = find(dgpoint(:,6)~=0);
    [nblk,dum] = size(blk);
    [nx,dum] = size(tx);
    if nx>0
        sizex = tx(:,4);
        mthA = tx(:,5:7);
        mthB = [mthA(:,1).*tx(:,1) mthA(:,2).*tx(:,1) mthA(:,3).*tx(:,1)];
    else
        sizex = [];
        mthA = [];
        mthB = [];
    end
    [ny,dum] = size(ty);
    if ny>0
        sizey = ty(:,4);
        maA = ty(:,5);
        maB = maA.*ty(:,1);   % only want D's
    else
        sizey = [];
        maA = [];
        maB = [];
    end
    nz = 0;
    sizez = [];
    mrA = [];
    mrB = [];
    [nv,dum] = size(tv);
    if nv>0
        sizecdA = tv(:,4:5);
        sizecdB = [sizecdA(:,1).*tv(:,1) sizecdA(:,2).*tv(:,1)];
        sizecdB = tv(:,6:7);
        vlow = zeros(nv,1);
        vhigh = zeros(nv,1);
    else
        sizecdA = [];
        sizecdB = [];
    end


    vardata = [nx;ny;nz;nv;sizex;sizey];
    if nx>0
        nvarx = sizex.*(sizex+1)/2;
        axvp = cumsum([1;nvarx]);
        lxvp = cumsum([1;nvarx]);
        tnvarx = sum(nvarx);
    else
        tnvarx = 0;
        axvp = [];
        lxvp = [];
    end
    if ny>0
        nvary = sizey.*(sizey-1)/2;
        ayvp = cumsum([tnvarx+1;nvary]);
        lyvp = cumsum([1;nvary]);
        tnvary = sum(nvary);
    else
        tnvary = 0;
        ayvp = [];
        lyvp = [];
    end
    tnvarz = 0;
    zvp = [];
    if nv>0
        avvp = cumsum([tnvarx+tnvary+1;ones(nv,1)]);
        lvvp = cumsum([1;ones(nv,1)]);
    else
        avvp = [];
        lvvp = [];
    end
    nvar = tnvarx + tnvary + nv;

    if nargin == 2
        beta = 1e-4;
        Bcond = 1/beta/beta;
        gamma = 1e5;
        bmin = beta;
        % Initialize vector of unknowns - D=I, G=0;
        var = zeros(nvar,1);
        for i=1:nx
            if tx(i,1)==1
                var(axvp(i):axvp(i+1)-1) = sm2vec(eye(tx(i,4)));
            else
                var(axvp(i):axvp(i+1)-1) = sm2vec(zeros(tx(i,4)));
            end
        end
        for i=1:ny
            var(ayvp(i):ayvp(i+1)-1) = zeros(ayvp(i+1)-ayvp(i),1);
        end
        for i=1:nv
            if tv(i,1)==1
                var(avvp(i)) = 1;
            else
                var(avvp(i)) = 0;
            end
        end
        %   ALLOCATE PIMS
        dalloc = [];
        for i=1:length(fulldblks)
            blknum = fulldblks(i);
            blkdim = abs(blk(blknum,1));
            dalloc = [dalloc;[blkdim blkdim 2 blknum]];
            dalloc = [dalloc;[blkdim blkdim 3 blknum]];
        end
        Dinitbnd = allocpim(dalloc,3);
        galloc = [];
        for i=1:length(fullgblks)
            blknum = fullgblks(i);
            blkdim = abs(blk(blknum,1));
            galloc = [galloc;[blkdim blkdim 2 blknum]];
            galloc = [galloc;[blkdim blkdim 3 blknum]];
        end
        Ginitbnd = allocpim(galloc,3);
        %   FILL PIMS
        for i=1:length(fulldblks)
            blknum = fulldblks(i);
            blkdim = abs(blk(blknum,1));
            Dinitbnd = ipii(Dinitbnd,beta*eye(blkdim),2,blknum);
            Dinitbnd = ipii(Dinitbnd,(1/beta)*eye(blkdim),3,blknum);
        end
        for i=1:length(fullgblks)
            blknum = fullgblks(i);
            blkdim = abs(blk(blknum,1));
            Ginitbnd = ipii(Ginitbnd,(-gamma)*eye(blkdim),2,blknum);
            Ginitbnd = ipii(Ginitbnd,gamma*eye(blkdim),3,blknum);
        end
        for i=1:length(scaldblks)
            blknum = scaldblks(i);
            varnum = dgpoint(blknum,5);
            vlow(varnum) = beta;
            vhigh(varnum) = 1/beta;
        end
        for i=1:length(scalgblks)
            blknum = scalgblks(i);
            varnum = dgpoint(blknum,6);
            vlow(varnum) = -gamma;
            vhigh(varnum) = gamma;
        end
    else
        % fill in initial values, Dinit, stored as PIM by BKL structure number
        var = zeros(nvar,1);
        for i=1:nx
            blknum = tx(i,3);
            dim = tx(i,4);
            if tx(i,1)==1       % Dreal
                var(axvp(i):axvp(i+1)-1) = sm2vec(real(xpii(Dinitbnd,1,blknum)));
            else                % Greal
                var(axvp(i):axvp(i+1)-1) = sm2vec(real(xpii(Ginitbnd,1,blknum)));
            end
        end
        for i=1:ny
            blknum = ty(i,3);
            dim = ty(i,4);
            if ty(i,1)==1       % Dimag
                var(ayvp(i):ayvp(i+1)-1) = ssm2vec(imag(xpii(Dinitbnd,1,blknum)));
            else                % Gimag
                var(ayvp(i):ayvp(i+1)-1) = ssm2vec(imag(xpii(Ginitbnd,1,blknum)));
            end
        end
        for i=1:nv
            blknum = tv(i,3);
            if tv(i,1)==1
                var(avvp(i)) = real(xpii(Dinitbnd,1,blknum));
            else
                var(avvp(i)) = real(xpii(Ginitbnd,1,blknum));
            end
        end
        bmin = inf;
        for i=1:length(scaldblks)
            blknum = scaldblks(i);
            dlow = real(xpii(Dinitbnd,2,blknum));
            if dlow<bmin
                bmin = dlow;
            end
            dhigh = real(xpii(Dinitbnd,3,blknum));
            varnum = dgpoint(blknum,5);
            vlow(varnum) = dlow;
            vhigh(varnum) = dhigh;
        end
        for i=1:length(scalgblks)
            blknum = scalgblks(i);
            glow = real(xpii(Ginitbnd,2,blknum));
            ghigh = real(xpii(Ginitbnd,3,blknum));
            varnum = dgpoint(blknum,6);
            vlow(varnum) = glow;
            vhigh(varnum) = ghigh;
        end
        for i=1:length(fulldblks)
            blknum = fulldblks(i);
            dlow = xpii(Dinitbnd,2,blknum);
            mind = min(real(eig(dlow)));
            if mind<bmin
                bmin = mind;
            end
            beta = .001;
        end
    end
    xv = var(1:tnvarx);
    yv = var(tnvarx+1:tnvarx+tnvary);
    zv = [];
    vv = var(tnvarx+tnvary+1:nvar);

    [amiAmat] = amevlp(vardata, mthA, la, ra, pa, qa, xv, ...
                            maA, wa, sa, yv, ...
                            mrA, ha, ja, zv, ...
                            sizecdA, ca, da, vv, [ca da], [ca';da'], ...
                            ta, [1 1]);
    [amiBmat] = amevlp(vardata, mthB, lb, rb, pb, qb, xv, ...
                            maB, wb, sb, yv, ...
                            mrB, hb, jb, zv, ...
                            sizecdB, cb, db, vv, [cb db], [cb';db'], ...
                            tb, [1 1]);
    lam = max(real(eig(amiAmat,amiBmat)));
    if diagnose==1
        disp(['sqrt(Lamda) = ' num2str(sqrt(lam))]);
    end
    fac = 5;

    lambda = 1.001*lam;

    [mthAn, lan, ran, pan, qan, maAn, wan, san, ...
            mrAn, han, jan, sizecdAn, can, dan, tan] = ...
        mamiscl(mthA, la, ra, pa, qa, maA, wa, sa, ...
            mrA, ha, ja, sizecdA, ca, da, ta, -1);
    [mth,lmat,rmat,pmat,qmat,ma,wmat,smat,...
            mr,hmat,jmat,sizecd,cmat,dmat,tmat] = ...
        mamilc(mthAn,lan,ran,pan,qan,maAn,wan,san,...
                mrAn,han,jan,sizecdAn,can,dan,tan,...
                mthB,lb,rb,pb,qb,maB,wb,sb,...
                mrB,hb,jb,sizecdB,cb,db,tb,lambda,vardata);
    cnt = 0;
    maingo = 1;
    lastlam = inf;
    resetbad = 0;
    abstop = 0;
    lastiters = inf;
    [dldp,dhlp] = helpxpii(Dinitbnd);
    [gldp,ghlp] = helpxpii(Ginitbnd);
    cada = [ca da];
    cadat = [ca';da'];
    cbdb = [cb db];
    cbdbt = [cb';db'];
    lowerbnd = 0;

while (maingo == 1 | cnt<2) & resetbad<2 & abstop==0
    cnt = cnt+1;
    gogo = 1;
    iter = 0;
    qc = 0;
    lastdelta = inf;
    csbsd = [cmat dmat];
    csbsdt = csbsd';
    while gogo==1 & iter<(2*lastiters+5)
        iter = iter + 1;
        [amimat,F,G,H] = amevlp(vardata, mth, lmat, rmat, pmat, qmat, xv, ...
                            ma, wmat, smat, yv, ...
                            mr, hmat, jmat, zv, ...
                            sizecd, cmat, dmat, vv, csbsd, csbsdt, ...
                            tmat, [0 1]);
        Fall = fac*F;
        Gall = fac*G;
        Hall = fac*H;

        % Gradient/Hessian from Variable Bounds
        for i=1:length(fulldblks)
            blknum = fulldblks(i);
            dx = dgpoint(blknum,1);
            dy = dgpoint(blknum,3);
            lnum = 2 + dldp*(blknum-1);
            dbnd = zeros(dhlp(lnum,3),dhlp(lnum,4));
            dbnd(:) = Dinitbnd(dhlp(lnum,1):dhlp(lnum,2));
            [Gallb,Hallb,mat,mati] = amilowxy(vardata,var,dx,dy,...
                real(dbnd),imag(dbnd),Gall,Hall);
            Gall = Gallb;
            Hall = Hallb;
            hnum = 3 + dldp*(blknum-1);
            dbnd(:) = Dinitbnd(dhlp(hnum,1):dhlp(hnum,2));
            [Gallb,Hallb,mat,mati] = amiuppxy(vardata,var,dx,dy,...
                real(dbnd),imag(dbnd),Gall,Hall);
            Gall = Gallb;
            Hall = Hallb;
        end
        for i=1:length(fullgblks)
            blknum = fullgblks(i);
            gx = dgpoint(blknum,2);
            gy = dgpoint(blknum,4);
            lnum = 2 + gldp*(blknum-1);
            gbnd = zeros(ghlp(lnum,3),ghlp(lnum,4));
            gbnd(:) = Ginitbnd(ghlp(lnum,1):ghlp(lnum,2));
            [Gallb,Hallb,mat,mati] = amilowxy(vardata,var,gx,gy,...
                real(gbnd),imag(gbnd),Gall,Hall);
            Gall = Gallb;
            Hall = Hallb;
            hnum = 3 + gldp*(blknum-1);
            gbnd(:) = Ginitbnd(ghlp(hnum,1):ghlp(hnum,2));
            [Gallb,Hallb,mat,mati] = amiuppxy(vardata,var,gx,gy,...
                real(gbnd),imag(gbnd),Gall,Hall);
            Gall = Gallb;
            Hall = Hallb;
        end
        if nv>0
            [ff,Gallb,Hallb,mat,mati] = amibndv(vardata,var,vlow,vhigh,Gall,Hall);
            Gall = Gallb;
            Hall = Hallb;
        end
        step = Hall\Gall;
        delta = abs(sqrt(Gall'*step));
        if delta <= 0.25
            qc = 1;
            var = var - step;
            if delta>2*lastdelta*lastdelta
                %if diagnose==1
                %    disp('Warning: Quadratic Convergence Lost, stopping optimization...');
                %end
                gogo = 0;
            end
            lastdelta = delta;
        else
            var = var - step/(1+delta);
        end
        % disp([cnt iter delta sqrt(lambda) sqrt(lowerbnd)])
        xv = var(1:tnvarx);
        yv = var(tnvarx+1:tnvarx+tnvary);
        zv = [];
        vv = var(tnvarx+tnvary+1:nvar);
        if delta < .001
            gogo = 0;
        end
    end
    if iter<(2*lastiters+5)
        [amiAmat] = amevlp(vardata, mthA, la, ra, pa, qa, xv, ...
                            maA, wa, sa, yv, ...
                            mrA, ha, ja, zv, ...
                            sizecdA, ca, da, vv, cada, cadat, ...
                            ta, [1 1]);
        [amiBmat] = amevlp(vardata, mthB, lb, rb, pb, qb, xv, ...
                            maB, wb, sb, yv, ...
                            mrB, hb, jb, zv, ...
                            sizecdB, cb, db, vv, cbdb, cbdbt, ...
                            tb, [1 1]);
        traceU = fac*sum(sum(diag(inv(amimat))));
        lowerbnd = max([lambda-nvar/traceU/bmin pmu*pmu]);
        lam = max(real(eig(amiAmat,amiBmat)));
        if lam<lastlam
            bestvar = var;
        else
            maingo = 0;
            abstop = 1;
        end
        llfac = .9945 + .0005*clevel;
        if lam<llfac*lastlam
            resetbad = 0;
        else
            resetbad = resetbad+1;
        end
        mutol = .004375 - .000375*clevel;
        if (lam-lowerbnd) < 2*lowerbnd*mutol
            maingo = 0;
            mubnd = sqrt(lam);
        end
        if lam<=1e-10
            lam = 1e-10;
            maingo = 0;
            abstop = 1;
            if lam<=0
                mubnd = 0;
            else
                mubnd = sqrt(lam);
            end
            lam = mubnd*mubnd;
        end
        theta = 0.01;
        lambda = (1-theta)*lam + theta*lambda;
        [mth, lmat, rmat, pmat, qmat, ma, wmat, smat, ...
                mr, hmat, jmat, sizecd, cmat, dmat, tmat] = ...
            mamilc(mthAn, lan, ran, pan, qan, maAn, wan, san, ...
                mrAn, han, jan, sizecdAn, can, dan, tan, ...
                mthB, lb, rb, pb, qb, maB, wb, sb, ...
                mrB, hb, jb, sizecdB, cb, db, tb, lambda, vardata);
        lastlam = lam;
        lastiters = iter;
    else
        % convergence problems, bail out with previous values
        abstop = 1;
    end
end

[X,Y,Z,V] = amiq2sol(bestvar,nx,sizex,lxvp,tnvarx,...
                ny,sizey,lyvp,tnvary,0,[],[],0,nv);
[nblk,dum] = size(blk);
blkp = ptrs(abs(blk));
mcolp = blkp(:,1);
mrowp = blkp(:,2);
nc = mcolp(nblk+1)-1;
nr = mrowp(nblk+1)-1;
dr = zeros(nr,nr);
dc = zeros(nc,nr);
gcr = zeros(nc,nr);
grc = zeros(nr,nc);
for i=1:nblk
    if dgpoint(i,1)>0 & dgpoint(i,2)>0  % real repeated
        dreal = xpii(X,dgpoint(i,1));
        dimag = xpii(Y,dgpoint(i,3));
        greal = xpii(X,dgpoint(i,2));
        gimag = xpii(Y,dgpoint(i,4));
        dr(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dreal + sqrt(-1)*dimag;
        dc(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dreal + sqrt(-1)*dimag;
        gcr(mcolp(i):mcolp(i+1)-1,mrowp(i):mrowp(i+1)-1) = greal + sqrt(-1)*gimag;
        grc(mrowp(i):mrowp(i+1)-1,mcolp(i):mcolp(i+1)-1) = greal + sqrt(-1)*gimag;
    elseif  dgpoint(i,1)>0 & dgpoint(i,2)==0  % complex repeated
        dreal = xpii(X,dgpoint(i,1));
        dimag = xpii(Y,dgpoint(i,3));
        dr(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dreal + sqrt(-1)*dimag;
        dc(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dreal + sqrt(-1)*dimag;
    elseif  dgpoint(i,5)>0 & dgpoint(i,6)>0  % scalar real, must be 1x1
        dreal = V(dgpoint(i,5));
        greal = V(dgpoint(i,6));
        dr(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dreal;
        dc(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dreal;
        gcr(mcolp(i):mcolp(i+1)-1,mrowp(i):mrowp(i+1)-1) = greal;
        grc(mrowp(i):mrowp(i+1)-1,mcolp(i):mcolp(i+1)-1) = greal;
    elseif  dgpoint(i,5)>0 & dgpoint(i,6)==0  % full complex
        rdim = blk(i,2);
        cdim = blk(i,1);
        dreal = V(dgpoint(i,5));
        dr(mrowp(i):mrowp(i+1)-1,mrowp(i):mrowp(i+1)-1) = dreal*eye(rdim);
        dc(mcolp(i):mcolp(i+1)-1,mcolp(i):mcolp(i+1)-1) = dreal*eye(cdim);
    end
end
mubnd = sqrt(lam);