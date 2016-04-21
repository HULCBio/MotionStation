
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mtblanks(n)
 if n == 0
   out = [];
 else
   out = [];
   for i=1:n
     out = [out ' '];
   end
 end
%
%