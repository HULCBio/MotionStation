% function [matout,err] = xtract(mat,ivlow,ivhigh)
%   or
% function [matout,err] = xtract(mat,desiv)
%
%   3 INPUT ARGUMENTS:
%   ==================
%   Extract specified portion of a VARYING matrix, with
%   INDEPENDENT VARIABLE's values between IVLOW and IVHIGH.
%   XTRACT assumes that the INDEPENDENT VARIABLE value's are
%   sorted in ascending order.  Use SORTIV if necessary.
%
%   2 INPUT ARGUMENTS:
%   ==================
%   A VARYING matrix whose INDEPENDENT VARIABLE's value's
%   are closest (in absolute value) to the values of the
%   second input argument is extracted as a VARYING matrix
%   (with as many points as there are elements in the
%   second argument).
%
%   See also: SEL, VAR2CON, VPCK, VUNPCK, and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

%   ERR is set to -1 if IVLOW is greater than IVHIGH, ERR is
%   set to -2 if there are no INDEPENDENT VARIABLE values in
%   the range selected. ERR is set to -3 if the input matrix
%   is not a VARYING matrix. on a successful call, ERR is
%   set to 0.

function [matout,err] = xtract(mat,wlow,whigh)
  err = 0;
  if nargin < 2
    disp('usage: [matout,err] = xtract(mat,ivlow,ivhigh)')
    disp('  or')
    disp('usage: [matout,err] = xtract(mat,desiv)')
    return
  end
  if nargin == 3
    if wlow > whigh
      if nargout == 2
        err = -1;
        return
      else
        error(['ivlow should be <= ivhigh'])
        return
      end
    end
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mtype == 'vary'
    [nr,nc] = size(mat);
    omega = mat(1:mnum,nc);
    if nargin == 2
      if min(size(wlow)) > 1
        error('DESIV should be a vector of desired IV values')
        return
      end
      wlow = wlow(:);
      xmy = ones(length(omega),1)*wlow'-omega*ones(1,length(wlow));
      [val,loc] = min(abs(xmy));
      indvnum = loc';
      ivout = mat(indvnum,mcols+1);
%     v = kron(ones(mrows,1),mrows*(indvnum-1)); OLD:WRONG
      v = kron(mrows*(indvnum-1),ones(mrows,1)); %NEW:CORRECT ap10/24/93
      v = v + kron(ones(length(indvnum),1),[1:mrows]');
      rt = length(v);
      rivt = max(length(indvnum));
      matout = [mat(v,1:mcols) [ivout;zeros(rt-rivt,1)]; ...
                  zeros(1,mcols-1) length(indvnum) inf];
    else
      if max(size(omega)) == 1
        if omega(1) <= whigh & wlow <= omega(1)
         matout = mat;
        else
          if nargout == 2
            err = -2;
            out = [];
            return
          else
            error(['no INDEPENDENT VARIABLES in range selected'])
            return
          end
        end
      end
      [nr_om,nc_om] = size(omega);
      key = omega>=ones(nr_om,nc_om)*wlow & omega<=ones(nr_om,nc_om)*whigh;
      ptlow = min(find(key));
      pthigh = max(find(key));
      pt = [ptlow pthigh];
      if ~isempty(pt)
        matout = mat(mrows*(pt(1)-1)+1:mrows*pt(2),1:nc-1);
        newomega = omega(pt(1):pt(2));
        matout=vpck(matout,newomega);
      else
        if nargout == 2
          err = -2;
          return
        else
          error(['no INDEPENDENT VARIABLES in range selected'])
          return
        end
      end
    end
  else
    if nargout == 2
      err = -3;
      return
    else
      error(['input is not a valid VARYING matrix'])
      return
    end
  end
%
%