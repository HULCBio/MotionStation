% function out = frsp(sys,omega,T,balflg)
%
%   Complex frequency response of a SYSTEM matrix, produces
%   a VARYING matrix which contains its frequency response:
%
%    SYS     - SYSTEM matrix
%    OMEGA   - response calculated at these frequencies, can
%                also be another VARYING matrix, and then these
%                independent variables are used
%    T       - 0 (default) continuous system, if T ~= 0 then
%         discrete evaluation with sample time T is used.
%    BALFLG  - 0 (default) balances A matrix prior to eval, nonzero
%                 value for BALFLG leaves state-space unchanged
%    OUT     - VARYING frequency response matrix
%
%   See also: BALANCE, HESS, SAMHLD, TUSTIN, and VPLOT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = frsp(sys,omega,T,balflg,guidata)

if nargin < 2
    disp('usage: out = frsp(sys,omega)')
    return
elseif nargin == 2
    T = [];
    balflg = [];
    guidata = [];
elseif nargin == 3
    balflg = [];
    guidata = [];
elseif nargin == 4
    guidata = [];
end

[mtype,mrows,mcols,mnum] = minfo(sys);
if mtype == 'vary'
    error('input matrix is already a VARYING matrix')
    return
elseif mtype == 'empt'
    out = [];
    return
end

[omtype,omrows,omcols,omnum] = minfo(omega);
if omtype == 'cons'
    if omrows == 1
      omega = omega.';
    end
    npts = length(omega);
elseif omtype == 'vary'
    omega = omega(1:omnum,omcols+1);
    npts = omnum;
else
    error('omega should be a vector, or VARYING matrix')
    return
end

if isempty(T)
    T = 0;
else
    T = T(1);
end
if isempty(balflg)
    balflg = 0;
end


if mtype == 'cons'
    out = [];
    for i=1:npts
      out = [out; sys];
    end
    out = [out [omega;zeros(npts*(mrows-1),1)];zeros(1,mcols-1) npts inf];
    return
end

if isempty(omega)
    out = [];
    return
else
    jomega = sqrt(-1) * omega;
    if T ~= 0
      jomega = exp(T*jomega);
    end
    [a,b,c,d] = unpck(sys);
    [states dum]=size(a);
    [outputs inputs] = size(d);
    if nargin == 2 | balflg == 0
      [t,aa] = balance(a);
      tbsloc = find(t>0);
      if max(t(tbsloc))/min(t(tbsloc)) < 1e10 & length(tbsloc)==states
        a = aa;
        b = t\b;
        c = c*t;
      end
    end
    [p,hesa] = hess(a);
    hesb = p' * b;
    hesc = c * p;
    npts = length(jomega);
    idn = eye(states);
    nrout = mrows;
    ncout = mcols;
    out = zeros((nrout*npts)+1,ncout+1);
    fout = (npts+1)*nrout;
    pout = 1:nrout:fout;
    poutm1 = pout(2:npts+1) - 1;
    if isempty(guidata)
        for i=1:npts
            g = (jomega(i) * idn - hesa) \ hesb;
            out(pout(i):poutm1(i),1:ncout) = d + hesc*g;
        end
    else
        den = guidata(2);
        ii=1;
        for i=1:npts
            g = (jomega(i) * idn - hesa) \ hesb;
            out(pout(i):poutm1(i),1:ncout) = d + hesc*g;
            if i/den >= ii
                set(guidata(1),'string',[int2str(i) '/' int2str(npts)]);
                ii = ii+1;
                drawnow
            end
        end
        set(guidata(1),'string',[int2str(npts) '/' int2str(npts)]);
        drawnow
    end
    out(1:npts,ncout+1) = omega;
    out((nrout*npts)+1,ncout+1) = inf;
    out((nrout*npts)+1,ncout) = npts;
end
%
%