% function seeiv(mat)
%
%   Display the INDEPENDENT VARIABLE's values.
%
%   See also: DISP, FPRINTF, GETIV, SEE and SEESYS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function seeiv(mat)
 if nargin ~= 1
   disp('usage: seeiv(mat)');
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   [nr,nc] = size(mat);
   left = mnum - 5*floor(mnum/5);
   for i=1:floor(mnum/5)
     for j=1:5
       fprintf('  %.3e ',mat((i-1)*5+j,nc));
     end
     fprintf('\n')
   end
   if left > 0
     for i=1:left
       fprintf('  %.3e ',mat(mnum+i-left,nc));
     end
     fprintf('\n')
   end
 else
   disp('input matrix is not a VARYING matrix')
 end
%
%