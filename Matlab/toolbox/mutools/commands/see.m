% function see(mat,iv_low,iv_high)
%
%   Display a specified range of a VARYING matrix or
%   display state-space entries of a SYSTEM matrix
%
%   See also: DISP, FPRINTF, GETIV, PCK, RIFD, SEESYS,
%             SEEIV and SORTIV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function see(mat,olow,ohigh)
 if nargin == 0 | nargin == 2
   disp('usage: see(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if mtype == 'vary'
   if nargin == 3
     [mat,err] = xtract(mat,olow,ohigh);
     if err == -1
       error('iv_high should be greater than iv_low')
       return
     elseif err == -2
       error('no iv values in iv range')
       return
     end
     [mtype,mrows,mcols,mnum] = minfo(mat);
   end
   [nr,nc] = size(mat);
   place = 1;
   omega = mat(1:mnum,nc);
   if mrows > 1
     if mcols > 1
       fprintf('%.0f rows  %.0f columns\n',mrows,mcols)
     else
       fprintf('%.0f rows  %.0f column\n',mrows,mcols)
     end
   else
     if mcols > 1
       fprintf('%.0f row  %.0f columns\n',mrows,mcols)
     else
       fprintf('%.0f row  %.0f column\n',mrows,mcols)
     end
   end
   fprintf('\n')
   for i=1:mnum
%    fprintf('indep variable  %g\n',omega(i))
     fprintf('iv  =  %g\n',omega(i))
     disp(mat(place:place+mrows-1,1:mcols))
     place = place + mrows;
   end
 elseif mtype == 'syst'
   clc
   disp('A matrix')
   disp(mat(1:mnum,1:mnum))
   disp('strike any key to move to B matrix')
   pause
   clc
   disp('B matrix')
   disp(mat(1:mnum,mnum+1:mnum+mcols))
   disp('strike any key to move to C matrix')
   pause
   clc
   disp('C matrix')
   disp(mat(mnum+1:mnum+mrows,1:mnum))
   disp('strike any key to move to D matrix')
   pause
   clc
   disp('D matrix')
   disp(mat(mnum+1:mnum+mrows,mnum+1:mnum+mcols))
 else
   disp(mat)
end
%
%