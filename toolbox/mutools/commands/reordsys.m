% function sysout = reordsys(sys,index);
%
%   Reorders the states of the SYSTEM matrix SYS as defined
%   by position variables in INDEX. The INDEX variable must be
%   of the same size as the number of states of SYS.
%
%   See also: STRANS, SRESID, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [sysout,ssysout] = reordsys(sys,index);
 if nargin ~= 2
   disp('usage: sysout = reordsys(sys,index)')
   return
 end

[mtype,mrows,mcols,mnum] = minfo(sys);

if mtype == 'syst'
  [a,b,c,d] = unpck(sys);
  mat = zeros(mnum);
  [nri,nci] = size(index);
  if nri == mnum & nci == 1
    index = index.';
    if sort(index) ~= [1:mnum]
      error('INDEX is incorrect')
      return
    end
  elseif nci == mnum & nri == 1
    if sort(index) ~= [1:mnum]
      error('INDEX is incorrect')
      return
    end
  else
    error('INDEX is wrong size')
    return
  end
  aax = a(index,index);
  bbx = b(index,:);
  ccx = c(:,index);
  sysout = pck(aax,bbx,ccx,d);
else
  error('input matrix is not a SYSTEM matrix')
  return
end
%
%