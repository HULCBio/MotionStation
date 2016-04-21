% subsys = ssub(sys,inputs,outputs)
%
% Extracts the subsystem  SUBSYS  of  SYS  obtained by selecting
% particular inputs and outputs
%
% Input:
%  SYS          LTI system or polytopic/parameter-dependent
%               system
%  INPUTS       vector of indices specifying the selected
%               inputs.  The first input is the top one in
%               the block-diagram representation of the system.
%  OUTPUTS      same for the outputs
%
%
% See also   LTISYS, PSYS.

% Author: P. Gahinet  6/94
% Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.6.2.3 $

function sys = ssub(sys,inputs,outputs)

if nargin < 3,
  error('usage: subsys = ssub(sys,inputs,outputs)');
end

if ispsys(sys),

   [pdtype,nv]=psinfo(sys); s=[];
   for j=1:nv, s=[s ssub(psinfo(sys,'sys',j),inputs,outputs)]; end

   pdtype=1+strcmp(pdtype,'aff');
   sys=psys(psinfo(sys,'par'),s,pdtype);

elseif islsys(sys),

   [rs,cs]=size(sys);
   na=sys(1,cs);

   sys=sys([1:na,na+outputs,rs],[1:na,na+inputs,cs]);

else

   sys=sys(outputs,inputs);

end
