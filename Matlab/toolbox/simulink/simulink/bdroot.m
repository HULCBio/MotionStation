function root_sys = bdroot(origsys)
%BDROOT Return the name of the top-level Simulink system.
%   BDROOT returns the top-level system name.
%   
%   BDROOT('OBJ'), where 'OBJ' is a system or block path name, returns the
%   name of the the top-level system containing the specified object.
%   
%   Example:
%   
%       bdroot(gcb)
%   
%   returns the name of the top-level system that contains the current
%   block.
%
%   BDROOT(SYS) where SYS is a cell array of system names or a vector
%   of handles will also work.
%   
%   See also FIND_SYSTEM, GCB.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.21.2.1 $

%
% no input arguments, use the current system
%
root_sys=[];
if nargin==0,
  origsys = gcs;
end

switch class(origsys),
  case 'char',
    root_sys=LocalGetRootSys(origsys);
    
  case 'double',
    for lp=length(origsys):-1:1,
      root_sys(lp,1)=get_param(LocalGetRootSys(origsys(lp)),'Handle');
    end
  case 'cell'
    for lp=length(origsys):-1:1,
      root_sys{lp,1}=LocalGetRootSys(origsys{lp});
    end
  otherwise,
    error(['bdroot cannot handle objects of class ''',class(origsys),'''']);
end % switch

function root_sys = LocalGetRootSys(origsys)
temp_root_sys = origsys;
root_sys = temp_root_sys;

while ~isempty(temp_root_sys),
  root_sys = temp_root_sys;
  temp_root_sys = get_param(root_sys,'Parent');
end
