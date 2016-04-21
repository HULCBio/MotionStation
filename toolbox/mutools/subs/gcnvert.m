% function [lmata,rmata,pmata,qmata,wmata,smata,hmata,jmata,cmata,dmata,tmata,...
%          lmatb,rmatb,pmatb,qmatb,wmatb,smatb,hmatb,jmatb,cmatb,dmatb,tmatb,...
%             tablex,tabley,tablez,tablev,dgpoint] = ...
%             gcnvert(m,v,blk)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [lmata,rmata,pmata,qmata,wmata,smata,hmata,jmata,cmata,dmata,tmata,...
          lmatb,rmatb,pmatb,qmatb,wmatb,smatb,hmatb,jmatb,cmatb,dmatb,tmatb,...
            tablex,tabley,tablez,tablev,dgpoint] = ...
            gcnvert(m,v,blk)

% BUGS (see GENMU also)
%       1. does not work for case when Vperp is a row vector
%          leading to a linear problem.  This is all in the scalar G case
%       FIXED: 10/31/95

    [nblk,dum] = size(blk);
    [nr,nc] = size(m);

    [nrv ncv] = size(v);
    [qv,rv] = qr(v');
    v = (qv(:,1:nrv))';
    vperp = (qv(:,nrv+1:ncv))';

    vpr = real(vperp);
    vpi = imag(vperp);
    hr = real(m*vperp');
    hi = imag(m*vperp');

    binbr = [hi -hr];
    brbi = [hr hi];
    narai = [-vpr' vpi'];
    aiar = [vpi' vpr'];

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
                % D BLOCK
                nv = nv + 1;
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                % G BLOCK
                nv = nv + 1;
                p1vec = binbr(rm,:)';
                p2vec = brbi(rm,:)';
                q1vec = narai(cm,:)';
                q2vec = -aiar(cm,:)';
                left = [p1vec q1vec p2vec q2vec];
                right = [q1vec';p1vec';q2vec';p2vec'];
                ww = right*left;
                nrw = max(size(ww));
                    rkw = rank(ww);
                    [evc,evl] = eig(ww);
                    devl = real(diag(evl));
                    [evls,evlidx] = sort(abs(devl)); % smallest to largest
                    keeps = evlidx(4-rkw+1:4);
                    devlk = devl(keeps);
                    evck = evc(:,keeps);
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

    pdim = 2*(nc-nrv);

    lmata = zeros(lpa-1,pdim);
    pmata = zeros(ppa-1,pdim);
    qmata = zeros(qpa-1,pdim);
    wmata = zeros(wpa-1,pdim);
    smata = zeros(spa-1,pdim);
    cmata = zeros(pdim,cpa-1);
    dmata = zeros(pdim,dpa-1);
    tmata = zeros(pdim,pdim);
    lmatb = zeros(lpb-1,pdim);
    wmatb = zeros(wpb-1,pdim);
    smatb = zeros(spb-1,pdim);
    cmatb = zeros(pdim,cpb-1);
    tmatb = zeros(pdim,pdim);

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
                lmata(lpa:lpa+dim-1,:) = brbi(mrp:mrp+dim-1,:);
                lmata(lpa+dim:lpa+2*dim-1,:) = binbr(mrp:mrp+dim-1,:);
                smata(spa:spa+dim-1,:) = brbi(mrp:mrp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = -binbr(mrp:mrp+dim-1,:);
                % B part
                lmatb(lpb:lpb+dim-1,:) = -narai(mcp:mcp+dim-1,:);
                lmatb(lpb+dim:lpb+2*dim-1,:) = aiar(mcp:mcp+dim-1,:);
                smatb(spb:spb+dim-1,:) = aiar(mcp:mcp+dim-1,:);
                wmatb(wpb:wpb+dim-1,:) = narai(mcp:mcp+dim-1,:);
                lpa = lpa + 2*dim;
                wpa = wpa + dim;
                spa = spa + dim;
                lpb = lpb + 2*dim;
                wpb = wpb + dim;
                spb = spb + dim;
                %   G BLOCKS
                nx = nx + 1;
                ny = ny + 1;
                tablex(nx,:) = [0 1 i dim 0 0 2];   % real part of G
                tabley(ny,:) = [0 1 i dim 2];   % imag part of G

                pmata(ppa:ppa+dim-1,:) = binbr(mrp:mrp+dim-1,:);
                pmata(ppa+dim:ppa+2*dim-1,:) = brbi(mrp:mrp+dim-1,:);
                qmata(qpa:qpa+dim-1,:) = narai(mcp:mcp+dim-1,:);
                qmata(qpa+dim:qpa+2*dim-1,:) = -aiar(mcp:mcp+dim-1,:);

                smata(spa:spa+dim-1,:) = narai(mcp:mcp+dim-1,:);
                smata(spa+dim:spa+2*dim-1,:) = aiar(mcp:mcp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = brbi(mrp:mrp+dim-1,:);
                wmata(wpa+dim:wpa+2*dim-1,:) = binbr(mrp:mrp+dim-1,:);

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
                cmata(:,cpa:cpa+dim-1) = brbi(mrp:mrp+dim-1,:)';
                cmata(:,cpa+dim:cpa+2*dim-1) = binbr(mrp:mrp+dim-1,:)';
                cmatb(:,cpb:cpb+dim-1) = -narai(mcp:mcp+dim-1,:)';
                cmatb(:,cpb+dim:cpb+2*dim-1) = aiar(mcp:mcp+dim-1,:)';
                cpa = cpa + 2*dim;
                cpb = cpb + 2*dim;
                % G BLOCK
                nv = nv + 1;
                p1vec = binbr(mrp,:)';
                p2vec = brbi(mrp,:)';
                q1vec = narai(mcp,:)';
                q2vec = -aiar(mcp,:)';
                left = [p1vec q1vec p2vec q2vec];
                right = [q1vec';p1vec';q2vec';p2vec'];
                www = left*right;
                ww = 0.5*(www+www');
                [eec,eel] = eig(ww);
                deel = diag(eel);
                rkw = rank(ww);
                devl = real(diag(eel));
                [evls,evlidx] = sort(-abs(devl)); % largest to smallest
                keeps = evlidx(1:rkw);
                devlk = devl(keeps);
                evck = eec(:,keeps);
                pploc = find(devlk>0);
                nnloc = find(devlk<0);
                shouldz = www;
                if length(pploc)>0
                    % evck(:,pploc)'*evck(:,pploc)
                    Cpart = evck(:,pploc)*diag(sqrt(devlk(pploc)));
                    cmata(:,cpa:cpa+length(pploc)-1) = Cpart;
                    shouldz = shouldz - Cpart*Cpart';
                end
                if length(nnloc)>0
                    % evck(:,nnloc)'*evck(:,nnloc)
                    Dpart = evck(:,nnloc)*diag(sqrt(abs(devlk(nnloc))));
                    dmata(:,dpa:dpa+length(nnloc)-1) = Dpart;
                    shouldz = shouldz + Dpart*Dpart';
                end
                tablev(nv,:) = [0 1 i length(pploc) length(nnloc) 0 0];% scalar g
                % SHOULD BE ZERO
                % norm(shouldz,'fro')
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
                lmata(lpa:lpa+dim-1,:) = brbi(mrp:mrp+dim-1,:);
                lmata(lpa+dim:lpa+2*dim-1,:) = binbr(mrp:mrp+dim-1,:);
                smata(spa:spa+dim-1,:) = brbi(mrp:mrp+dim-1,:);
                wmata(wpa:wpa+dim-1,:) = -binbr(mrp:mrp+dim-1,:);
                % B part
                lmatb(lpb:lpb+dim-1,:) = -narai(mcp:mcp+dim-1,:);
                lmatb(lpb+dim:lpb+2*dim-1,:) = aiar(mcp:mcp+dim-1,:);
                smatb(spb:spb+dim-1,:) = aiar(mcp:mcp+dim-1,:);
                wmatb(wpb:wpb+dim-1,:) = narai(mcp:mcp+dim-1,:);
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
                cmata(:,cpa:cpa+dim-1) = brbi(mrp:mrp+dim-1,:)';
                cmata(:,cpa+dim:cpa+2*dim-1) = binbr(mrp:mrp+dim-1,:)';
                cmatb(:,cpb:cpb+dim-1) = -narai(mcp:mcp+dim-1,:)';
                cmatb(:,cpb+dim:cpb+2*dim-1) = aiar(mcp:mcp+dim-1,:)';
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
            cmata(:,cpa:cpa+dim2-1) = brbi(mrp:mrp+dim2-1,:)';
            cmata(:,cpa+dim2:cpa+2*dim2-1) = binbr(mrp:mrp+dim2-1,:)';
            cmatb(:,cpb:cpb+dim1-1) = -narai(mcp:mcp+dim1-1,:)';
            cmatb(:,cpb+dim1:cpb+2*dim1-1) = aiar(mcp:mcp+dim1-1,:)';
            cpa = cpa + 2*dim2;
            cpb = cpb + 2*dim1;
            mrp = mrp + dim2;   % row of M, col of Delta
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

