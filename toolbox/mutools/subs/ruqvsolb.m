% function [q,gopt] = ruqvsolb(r0,r1,uu,vv)
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [maxlam] = ruqvsolb(r0,r1,uu,vv)

  [nrr ncr] = size(r0);
  [nru ncu] = size(uu);
  [nrv ncv] = size(vv);
  if nrr ~= nru | ncr ~= ncv | nru < ncu | ncv < nrv
    error('Dimension problems')
    return
  end

    [Uu,Su,Vu] = svd(uu);
    utol = max(size(uu))*max(max(Su))*eps;
    rku = sum(diag(Su)>utol);
    Vu1 = Vu(:,1:rku);
    Su1 = Su(1:rku,1:rku);
    Ueq = Uu(:,1:rku);
    if rku<nru
        uperp = Uu(:,rku+1:nru);
    else
        uperp = [];
    end

    [Uv,Sv,Vv] = svd(vv);
    vtol = max(size(vv))*max(max(Sv))*eps;
    rkv = sum(diag(Sv)>vtol);
    Uv1 = Uv(:,1:rkv);
    Sv1 = Sv(1:rkv,1:rkv);
    Veq = Vv(:,1:rkv)';
    if rkv<ncv
        vperp = Vv(:,rkv+1:ncv)';
    else
        vperp = [];
    end

if ~isempty(uperp)
  upr0 = uperp'*r0;
  upr1 = uperp'*r1;
  b = [zeros(nru-ncu,nru-ncu) upr0;upr0' zeros(ncr,ncr)];
  a = -[eye(nru-ncu) upr1;upr1' eye(ncr)];
  lam = eig(a,b);
  keep = find(abs(imag(lam))<1e-8);
  keep = 1:length(lam);
  vals = real(lam(keep));
  vals = sort(vals);
  keep = find(~isinf(vals) & ~isnan(vals));
  vals = vals(keep);
  lowu = [];
  highu = [];
  cnt = 0;
  tmpu = zeros(length(vals),1);
  for i=1:length(vals)
    tmpu(i) = norm(uperp'*(vals(i)*r0+r1));
    if abs(norm(uperp'*(vals(i)*r0+r1))-1)<1e-6
        if isempty(lowu)
            lowu = vals(i);
            cnt = cnt + 1;
        else
            highu = vals(i);
            cnt = cnt + 1;
        end
     end
  end
  if cnt>2
    % disp('Warning in RUQVSOLB: Too many U-Points found');
    % tmpu
  end
else
    highu = inf;
end

if ~isempty(vperp)
  r0vp = r0*vperp';
  r1vp = r1*vperp';
  b = [zeros(nrr,nrr) r0vp;r0vp' zeros(ncv-nrv,ncv-nrv)];
  a = -[eye(nrr) r1vp;r1vp' eye(ncv-nrv)];
  lam = eig(a,b);
  keep = find(abs(imag(lam))<1e-8);
  keep = 1:length(lam);
  vals = real(lam(keep));
  vals = sort(vals);
  keep = find(~isinf(vals) & ~isnan(vals));
  vals = vals(keep);
  lowv = [];
  highv = [];
  cnt = 0;
  tmpv = zeros(length(vals),1);
  for i=1:length(vals)
    tmpv(i) = norm((vals(i)*r0+r1)*vperp');
    if abs(norm((vals(i)*r0+r1)*vperp')-1)<1e-6
        if isempty(lowv)
            lowv = vals(i);
            cnt = cnt + 1;
        else
            highv = vals(i);
            cnt = cnt + 1;
        end
     end
  end
  if cnt>2
    % disp('Warning in RUQVSOLB: Too many V-Points found');
    % tmpv
  end
else
    highv = inf;
end

  if ~isempty(highu) & ~isempty(highv)
    if isinf(highu)
        maxlam = highv;
    elseif isinf(highv)
        maxlam = highu;
    else
        if highu<=highv & highu>=lowv
            maxlam = highu;
        elseif highv<=highu & highv>=lowu
            maxlam = highv;
        else
            maxlam = [];
        end
    end
  end
