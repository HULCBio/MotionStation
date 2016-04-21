% function matout = xtracti(mat,ivindex,ascon)
%
%   If MAT is a VARYING matrix, and IVINDEX is a
%   positive integer array, with
%
%               MAX(IVINDEX) <= LENGTH(GETIV(MAT))
%
%   then MATOUT is the matrix associated with
%   the IVINDEX'th INDEPENDENT VARIABLE's values.
%   MATOUT is, by default, a VARYING matrix.  If
%   the optional 3rd argument, ASCON, is set to
%   a positive number, then MATOUT is a constant
%   matrix containing the extracted data.
%
%   If MAT is a CONSTANT or SYSTEM matrix, and
%   INDVINDX is a positive integer, then MATOUT
%   is equal to MAT.
%
%   See also: GETIV, MINFO, SCLIV, SEL, VAR2CON
%   and XTRACT.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function matout = xtracti(mat,indvnum,ascon)
  err = 0;
  if nargin < 2
    disp('usage: matout = xtracti(mat,ivindex)')
    return
  end
  if isempty(indvnum)
    matout = [];
  elseif min(indvnum) < 1 | floor(indvnum) ~= ceil(indvnum)
    error('INDEPENDENT VARIABLE index should be positive integers')
    return
  else
    indvnum = indvnum(:);
    [mtype,mrows,mcols,mnum] = minfo(mat);
    if strcmp(mtype,'vary')
      if nargin == 2
        ascon = 0;
      end
      if ascon ~= 0
        ascon = 1;
      end
      if mnum >= max(indvnum) & ascon == 0
        ivout = mat(indvnum,mcols+1);
%       v = kron(ones(mrows,1),mrows*(indvnum-1));  OLD VERSION:WRONG
        v = kron(mrows*(indvnum-1),ones(mrows,1)); % NEW:CORRECT ap10/24/93
        v = v + kron(ones(length(indvnum),1),[1:mrows]');
        rt = length(v);
        rivt = max(length(indvnum));
        matout = [mat(v,1:mcols) [ivout;zeros(rt-rivt,1)]; ...
                 zeros(1,mcols-1) length(indvnum) inf];
      elseif mnum >= max(indvnum) & ascon == 1
%       v = kron(ones(mrows,1),mrows*(indvnum-1));  OLD VERSION:WRONG
        v = kron(mrows*(indvnum-1),ones(mrows,1)); % NEW:CORRECT ap10/24/93
        v = v + kron(ones(length(indvnum),1),[1:mrows]');
        matout = [mat(v,1:mcols)];
      else
        error('INDEPENDENT VARIABLE index too large for VARYING data')
        return
      end
    else
      matout = mat;
    end
  end