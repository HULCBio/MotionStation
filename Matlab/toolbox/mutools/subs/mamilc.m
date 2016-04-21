function [mth,lmat,rmat,pmat,qmat,ma,wmat,smat,...
            mr, hmat,jmat,sizecd,cmat,dmat,tmat] = ...
         mamilc(mthA,lmatA,rmatA,pmatA,qmatA,maA,wmatA,smatA,...
            mrA,hmatA,jmatA,sizecdA,cmatA,dmatA,tmatA,...
            mthB,lmatB,rmatB,pmatB,qmatB,maB,wmatB,smatB,...
            mrB,hmatB,jmatB,sizecdB,cmatB,dmatB,tmatB,...
            lambda,vardata)

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

mth=[]; lmat=[]; rmat=[]; pmat=[]; qmat=[]; ma=[]; wmat=[]; smat=[];
mr=[]; hmat=[]; jmat=[]; sizecd=[]; cmat=[]; dmat=[]; tmat=[];

% forms new AMI: lambda B + A
            [mthB,lmatB,rmatB,pmatB,qmatB,maB,wmatB,smatB,...
                    mrB,hmatB,jmatB,sizecdB,cmatB,dmatB,tmatB] = ...
                mamiscl(mthB,lmatB,rmatB,pmatB,qmatB,maB,wmatB,smatB,...
                    mrB,hmatB,jmatB,sizecdB,cmatB,dmatB,tmatB,lambda);


[nx,ny,nz,nv,sizex,nvarx,xvp,tnvarx,...
            sizey,nvary,yvp,tnvary,...
            sizez,nvarz,zvp,tnvarz,...
            tnvar] = var2sep(vardata);

pdim = size(tmatA,1);

            if nx>0
                lad = mthA(:,1).*sizex;
                lap = cumsum([1;lad]);
                lbd = mthB(:,1).*sizex;
                lbp = cumsum([1;lbd]);
                lrp = cumsum([1;lad+lbd]);
                rad = mthA(:,2).*sizex;
                rap = cumsum([1;rad]);
                rbd = mthB(:,2).*sizex;
                rbp = cumsum([1;rbd]);
                rrp = cumsum([1;rad+rbd]);
                pqad = mthA(:,3).*sizex;
                pqap = cumsum([1;pqad]);
                pqbd = mthB(:,3).*sizex;
                pqbp = cumsum([1;pqbd]);
                pqrp = cumsum([1;pqad+pqbd]);
                lmat = zeros(sum(lad)+sum(lbd),pdim);
                rmat = zeros(sum(rad)+sum(rbd),pdim);
                pmat = zeros(sum(pqad)+sum(pqbd),pdim);
                qmat = zeros(sum(pqad)+sum(pqbd),pdim);
                mth = mthA + mthB;
                for i=1:nx
                    if mth(i,1)>0
                        lmat(lrp(i):lrp(i+1)-1,:) = ...
                            [lmatA(lap(i):lap(i+1)-1,:);lmatB(lbp(i):lbp(i+1)-1,:)];
                    end
                    if mth(i,2)>0
                        rmat(rrp(i):rrp(i+1)-1,:) = ...
                            [rmatA(rap(i):rap(i+1)-1,:);rmatB(rbp(i):rbp(i+1)-1,:)];
                    end
                    if mth(i,3)>0
                        pmat(pqrp(i):pqrp(i+1)-1,:) = ...
                            [pmatA(pqap(i):pqap(i+1)-1,:);pmatB(pqbp(i):pqbp(i+1)-1,:)];
                        qmat(pqrp(i):pqrp(i+1)-1,:) = ...
                            [qmatA(pqap(i):pqap(i+1)-1,:);qmatB(pqbp(i):pqbp(i+1)-1,:)];
                    end
                end
            end
            if ny>0
                wsad = maA.*sizey;
                wsap = cumsum([1;wsad]);
                wsbd = maB.*sizey;
                wsbp = cumsum([1;wsbd]);
                wsrp = cumsum([1;wsad+wsbd]);
                smat = zeros(sum(wsad)+sum(wsbd),pdim);
                wmat = zeros(sum(wsad)+sum(wsbd),pdim);
                ma = maA + maB;
                for i=1:ny
                    if ma(i)>0
                        wmat(wsrp(i):wsrp(i+1)-1,:) = ...
                            [wmatA(wsap(i):wsap(i+1)-1,:);wmatB(wsbp(i):wsbp(i+1)-1,:)];
                        smat(wsrp(i):wsrp(i+1)-1,:) = ...
                            [smatA(wsap(i):wsap(i+1)-1,:);smatB(wsbp(i):wsbp(i+1)-1,:)];
                    end
                end
            end
            if nz>0
                had = mrA.*sizez(:,1);
                hap = cumsum([1;had]);
                hbd = mrB.*sizez(:,1);
                hbp = cumsum([1;hbd]);
                jad = mrA.*sizez(:,2);
                jap = cumsum([1;jad]);
                jbd = mrB.*sizez(:,2);
                jbp = cumsum([1;jbd]);
                hrp = cumsum([1;had+hbd]);
                jrp = cumsum([1;jad+jbd]);
                hmat = zeros(sum(had)+sum(hbd),pdim);
                jmat = zeros(sum(jad)+sum(jbd),pdim);
                mr = mrA + mrB;
                for i=1:nz
                    if mr(i)>0
                        hmat(hrp(i):hrp(i+1)-1,:) = ...
                            [hmatA(hap(i):hap(i+1)-1,:);hmatB(hbp(i):hbp(i+1)-1,:)];
                        jmat(jrp(i):jrp(i+1)-1,:) = ...
                            [jmatA(jap(i):jap(i+1)-1,:);jmatB(jbp(i):jbp(i+1)-1,:)];
                    end
                end
            end
            if nv>0
                cap = cumsum([1;sizecdA(:,1)]);
                dap = cumsum([1;sizecdA(:,2)]);
                cbp = cumsum([1;sizecdB(:,1)]);
                dbp = cumsum([1;sizecdB(:,2)]);
                cp = cumsum([1;sizecdA(:,1)+sizecdB(:,1)]);
                dp = cumsum([1;sizecdA(:,2)+sizecdB(:,2)]);
                sizecd = sizecdA + sizecdB;
                cmat = zeros(pdim,sum(sizecd(:,1)));
                dmat = zeros(pdim,sum(sizecd(:,2)));
                for i=1:nv
                    cmat(:,cp(i):cp(i+1)-1) = ...
                        [cmatA(:,cap(i):cap(i+1)-1) cmatB(:,cbp(i):cbp(i+1)-1)];
                    dmat(:,dp(i):dp(i+1)-1) = ...
                        [dmatA(:,dap(i):dap(i+1)-1) dmatB(:,dbp(i):dbp(i+1)-1)];
                end
            end
            tmat = tmatA+tmatB;
