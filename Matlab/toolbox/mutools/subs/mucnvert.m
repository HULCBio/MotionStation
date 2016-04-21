%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [lmata,rmata,pmata,qmata,wmata,smata,hmata,jmata,cmata,dmata,tmata,...
          lmatb,rmatb,pmatb,qmatb,wmatb,smatb,hmatb,jmatb,cmatb,dmatb,tmatb,...
            tablex,tabley,tablez,tablev,dgpoint] = ...
            mucnvert(m,blk)

    [nblk,dum] = size(blk);
    [nr,nc] = size(m);
    mr = real(m);
    mi = imag(m);
    mrmi = [mr mi];
    minmr = [mi -mr];
    zeroeye = [zeros(nc,nc) eye(nc,nc)];
    eyezero = [eye(nc,nc) zeros(nc,nc)];
    nx = 0;
    ny = 0;
    nv = 0;
    lpa = 1;
    ppa = 1;
    qpa = 1;
    cpa = 1;
    dpa = 1;
    spa = 1;
    wpa = 1;
    lpb = 1;
    cpb = 1;
    spb = 1;
    wpb = 1;
    mrp = 1;

    rm = 1;
    cm = 1;
    dgpoint = zeros(nblk,6);

    for i=1:nblk
        if blk(i,1)<0 & blk(i,2) == 0
            if abs(blk(i,1)) > 1    % repeated real
                dim = abs(blk(i,1));
                % D-blocks
                nx = nx + 1;
                ny = ny + 1;
                lpa = lpa + 2*dim;
                wpa = wpa + dim;
                spa = spa + dim;
                lpb = lpb + 2*dim;
                wpb = wpb + dim;
                spb = spb + dim;
                %   G-blocks
                nx = nx + 1;
                ny = ny + 1;
                ppa = ppa + 2*dim;
                qpa = qpa + 2*dim;
                wpa = wpa + 2*dim;
                spa = spa + 2*dim;
                rm = rm + dim;
                cm = cm + dim;
                dgpoint(i,:) = [nx-1 nx ny-1 ny 0 0];
            elseif abs(blk(i,1))==1 % scalar real
                dim = abs(blk(i,1));
                % d block
                nv = nv + 1;
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                % g block
                nv = nv + 1;
                avec = mr(rm,:)';
                bvec = mi(rm,:)';
                nab = bvec'*bvec + avec'*avec;
                ai = avec(cm);
                bi = bvec(cm);
                ei = zeros(nc,1);
                zrvec = ei;
                ei(cm) = 1;
                ww = [-bi -ai 1 0;ai -bi 0 1;nab 0 -bi ai;0 nab -ai -bi];
                [evc,evl] = eig(ww);
                rkw = rank(ww);
                devl = diag(evl);
                [evls,evlidx] = sort(abs(devl)); % smallest to largest
                keeps = evlidx(4-rkw+1:4);
                devlk = devl(keeps);
                evck = evc(:,keeps);
                %format short e
                %[devl devl>0 devl<0]
                ploc = find(devlk>0);
                nloc = find(devlk<0);
                % ['Pos' int2str(length(ploc)) ':Neg=' int2str(length(nloc))]
                cpa = cpa + length(ploc);
                dpa = dpa + length(nloc);
                rm = rm + dim;
                cm = cm + dim;
                dgpoint(i,:) = [0 0 0 0 nv-1 nv];
            else
                error('Bad Block')
                return
            end
        elseif blk(i,2) == 0
            if blk(i,1) > 1    % repeated complex
                dim = blk(i,1);
                nx = nx + 1;
                ny = ny + 1;
                lpa = lpa + 2*dim;
                wpa = wpa + dim;
                spa = spa + dim;
                lpb = lpb + 2*dim;
                wpb = wpb + dim;
                spb = spb + dim;
                rm = rm + dim;
                cm = cm + dim;
                dgpoint(i,:) = [nx 0 ny 0 0 0];
            elseif blk(i,1)==1 % scalar complex
                dim = blk(i,1);
                nv = nv + 1;
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                rm = rm + dim;
                cm = cm + dim;
                dgpoint(i,:) = [0 0 0 0 nv 0];
            else
                error('Bad Block')
                return
            end
        else                    % full complex
            dim1 = blk(i,1);
            dim2 = blk(i,2);
            nv = nv + 1;
            cpa = cpa + 2*dim2;
            cpb = cpb + 2*dim1;
            rm = rm + dim2;
            cm = cm + dim1;
            dgpoint(i,:) = [0 0 0 0 nv 0];
        end
    end

    lmata = zeros(lpa-1,2*nc);
    pmata = zeros(ppa-1,2*nc);
    qmata = zeros(qpa-1,2*nc);
    wmata = zeros(wpa-1,2*nc);
    smata = zeros(spa-1,2*nc);
    cmata = zeros(2*nc,cpa-1);
    dmata = zeros(2*nc,dpa-1);
    tmata = zeros(2*nc,2*nc);
    lmatb = zeros(lpb-1,2*nc);
    wmatb = zeros(wpb-1,2*nc);
    smatb = zeros(spb-1,2*nc);
    cmatb = zeros(2*nc,cpb-1);
    tmatb = zeros(2*nc,2*nc);

    tablex = zeros(nx,7);
    tabley = zeros(ny,5);
    tablev = zeros(nv,7);
    nx = 0;
    ny = 0;
    nv = 0;
    lpa = 1;
    ppa = 1;
    qpa = 1;
    cpa = 1;
    dpa = 1;
    spa = 1;
    wpa = 1;
    lpb = 1;
    cpb = 1;
    spb = 1;
    wpb = 1;
    mrp = 1;
    mcp = 1;

    for i=1:nblk
        if blk(i,1)<0 & blk(i,2) == 0
            if abs(blk(i,1)) > 1    % repeated real
                dim = abs(blk(i,1));
                % D-blocks
                nx = nx + 1;
                ny = ny + 1;
                tablex(nx,:) = [1 0 i dim 2 0 0];   % real part of D
                tabley(ny,:) = [1 0 i dim 1];   % imag part of D
                % A part
                lmata(lpa:lpa+dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                lmata(lpa+dim:lpa+2*dim-1,:) = minmr(mrp:mrp+dim-1,:);
                smata(spa:spa+dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = -minmr(mrp:mrp+dim-1,:);
                % B part
                lmatb(lpb:lpb+dim-1,:) = eyezero(mcp:mcp+dim-1,:);
                lmatb(lpb+dim:lpb+2*dim-1,:) = zeroeye(mcp:mcp+dim-1,:);
                smatb(spb:spb+dim-1,:) = eyezero(mcp:mcp+dim-1,:);
                wmatb(wpb:wpb+dim-1,:) = zeroeye(mcp:mcp+dim-1,:);
                lpa = lpa + 2*dim;
                wpa = wpa + dim;
                spa = spa + dim;
                lpb = lpb + 2*dim;
                wpb = wpb + dim;
                spb = spb + dim;
                %   G-blocks
                nx = nx + 1;
                ny = ny + 1;
                tablex(nx,:) = [0 1 i dim 0 0 2];   % real part of G
                tabley(ny,:) = [0 1 i dim 2];   % imag part of G

                pmata(ppa:ppa+dim-1,:) = minmr(mrp:mrp+dim-1,:);
                pmata(ppa+dim:ppa+2*dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                qmata(qpa:qpa+dim-1,:) = -eyezero(mcp:mcp+dim-1,:);
                qmata(qpa+dim:qpa+2*dim-1,:) = -zeroeye(mcp:mcp+dim-1,:);

                smata(spa:spa+dim-1,:) = -eyezero(mcp:mcp+dim-1,:);
                smata(spa+dim:spa+2*dim-1,:) = -zeroeye(mcp:mcp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                wmata(wpa+dim:wpa+2*dim-1,:) = -minmr(mrp:mrp+dim-1,:);

                ppa = ppa + 2*dim;
                qpa = qpa + 2*dim;
                wpa = wpa + 2*dim;
                spa = spa + 2*dim;
                mrp = mrp + dim;
                mcp = mcp + dim;
            elseif abs(blk(i,1))==1 % scalar real
                dim = abs(blk(i,1));
                % D BLOCK
                nv = nv + 1;
                tablev(nv,:) = [1 0 i 2*dim 0 2*dim 0];   % scalar d
                cmata(:,cpa:cpa+dim-1) = mrmi(mrp:mrp+dim-1,:)';
                cmata(:,cpa+dim:cpa+2*dim-1) = minmr(mrp:mrp+dim-1,:)';
                cmatb(:,cpb:cpb+dim-1) = eyezero(mcp:mcp+dim-1,:)';
                cmatb(:,cpb+dim:cpb+2*dim-1) = zeroeye(mcp:mcp+dim-1,:)';
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                % G BLOCK
                nv = nv + 1;
                avec = mr(mrp,:)';
                bvec = mi(mrp,:)';
                nab = bvec'*bvec + avec'*avec;
                ai = avec(mcp);
                bi = bvec(mcp);
                ei = zeros(nc,1);
                zrvec = ei;
                ei(mcp) = 1;
                fixmat = [bvec avec -ei zrvec;-avec bvec zrvec -ei];
                nfix = [-ei' zrvec';zrvec' -ei';bvec' -avec';avec' bvec'];
                rkw = rank(nfix*fixmat);
                [eec,eel] = eig(fixmat*nfix);
                deel = diag(eel);
                [evls,evlidx] = sort(-abs(deel));    % largest to smallest
                keeps = evlidx(1:rkw);
                devlk = deel(keeps);
                evck = eec(:,keeps);
                pploc = find(devlk>0);
                nnloc = find(devlk<0);
                shouldz = fixmat*nfix;
                if length(pploc)>0
                    Cpart = evck(:,pploc)*diag(sqrt(devlk(pploc)));
                    cmata(:,cpa:cpa+length(pploc)-1) = Cpart;
                    shouldz = shouldz - Cpart*Cpart';
                end
                if length(nnloc)>0
                    Dpart = evck(:,nnloc)*diag(sqrt(abs(devlk(nnloc))));
                    dmata(:,dpa:dpa+length(nnloc)-1) = Dpart;
                    shouldz = shouldz + Dpart*Dpart';
                end
                tablev(nv,:) = [0 1 i length(pploc) length(nnloc) 0 0];% scalar g
                % NEXT SHOULD BE ZERO
                % shouldz
                cpa = cpa + length(pploc);
                dpa = dpa + length(nnloc);
                mrp = mrp + dim;
                mcp = mcp + dim;
            else
                error('Bad Block')
                return
            end
        elseif blk(i,2) == 0
            if blk(i,1) > 1    % repeated complex
                dim = blk(i,1);
                nx = nx + 1;
                ny = ny + 1;
                tablex(nx,:) = [1 0 i dim 2 0 0];   % real part of D
                tabley(ny,:) = [1 0 i dim 1];   % imag part of D
                % A part
                lmata(lpa:lpa+dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                lmata(lpa+dim:lpa+2*dim-1,:) = minmr(mrp:mrp+dim-1,:);
                smata(spa:spa+dim-1,:) = mrmi(mrp:mrp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = -minmr(mrp:mrp+dim-1,:);
                % B part
                lmatb(lpb:lpb+dim-1,:) = eyezero(mcp:mcp+dim-1,:);
                lmatb(lpb+dim:lpb+2*dim-1,:) = zeroeye(mcp:mcp+dim-1,:);
                smatb(spb:spb+dim-1,:) = eyezero(mcp:mcp+dim-1,:);
                wmatb(wpb:wpb+dim-1,:) = zeroeye(mcp:mcp+dim-1,:);
                lpa = lpa + 2*dim;
                wpa = wpa + dim;
                spa = spa + dim;
                lpb = lpb + 2*dim;
                wpb = wpb + dim;
                spb = spb + dim;
                mrp = mrp + dim;
                mcp = mcp + dim;
            elseif blk(i,1)==1 % scalar complex
                dim = blk(i,1);
                nv = nv + 1;
                tablev(nv,:) = [1 0 i 2*dim 0 2*dim 0];  % scalar d
                cmata(:,cpa:cpa+dim-1) = mrmi(mrp:mrp+dim-1,:)';
                cmata(:,cpa+dim:cpa+2*dim-1) = minmr(mrp:mrp+dim-1,:)';
                cmatb(:,cpb:cpb+dim-1) = eyezero(mcp:mcp+dim-1,:)';
                cmatb(:,cpb+dim:cpb+2*dim-1) = zeroeye(mcp:mcp+dim-1,:)';
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                mrp = mrp + dim;
                mcp = mcp + dim;
            else
                error('Bad Block')
                return
            end
        else
            dim1 = blk(i,1);
            dim2 = blk(i,2);
            nv = nv + 1;
            tablev(nv,:) = [1 0 i 2*dim2 0 2*dim1 0];
            cmata(:,cpa:cpa+dim2-1) = mrmi(mrp:mrp+dim2-1,:)';
            cmata(:,cpa+dim2:cpa+2*dim2-1) = minmr(mrp:mrp+dim2-1,:)';
            cmatb(:,cpb:cpb+dim1-1) = eyezero(mcp:mcp+dim1-1,:)';
            cmatb(:,cpb+dim1:cpb+2*dim1-1) = zeroeye(mcp:mcp+dim1-1,:)';
            cpa = cpa + 2*dim2;
            cpb = cpb + 2*dim1;
            mrp = mrp + dim2;
            mcp = mcp + dim1;
        end
    end

    nz = 0;
    tablez = [];
    rmata = [];
    hmata = [];
    jmata = [];
    rmatb = [];
    pmatb = [];
    qmatb = [];
    hmatb = [];
    jmatb = [];
    dmatb = [];