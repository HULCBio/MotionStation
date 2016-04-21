% function y = vinterp(u,stepsize,finaliv,order)
%   or
% function y = vinterp(u,varymat,order)
%
%   The output vector Y (VARYING) is an interpolated version
%   of the input U.
%
%   If the second argument is a positive scalar, then:
%       The INDEPENDENT VARIABLEs of Y start at
%       MIN(GETIV(U)) and finish at FINALIV (or
%       MAX(GETIV(U)) if only 2 arguments), in
%       increments of STEPSIZE.  Hence, this gives
%       uniform spacing of output IV's.
%   If the second argument is a VARYING matrix, then:
%       The INDEPENDENT VARIABLEs of Y are equal to
%       GETIV(VARYMAT).  In this case, 3rd argument
%       is interpolation ORDER.
%
%   The choices of order are:
%       0	Zero order hold (default if only 3 args)
%       1	Linear interpolation
%
%   See also: DTRSP, TRSP, and VDCMATE.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function y = vinterp(u,stepsize,finaliv,order)

if nargin < 2
    disp('usage: y = vinterp(u,stepsize,finaliv,order)')
    disp('  or')
    disp('usage: y = vinterp(u,varymat,order)')
    return
    end

[utype,nru,ncu,nptsu] = minfo(u);
if utype == 'syst'
    error('cannot interpolate SYSTEM matrices')
    return
elseif utype == 'vary'
    [udat,uptr,ut] = vunpck(u);
else
    ut = 0;
    udat = u;
    end


[stype,srows,scols,snum] = minfo(stepsize);
if strcmp(stype,'cons') & srows == 1 & scols == 1
  if stepsize > 0
    if nargin < 3
      finaliv = max(ut);
    end
    yt = [ut(1):real(stepsize):finaliv].';
    teps = real(stepsize)*1e-8;
  else
    error('STEPSIZE must be greater than 0');
    return
  end
  if finaliv < ut(1);
    error('final iv precedes starting iv')
    return
  end
  if nargin < 4,
    order = 0;
    if nargin < 3
      finaliv = max(ut);
    end
  end
elseif strcmp(stype,'vary')
  yt = stepsize(1:snum,scols+1);
  teps = 1e-8;
  if min(yt) < min(ut)
    error('Desired interpolation points start before U')
    return
  end
  if nargin > 3
    error('Only 3 arguments when 2nd argument is VARYING')
  elseif nargin == 3
    order = finaliv;
    if (order ~= 1) & (order ~= 0)
      error('ORDER should be either 0 or 1')
      return
    end
  else
    order = 0;
  end
else
  error('2nd argument must be scalar >0, or VARYING matrix');
  return
end

npts = length(yt);

%   initial vector first

y = zeros(nru*npts+1,ncu+1);

%    we index on the shorter of yt or ut.  Note that this relies
%    on the command y([]) = []; leaving y unchanged.
%
%    modified: RSS, 8/5/91.  Test for empty index now performed
%    Varying matrix inputs can now be handled.

if order == 0,
    if npts <= length(ut),
        for i = 1:npts,
            index = max(find(ut <= yt(i)+teps));
            y((i-1)*nru+1:i*nru,1:ncu) = udat((index-1)*nru+1:index*nru,:);
            end
    elseif length(ut) == 1,
        y(1:nru*npts,1:ncu) = kron(ones(npts,1),udat);
    else
        for i = 1:length(ut)-1,
            index = find(yt >= ut(i) & yt < ut(i+1));
            if ~isempty(index),
                y((min(index)-1)*nru+1:max(index)*nru,1:ncu) = ...
                  kron(ones(length(index),1),udat((i-1)*nru+1:i*nru,:));
                end
            end
        i = length(ut);
        index = find(yt >= ut(length(ut)));
        if ~isempty(index),
            y((min(index)-1)*nru+1:max(index)*nru,1:ncu) = ...
              kron(ones(length(index),1),udat((i-1)*nru+1:i*nru,:));
            end
        end
    y(1:length(yt),ncu+1) = yt;
    y((nru*length(yt))+1,ncu+1) = inf;
    y((nru*length(yt))+1,ncu) = length(yt);
elseif order == 1,
    if length(ut) == 1,
        y(1:nru*npts,1:ncu) = kron(ones(npts,1),udat);
    elseif npts <= length(ut),
        for i = 1:length(yt);
            lix = max(find(ut <= yt(i)));
            hix = min(find(ut > yt(i)));
            if isempty(hix),
                j = [i:length(yt)];
                y((min(j)-1)*nru+1:max(j)*nru,1:ncu) = ...
                  kron(ones(length(j),1),udat((lix-1)*nru+1:lix*nru,:));
                break
            else
                tscl = (yt(i) - ut(lix))/(ut(hix)-ut(lix));
                udiff = ...
                  udat((hix-1)*nru+1:hix*nru,:)-udat((lix-1)*nru+1:lix*nru,:);
                  y(((i-1)*nru+1):i*nru,1:ncu) = ...
                  udat((lix-1)*nru+1:lix*nru,:)+ tscl*udiff;
	        end
            end
    else
        for i = 1:length(ut)-1,
            index = find(yt >= ut(i) & yt < ut(i+1));
            if ~isempty(index),
                diffvect = ...
                  udat((i)*nru+1:(i+1)*nru,:)-udat((i-1)*nru+1:i*nru,:);
                y((min(index)-1)*nru+1:max(index)*nru,1:ncu) = ...
                  kron(ones(length(index),1),udat((i-1)*nru+1:i*nru,:)) ...
                  + kron((yt(index)-ut(i))./(ut(i+1)-ut(i)),diffvect);
                end
            end
        i = length(ut);
        index = find(yt >= ut(length(ut)));
        if ~isempty(index),
            y((min(index)-1)*nru+1:max(index)*nru,1:ncu) = ...
              kron(ones(length(index),1),udat((i-1)*nru+1:i*nru,:));
            end
        end
    y(1:length(yt),ncu+1) = yt;
    y((nru*length(yt))+1,ncu+1) = inf;
    y((nru*length(yt))+1,ncu) = length(yt);
else
    error('order must be 0 or 1')
    return
    end



%if nargin < 4,
%    order = 0;
%    if nargin < 3
%        finaliv = max(ut);
%        end
%    end
%
%if finaliv < ut(1);
%    error('final iv precedes starting iv')
%    return
%    end
