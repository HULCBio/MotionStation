% function out = cjt(mat)
%
%   Complex conjugate transpose for VARYING matrices;
%
%   Complex conjugate transpose (adjoint system) for
%      SYSTEM matrices.
%
%   See also: ', .', TRANSP, VCJT, VTP

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = cjt(mat)
 if nargin ~= 1
   disp('usage: out = cjt(mat)')
   return
 end
 [mtype,mrows,mcols,mnum] = minfo(mat);
 if strcmp(mtype,'vary')
   [vd,rp,indv] = vunpck(mat);
   out = zeros(mcols*mnum+1,mrows+1);
   out(mcols*mnum+1,mrows+1) = inf;
   out(mcols*mnum+1,mrows) = mnum;
   out(1:mnum,mrows+1) = indv;
   for i=1:mnum
     out(1+mcols*(i-1):i*mcols,1:mrows) = ...
         mat(rp(i):rp(i)+mrows-1,1:mcols)';
   end
 elseif strcmp(mtype,'syst')
   [a,b,c,d] = unpck(mat);
   out = pck(-a',-c',b',d');
 else
   out = mat';
 end
%
%