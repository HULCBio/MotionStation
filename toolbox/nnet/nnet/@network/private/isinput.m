function f=isinput(s)
%ISINPUT True if input is an NNINPUT structure.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if ~nnstruct(s,'nninput')
  f = 0;
else
  f = 1;
end
  
