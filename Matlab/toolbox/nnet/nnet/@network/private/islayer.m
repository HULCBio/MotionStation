function f=islayer(s)
%ISLAYER True if input is an NNLAYER structure.

%  Mark Beale, 11-31-97
%  Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.7 $

if ~nnstruct(s,'nnlayer')
  f = 0;
else
  f = 1;
end
  
