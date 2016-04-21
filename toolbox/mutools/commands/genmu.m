% function [bnd,q,dd,gg] = genmu(m,c,blk)
%
%   Generalized-mu Upper bound Calculation
%
%   [I - Delta M;C] is guaranteed not to lose
%   column rank for all perturbations Delta
%   in BLK, with norm < 1/BND.  This is guaranteed
%   by a matrix Q, such that mu(M+QC)<=BND, as
%   verified with the scalings in DD and GG.
%
%   See MU, CMMUSYN

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [bnd,q,dd,gg] = genmu(m,c,blk,opt)

if nargin<3
    disp('usage: [bnd,qopt,dd,gg] = genmu(m,c,blk)');
    return
end

if nargin == 3
    opt = 'n';
end
bnd = []; q = []; dd = []; gg = [];

mumexstatus1 = exist('amevlp');
mumexstatus2 = exist('amibndv');
mumexstatus3 = exist('amilowxy');
mumexstatus4 = exist('amiuppxy');
if mumexstatus1~=3 | mumexstatus2~=3 | mumexstatus3~=3 | mumexstatus4~=3
	disp(['genmu Warning: MEX functions are unavailable.  Use CMMUSYN for approximate solution']);
	return
end

diagnose = goptvl(opt,'d',1,-1);
clevel = goptvl(opt,'C',1,1);

[mtype,nr,nc,mnum] = minfo(m);
[ctype,cr,cc,cnum] = minfo(c);
[nblk,dum] = size(blk);
if dum~=2
    error('Invalid Block Structure');
    return
end
ablk = abs(blk);
sblk = find(ablk(:,2)==0);
if ~isempty(sblk)
    ablk(sblk,2) = ablk(sblk,1);
end
if nblk>1
    dims = sum(ablk);
else
    dims = ablk;
end
if dims(1)~=nc | dims(2)~=nr | nc~=cc
    error('Inconsistent Matrix/Delta dimensions')
    return
end
if strcmp(mtype,'syst') | strcmp(ctype,'syst')
    error('M and C should be VARYING and/or CONSTANT')
    return
end

if ~strcmp(mtype,'cons') | ~strcmp(ctype,'cons')
    [bnd,q,dd,gg] = veval('genmu',m,c,blk,opt);
else
    if diagnose>=1
        x1 = clock;
        [bnd,var,dac,dar,gacr,garc] = gebubd(m,c,blk,diagnose,clevel);
        x2 = clock;
    else
        x1=clock;
        [bnd,var,dac,dar,gacr,garc] = gebub(m,c,blk,diagnose,clevel);
        x2=clock;
    end
    bbnd = bnd;
    if bnd==0
        bbnd = 1e-6;
    end
    [dd,gg] = a2ynrow(dar,dac,garc,gacr,blk,bbnd);
    if any(blk(:,1)<0)
        [dl,dr,gl,gm,gr] = muunwrap(dd,gg,blk);
        el = eye(nr);
        er = eye(nc);
        ll = inv(sqrtm(sqrtm(el+gl*gl)));
        rr = inv(sqrtm(sqrtm(er+gr*gr)));
        newv = c/dr*rr;
        newr = ll*( (1/bbnd)*dl*m/dr-sqrt(-1)*gm )*rr;
        newu = (1/bbnd)*ll*dl;
        [q,gam] = ruqvsol(newr,newu,newv);
    else
        [dl,dr] = muunwrap(dd,blk);
        el = eye(nr);
        er = eye(nc);
        newv = c/dr;
        newr = dl*m/dr;
        newu = dl;
        [q,gam] = ruqvsol(newr,newu,newv);
    end
end
if diagnose>=1
    disp(['Time to Compute: ' num2str(etime(x2,x1))]);
elseif diagnose==0
    disp(['Time to Compute: ' num2str(etime(x2,x1))]);
end