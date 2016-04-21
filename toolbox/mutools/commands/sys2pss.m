% function mat = sys2pss(sys)
%
%   Unpacks a SYSTEM matrix into a packed matrix,
%    MAT = [A B; C D];
%
%   See also: PCK, PSS2SYS, UNPCK, VPCK and VUNPCK.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [mat] = sys2pss(sys)
  if nargin ~= 1
    disp('usage: mat = sys2pss(sys)')
    return
  end
  [systype,sysr,sysc,sysn] = minfo(sys);
  if systype == 'syst'
    [nr nc] = size(sys);
    nr = nr-1;
    nc = nc-1;
    mat = sys(1:nr,1:nc);
  elseif systype == 'cons'
    mat = sys;
  elseif systype == 'vary'
    error(['can''t unpack a VARYING matrix']);
    return
  else
    mat = [];
  end
%
%