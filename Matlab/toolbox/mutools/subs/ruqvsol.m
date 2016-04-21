% function [q,gammaopt] = ruqvsol(r,u,v)
%
%   This solves the constant matrix Davis-Kahan-Weinberger
%   problem (SIAM Journal, 1981)
%
%       gammaopt := min norm(r + u*q*v)
%                    q
%
%   This is one of the most important linear algebra lemmas
%   in modern linear systems theory, showing up in an
%   operator-theoretic version in the H-infinity research
%   from 1982-1987, and then the AMI-based synthesis techniques
%   from 1990-present.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [q,gopt] = ruqvsol(r,uu,vv)

    if nargin ~= 3
        disp('usage: [q,gopt] = ruqvsol(r,u,v)');
        return
    end

    [typer,nrr,ncr,numr] = minfo(r);
    [typeu,nru,ncu,numu] = minfo(uu);
    [typev,nrv,ncv,numv] = minfo(vv);
    if nrr ~= nru | ncr ~= ncv
        error('R and U need same # of rows, R and V need same # of columns')
        return
    end
    if strcmp(typer,'syst') | strcmp(typeu,'syst') | strcmp(typev,'syst')
        error('R, U and V should be VARYING and/or CONSTANT')
        return
    end

if ~strcmp(typer,'cons') | ~strcmp(typeu,'cons') | ~strcmp(typev,'cons')
        % cheat if VARYING
        [q,gopt] = veval('ruqvsol',r,uu,vv);
else

    % 8 cases, should just use veval

    [Uu,Su,Vu] = svd(uu);
    if min(size(uu))==1
        dsu = Su(1);
    else
        dsu = diag(Su);
    end
    utol = max(size(uu))*max(dsu)*eps;
    rku = sum(dsu>utol);
    Vu1 = Vu(:,1:rku);
    Su1 = Su(1:rku,1:rku);
    Ueq = Uu(:,1:rku);
    if rku<nru
        uperp = Uu(:,rku+1:nru);
    else
        uperp = [];
    end
    [Uv,Sv,Vv] = svd(vv);
    if min(size(vv))==1
        dsv = Sv(1);
    else
        dsv = diag(Sv);
    end
    vtol = max(size(vv))*max(dsv)*eps;
    rkv = sum(dsv>vtol);
    Uv1 = Uv(:,1:rkv);
    Sv1 = Sv(1:rkv,1:rkv);
    Veq = Vv(:,1:rkv)';
    if rkv<ncv
        vperp = Vv(:,rkv+1:ncv)';
    else
        vperp = [];
    end

    if ~isempty(uperp) & ~isempty(vperp)
        gopt = max([norm(uperp'*r) norm(r*vperp')]);
        a = uperp'*r*vperp';
        [nra nca] = size(a);
        b = Ueq'*r*vperp';
        c = uperp'*r*Veq';
        % Y
        rightside = gopt*gopt*eye(nca) - a'*a;
        rs = sqrtm(rightside);
        y = b/rs;
        % Z
        leftside = gopt*gopt*eye(nra) - a*a';
        ls = sqrtm(leftside);
        z = ls\c;
        % Q
        qprime = -y*a'*z;
        q = Vu1/Su1*(qprime - Ueq'*r*Veq')/Sv1*Uv1';
    elseif isempty(uperp) & ~isempty(vperp)
        gopt = norm(r*vperp');
        q = Vu1/Su1*(-Ueq'*r*Veq')/Sv1*Uv1';
    elseif ~isempty(uperp) & isempty(vperp)
        gopt = norm(uperp'*r);
        q = Vu1/Su1*(-Ueq'*r*Veq')/Sv1*Uv1';
    elseif isempty(uperp) & isempty(vperp)
        gopt = 0;
        q = Vu1/Su1*(-Ueq'*r*Veq')/Sv1*Uv1';
    end
end

%

