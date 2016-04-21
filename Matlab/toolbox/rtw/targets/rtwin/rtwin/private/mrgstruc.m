function dst = mrgstruc(dst, src)
%MRGSTRUC Merge two structures.
%   MRGSTRUC merges two structures so that the first structure receives
%   those fields of the second structure that are not already present.
%
%   Private function.

%   Copyright 1994-2003 The MathWorks, Inc.
%   $Revision: 1.4.2.1 $  $Date: 2003/12/31 19:45:51 $  $Author: batserve $

for f = fieldnames(src)'
  f = f{:};
  if ~isfield(dst, f) || isempty(dst.(f))
    dst.(f) = src.(f);
  end;
end;
