%function [qopt,bound] = cmmusyn(r,u,v,blk,opt,Qinit)
%
%   Constant-Matrix Upper-Bound mu-Synthesis.  Minimizes
%       (over constant matrix Q) the upper bound of
%       mu(R+UQV), using the block structure defined
%       by BLK.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $


function [qbest,bestcost,dd,gg] = cmmusyn(r,u,v,blk,opt,qinit,niter)

if nargin<4
    disp('usage: [qopt,mubnd] = cmmusyn(r,u,v,blk,opt,Qinit)');
    return
end

if nargin==4
    opt = [];
    qinit = [];
    niter = [];
elseif nargin==5
    qinit = [];
    niter = [];
elseif nargin==6
    niter = [];
end

[typem,nr,nc,nptm] = minfo(r);
[typeu,ur,uc,nptu] = minfo(u);
[typev,vr,vc,nptv] = minfo(v);
ablk = abs(blk);
sblk = find(ablk(:,2)==0);
if ~isempty(sblk)
    ablk(sblk,2) = ablk(sblk,1);
end
dims = sum(ablk);
if dims(1)~=nc | dims(2)~=nr | nc~=vc | nr~=ur
    error('Inconsistent Matrix/Delta dimensions')
    return
end

if isempty(opt)
    opt = 'cUsw';
elseif ~isstr(opt)
    error('Option should be a string');
    return
else
    opt = [opt 'Usw'];
end
diagnose = 0;
if any(opt=='D')
	diagnose = 1;
end

if isempty(qinit)
    qinit = zeros(uc,vr);
else
    [typeq,rowq,colq,nptq] = minfo(qinit);
    if rowq~=uc | colq~=vr
        error('Inconsistent dimensions for R, U, Q, V');
        return
    elseif strcmp(typeq,'syst')
        error('Qinit should be VARYING or CONSTANT');
        return
    end
end

if isempty(niter)
    niter = inf;
else
    niter = ceil(abs(niter(1)));
    if niter < 1
        error('NITER should be positive integer')
        return
    end
end

perctol = 0.01;

if strcmp(typem,'syst') | strcmp(typeu,'syst') | strcmp(typev,'syst')
    error('R, U and V should be VARYING and/or CONSTANT')
    return
end

bestcost = inf;

if ~strcmp(typem,'cons') | ~strcmp(typeu,'cons') | ~strcmp(typev,'cons')
    [q,lastcost] = veval('cmmusyn',r,u,v,blk,opt,qinit,niter);
else
    iter = 0;
    dl = eye(nr);
    dr = eye(nc);
    go = 1;
    lastcost = norm(r);
    cnt = 0;
    if all(blk(:,1)>0)
        [bnd,dd,ss] = mu(r+u*qinit*v,blk,opt);
        if bnd(1) < bestcost
            bestcost = bnd(1);
            qbest = qinit;
            dbest = dd;
        end
        lastcost = bnd(1);
        [dl,dr] = muunwrap(dd,blk);
        while go==1 & iter<niter
            [q,gam] = ruqvsol(dl*r/dr,dl*u,v/dr);
            [bnd,dd] = mu(r+u*q*v,blk,opt);
            if bnd(1) < bestcost
                bestcost = bnd(1);
                qbest = q;
                dbest = dd;
            end
	    if diagnose==1
            	 disp([iter lastcost gam bnd(1)])
	    end
            if lastcost-bnd(1)<perctol*bnd(1)
                go = 0;
            end
            lastcost = bnd(1);
            [dl,dr] = muunwrap(dd,blk);
            iter = iter + 1;
        end
        dd = dbest;
        gg = [];
    else
        el = eye(nr); er = eye(nc);
        [bnd,dd,ss,pp,gg] = mu(r+u*qinit*v,blk,opt);
        if bnd(1) < bestcost
            bestcost = bnd(1);
            qbest = qinit;
            dbest = dd;
            gbest = gg;
        end
        lastcost = bnd(1);
        [dl,dr,gl,gm,gr] = muunwrap(dd,gg,blk);
        while go==1 & iter<niter
            ll = inv(sqrtm(sqrtm(el+gl*gl)));
            rr = inv(sqrtm(sqrtm(er+gr*gr)));
            r0 = ll*dl*r/dr*rr;
            r1 = -sqrt(-1)*ll*gm*rr;
            uu = ll*dl*u; vv = v/dr*rr;
            % [size(r0);size(r1);size(uu);size(vv)]
            maxlam = ruqvsolb(r0,r1,uu,vv);
            xtry = 1/maxlam;
            newr = ll*( (1/xtry)*dl*r/dr-sqrt(-1)*gm )*rr;
            newu = (1/xtry)*ll*dl*u;
            newv = v/dr*rr;
            [q,gam] = ruqvsol(newr,newu,newv);
            [bnd,dd,ss,pp,gg] = mu(r+u*q*v,blk,opt);
            if bnd(1) < bestcost
                bestcost = bnd(1);
                qbest = q;
                dbest = dd;
                gbest = gg;
            end
	    if diagnose==1
            	disp([iter lastcost gam bnd(1)])
	    end
            if lastcost-bnd(1)<perctol*bnd(1)
                go = 0;
            end
            lastcost = bnd(1);
            [dl,dr,gl,gm,gr] = muunwrap(dd,gg,blk);
            iter = iter + 1;
        end
        dd = dbest;
        gg = gbest;
    end
end
%
%
