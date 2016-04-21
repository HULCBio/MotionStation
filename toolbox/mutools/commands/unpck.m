% function [a,b,c,d] = unpck(sys)
%
%   Unpacks a SYSTEM matrix into its 4 separate
%   state-space entries.
%
%   See also: PCK, PSS2SYS, SYS2PSS, VPCK and VUNPCK.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [a,b,c,d] = unpck(sys)
  if nargin ~= 1
    disp('usage: [a,b,c,d] = unpck(sys)')
    return
  end
  [systype,sysr,sysc,sysn] = minfo(sys);
  if systype == 'syst'
    states = sysn;
    [nr nc] = size(sys);
    nr = nr-1;
    nc = nc-1;
    a = sys(1:states,1:states);
    b = sys(1:states,states+1:nc);
    c = sys(states+1:nr,1:states);
    d = sys(states+1:nr,states+1:nc);
  elseif systype == 'cons'
    a = [];
    b = [];
    c = [];
    d = sys;
  elseif systype == 'vary'
    error(['can''t unpack a VARYING matrix']);
    return
  else
    a = [];
    b = [];
    c = [];
    d = [];
  end
%
%