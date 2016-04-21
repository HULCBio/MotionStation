% function smp = extsmp(sys)
%
%   compute stable, minimum phase SYSTEM
%   matrix SMP such that
%
%      MMULT(CJT(SMP),SMP) = MMULT(CJT(SYS),SYS)
%
%   SYS should have full column-rank at all s=jw,
%   and should have no poles on s=jw.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function smp = extsmp(sys)
    if nargin ~= 1
        disp(['usage: smp = extsmp(sys)']);
        return
    end
    flg = 0;
    [mtype,mrows,mcols,ns] = minfo(sys);
    if strcmp(mtype,'cons')
        smp = sys;
    elseif strcmp(mtype,'syst')
        [a,b,c,d] = unpck(sys);
        if rank(d)~=mcols
            error('System should have Full Column Rank at s=infty');
            return
        end
        normb = norm(b,'fro');
        normc = norm(c,'fro');
        if normb>0 & normc>0
            m = sys2pss(sys);
            blk = [ones(ns,2);mcols mrows];
            [bnds,dvec] = mu(m,blk,'U');
            [dl,dr] = unwrapd(dvec,blk);
            sys = pss2sys(dl*m/dr,ns);
            [a,b,c,d] = unpck(sys);
        end
        aa = [-a' -c'*c; zeros(ns,ns) a];
        cc = [b' d'*c];
        bb = [-c'*d ; b];
        dd = d'*d;
        [x1,x2,fail] = ric_schr(aa);
        if fail > 0
            disp('Warning: System has imaginary axis poles');
            smp = [];
        else
            seisp = [x1;x2];
            [x1,x2,fail] = ric_schr(-aa);
            if fail > 0
                disp('Warning: System has imaginary axis poles');
                smp = [];
            else
                useisp = [x1;x2];
                tran = [seisp useisp];
                newa = tran\aa*tran;
                a1 = newa(1:ns,1:ns);
                ct = cc*tran;
                c1 = ct(:,1:ns);
                tib = tran\bb;
                b1 = tib(1:ns,:);
                bdi = b1/dd;
                atop = a1 - bdi*c1;
                aham = [atop -bdi*b1';(c1'/dd)*c1 -atop'];
                [x1,x2,fail] = ric_schr(aham);
                if fail > 0
                    if mcols==1 & mrows==1
                        pp = spoles(sys);
                        zz = szeros(sys);
                        if any(real(pp)==0) | any(real(zz)==0)
                            disp('Warning: Decomposition fails');
                            smp = [];
                        else
                            ppr = find(real(pp)>0);
                            pp(ppr) = -pp(ppr);
                            zzr = find(real(zz)>0);
                            zz(zzr) = -zz(zzr);
                            smp = nd2sys(poly(zz),poly(pp),d);
                            flg = 1;
                        end
                    else
                        disp('Warning: Decomposition fails');
                        smp = [];
                    end
                else
                    ddsm = sqrtm(dd);
                    smp = sysbal(pck(a1,b1,ddsm\(c1+b1'*real(x2/x1)),ddsm));
                end
            end
        end
    else
        error('Input variable should be CONSTANT or SYSTEM');
        return
    end