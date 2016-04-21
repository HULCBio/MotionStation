% function sys = fitsys(frdata,order,weight,code,idnum,discflg)
%
%   FITSYS fits frequency response data in FRDATA
%   with a transfer function of order ORDER, using a
%   frequency dependent weight in WEIGHT (optional).
%
%   FRDATA : VARYING matrix of given frequency response data.
%            This must be a VARYING row or column matrix.
%   ORDER  : order of the SYSTEM matrix to fit data.
%   WEIGHT : VARYING/SYSTEM/CONSTANT matrix,
%            used as weighting in the least-squares fitting (default=1)
%   CODE   : 0 - no restriction on pole location of SYS (default)
%            1 - restrict SYS to be stable, minimum-phase, requires
%                   FRDATA to be 1x1 VARYING matrix
%            2 - constrain rational fit so that SYS is stable
%   IDNUM  : number of LS iterations (default = 2)
%   DISCFLG: If DISCFLG==1 (default=0) then all frequency data is
%            interpreted as unit disk data, and SYS should be interpreted
%            as discrete-time.  If DISCFLG==0, then the frequency data is
%            interpreted as imaginary axis, and SYS is interpreted as continuous
%            time.
%
%   The fourth argument, CODE, is optional. If CODE==0 (default)
%   then the rational fit is unconstrained.
%   If CODE == 1, as in the mu-synthesis routines, it
%   forces the rational fit to be stable, minimum phase,
%   by simply doing a spectral factorization on the answer.
%   Typically in this case, the response FRDATA comes from
%   the program GENPHASE, and already corresponds to a
%   stable, minimum phase transfer function.
%
%   See also: FITMAG, MAGFIT, GENPHASE, INVFREQS, and MSF

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%   Written by Xin Hua Yang and Andy Packard

function sys = fitsys(frdata,ord,weight,code,idnum,discflg)

if nargin < 2
    disp(['usage: sys = fitsys(frdata,order,weight)']);
    return
end

if isempty(ord)
    error('Order should be non-negative integer');
    return
else
    ord = ord(1);
    if ceil(ord)~=floor(ord) | ord<0
        error('Order should be non-negative integer');
        return
    end
end

% set missing ones empty for default treatment
if nargin==2
    weight = [];
    code = [];
    idnum = [];
    discflg = [];
elseif nargin == 3
    code = [];
    idnum = [];
    discflg = [];
elseif nargin == 4
    idnum = [];
    discflg = [];
elseif nargin == 5
    discflg = [];
end
if isempty(discflg)
    discflg = 0;
else
    discflg = discflg(1);
    if discflg~=1
        discflg = 0;
    end
end

omega = getiv(frdata);
if discflg==0
        pw = sqrt(max(omega)*(min(omega)+1e-8));
        capt = 1/pw;
        tcomes = capt*capt*(omega .^2);
        var = acos( (1 - tcomes) ./ ( 1 + tcomes) );
        var = exp(sqrt(-1)*var);
else
        var = exp(sqrt(-1)*omega);
end

[mtype,mrows,mcols,lendat] = minfo(frdata);
if ~strcmp(mtype,'vary')
    error('Frequency data must be a VARYING matrix');
    return
end
flag = 0;
if (mrows~=1)
    if (mcols==1)
        frdata = transp(frdata);
        flag = 1;
        mcols = mrows;
        mrows = 1;
    else
        error('Frequency Data must be Column or Row');
        return
    end
end
% NOTE: mrows is 1 at this point

[mattype,rowd,cold,mnum] = minfo(weight);
if strcmp(mattype,'empt')
    weight = ones(lendat,mcols);
elseif strcmp(mattype,'vary')
        if (mnum~=lendat)
            error('Incompatible Varying Data')
            return
        elseif rowd~=1 & cold~=1
            error('Weight must be Column or Row');
            return
        elseif rowd==1 & cold==mcols
            weight = abs(vunpck(weight));
        elseif rowd==mcols & cold==1
            weight = abs(vunpck(transp(weight)));
        elseif (rowd==1 & cold==1)
            weight = abs(vunpck(weight))*ones(1,mcols)
        else
            error('Incompatible Dimensions between WT and FRDATA ')
            return
        end
elseif strcmp(mattype,'cons')
    if rowd==1 & cold==1
        weight = ones(lendat,mcols);
    elseif rowd~=1 & cold~=1
        error('Weight must be Column or Row');
        return
    elseif rowd==1 & cold==mcols
        weight = ones(lendat,1)*abs(weight);
    elseif rowd==mcols & cold==1
        weight = ones(lendat,1)*abs(weight');
    else
        error('Incompatible Dimensions between WT and FRDATA ')
        return
    end
elseif strcmp(mattype,'syst')
    if rowd==1 & cold==1
        weight = vabs(vunpck(mmult(frsp(weight,omega,discflg),ones(1,mcols))));
    elseif rowd~=1 & cold~=1
        error('Weight must be Column or Row');
        return
    elseif rowd==1 & cold==mcols
        weight = vabs(vunpck(frsp(weight,omega,discflg)));
    elseif rowd==mcols & cold==1
        weight = vabs(vunpck(frsp(transp(weight),omega,discflg)));
    else
        error('Incompatible Dimensions between WT and FRDATA ')
        return
    end
else
        error('WT is not valid');
        return
end
% at this point, weight is lendat x numtransferfunc

if isempty(code)
    code = 0;
else
    code = code(1);
    if code~=1 & code~=2
        code = 0;
    end
end

if isempty(idnum)
    idnum = 2;
else
    idnum = idnum(1);
    if ceil(idnum)~=floor(idnum) | idnum<0
        idnum = 2;
    end
end

totalt = 0;
if ord>0
  ord1 = ord+1;
  mcod1 = mcols*ord1;
  mone = ones(1,ord);
  mone1 = ones(1,ord1);

  a0 = ones(lendat,ord1);
  for i=1:ord
    a0(:,ord1-i) = a0(:,ord1-i+1).*var;
  end
  b0 = a0(:,2:ord1);
  bn = a0(:,1);

  B = zeros(mcols*lendat,1);
  ab = zeros(mcols*lendat,ord);
  for kk=1:mcols
    sn=(kk-1)*lendat;
    B(sn+1:sn+lendat,1)=bn.*frdata(1:lendat,kk);
    ab(sn+1:sn+lendat,:)= -(frdata(1:lendat,kk)*mone).*b0;
  end
  % WAA is huge, sparse/zeros is ok, sparse is slow on small
  %     problems, and doesn't work on all machines
  waa = zeros(mcols*lendat,mcols*ord1);
  waan = waa;
  wB = zeros(mcols*lendat,1);
  for kk=1:mcols
    sn = (kk-1)*lendat;
    kn = (kk-1)*ord1;
    wB(sn+1:sn+lendat,1) = weight(:,kk).*B(sn+1:sn+lendat,1);
    wab(sn+1:sn+lendat,:) = (weight(:,kk)*mone).*ab(sn+1:sn+lendat,:);
    waa(sn+1:sn+lendat,kn+1:kn+ord1) = (weight(:,kk)*mone1).*a0;
  end
  x = [real([waa wab]);imag([waa wab])]\[real(wB);imag(wB)];

  den = [1;x(mcod1+1:mcod1+ord,1)];
  for idn=1:idnum
    dest = a0*den;
    nweight = abs(ones(lendat,1)./dest);
    wm = nweight*mone; wm1 = nweight*mone1;
    for kk=1:mcols
        sn = (kk-1)*lendat;
        kn = (kk-1)*ord1;
        wBn(sn+1:sn+lendat,1) = nweight.*wB(sn+1:sn+lendat,1);
        wabn(sn+1:sn+lendat,:) = wm.*wab(sn+1:sn+lendat,:);
        waan(sn+1:sn+lendat,kn+1:kn+ord1) =...
            wm1.*waa(sn+1:sn+lendat,kn+1:kn+ord1);
    end
    x = [real([waan wabn]);imag([waan wabn])]\[real(wBn);imag(wBn)];
    den = [1; x(mcod1+1:mcod1+ord,1)];
  end

  if code==2
    rs = roots(den);
    max_rad = max(abs(rs));
    if (max_rad>1)
        for kk=1:ord
            rt = rs(kk);
            rad = abs(rt);
            if rad>1
                rt = rt/(rad^2);
                rs(kk) = rt;
            end
        end
        sden=real(poly(rs).'); sdest = a0*sden;
        wm1=(ones(lendat,1)./sdest)*mone1;
        wa0=wm1.*a0;
        waa=kron(eye(mcols),wa0);
        for kk=1:mcols
            sn=(kk-1)*lendat;
            wB(sn+1:sn+lendat,1)=weight(:,kk).*frdata(1:lendat,kk);
            waan(sn+1:sn+lendat,kn+1:kn+ord1)=...
                wm1.*waa(sn+1:sn+lendat,kn+1:kn+ord1);
        end
        new_num=[real(waan);imag(waan)]\[real(wB);imag(wB)];
        x = [new_num;sden(2:ord1,1)];
    end
  end

  for kk=1:mcols
    sn = (kk-1)*ord1;
    num(:,kk) = x(sn+1:sn+ord1,1);
  end
  al(:,1) = x(mcod1+1:mcod1+ord,1);
  sn = ord-1;
  sa = [-al [eye(sn); zeros(1,sn)]];
  sd = num(1,:);
  sb = num(2:ord1,:)-al*sd;
  sc = zeros(1,ord); sc(1,1)=1;
  sys = pck(sa,sb,sc,sd);
  if flag
    sys = transp(sys);
  end
  sys = strans(sys);
  if code == 1 & mrows == 1 & mcols == 1
    if discflg==0
        sys = extsmp(di2co(sys,pw));
    else
        sys = co2di(extsmp(di2co(sys,1)),1);
    end
  else
    if discflg==0
        sys = di2co(sys,pw);
    end
  end
else
    sys = zeros(1,mcols);
    for kk=1:mcols
        amat = [weight(:,kk);zeros(lendat,1)];
        bmat = [weight(:,kk).*real(frdata(1:lendat,kk)); ...
                weight(:,kk).*imag(frdata(1:lendat,kk))];
        sys(kk) = amat\bmat;
    end
    if flag==1
        sys = sys';
    end
end