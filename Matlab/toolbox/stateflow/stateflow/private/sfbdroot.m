function root_sys = sfbdroot(origsys)
%SFBDROOT Return the name of the top-level Simulink system.
%   SFBDROOT returns the top-level system name.
%   
%   SFBDROOT('OBJ'), where 'OBJ' is a system or block path name, returns the
%   name of the the top-level system containing the specified object.
%   
%   Example:
%   
%       sfbdroot(gcb)
%   
%   returns the name of the top-level system that contains the current
%   block.
%
%   SFBDROOT(SYS) where SYS is a cell array of system names or a vector
%   of handles will also work.
%   
%   See also FIND_SYSTEM, GCB, BDROOT.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.1 $

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
end % switch

function root_sys = LocalGetRootSys(origsys)
  root_sys = origsys;
  if ~isempty(origsys),
    root_sys = strtok(getfullname(origsys),'/');
  end

