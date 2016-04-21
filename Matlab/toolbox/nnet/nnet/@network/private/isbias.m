function f=isbias(s)
%ISBIAS True if input is an NNBIAS structure.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if nnstruct(s,'nnbias')
  f = 1;
elseif isa(s,'double') & (prod(size(s)) == 0)
  f = 1;
else
  f = 0;
end
  
