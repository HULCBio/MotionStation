% function out = vcjt(mat)
%
%   Complex conjugate transpose for CONSTANT/VARYING matrices;
%
%   See also: ', .', CTP, TRANSP, and VTP

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vcjt(mat)
 if nargin ~= 1
   disp('usage: out = vcjt(mat)')
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
 elseif strcmp(mtype,'cons')
   out = mat';
 elseif strcmp(mtype,'syst')
   error(['VCJT does not work on SYSTEM matrices']);
   return
 else
   out = [];
 end
%
%