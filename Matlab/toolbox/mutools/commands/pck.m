% function sys = pck(a,b,c,d)
%
%   Pack state-space data into a SYSTEM matrix
%
%   See also: MINFO, ND2SYS, PSS2SYS, SYS2PSS, UNPCK,
%             VPCK, VUNPCK, and ZP2SYS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sys = pck(a,b,c,d)
  if nargin < 3
    disp('usage: sys = pck(a,b,c,d)')
    return
  end
  [atype,arows,acols,anum] = minfo(a);
  [btype,brows,bcols,bnum] = minfo(b);
  [ctype,crows,ccols,cnum] = minfo(c);
  p1 = strcmp(atype,'empt') & strcmp(btype,'empt') & strcmp(ctype,'empt');
  p2 = strcmp(atype,'cons') & strcmp(btype,'cons') & strcmp(ctype,'cons');
  if nargin == 3 % no d-matrix
    if p1 == 1  % all are empty matrices
      sys = [];
    elseif p2 == 1 % all constants
      d = zeros(crows,bcols);
      drows = crows;
      dcols = bcols;
      if arows == acols
        if brows == arows & ccols == arows & bcols == dcols & crows == drows
          rs = [arows ; zeros(arows+crows-1,1)];
          bs = [zeros(1,acols+bcols) -inf];
          sys = [a b;c d];
          sys = [sys rs;bs];
        else
          error('ABCD dimensions are not compatible')
          return
        end
      else
        error('A must be square')
        return
      end
    else % p1 = 0 and p2 = 0
      error('state space data should be CONSTANT matrix')
      return
    end
  else  % nargin == 4
    [dtype,drows,dcols,dnum] = minfo(d);
    if strcmp(dtype,'cons') &  p1 == 1
      sys = d;
    elseif strcmp(dtype,'empt') &  p1 == 1
      sys = [];
    elseif strcmp(dtype,'cons') & p2 == 1
      if arows == acols
        if brows == arows & ccols == arows & bcols == dcols & crows == drows
          rs = [arows ; zeros(arows+crows-1,1)];
          bs = [zeros(1,acols+bcols) -inf];
          sys = [a b;c d];
          sys = [sys rs;bs];
        else
          error('ABCD dimensions are not compatible')
          return
        end
      else
        error('A must be square')
        return
      end
    else % either d is not a CONSTANT/EMPTY, or p1 and p2 are both 0
      error('state space data should be CONSTANT matrix')
      return
    end
  end