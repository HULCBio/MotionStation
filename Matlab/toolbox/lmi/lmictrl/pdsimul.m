function [tout,x,y] = pdsimul(pds,ptraj,tf,ut,xi,options)
%  [t,x,y] = pdsimul(pds,'traj',tf,'ut',xi,options)
%
%  Simulation of an (affine) parameter-dependent system
%  along the parameter trajectory specified by the function
%  'TRAJ'.  The function PDSIMUL calls ODE15s to integrate
%  the time response of this linear time-varying system.
%
%  Without output arguments, PDSIMUL plots the output
%  trajectories.
%
%  Input:
%   PDS       affine parameter-dependent system (see PSYS)
%   'TRAJ'    name of the function  p=TRAJ(t)  specifying the
%             parameter trajectory. This function takes a time
%             t and returns a value p of the parameter vector.
%   TF        final time for the integration (initial=0)
%   'UT'      name of the input function  u=UT(t). The default
%             is a step input.
%   XI        initial state of the system (Default = 0)
%   OPTIONS   control parameters for the ODE integration
%             (see ODESET)
%
%  Output:
%   T         integration time points
%   X         state trajectories (X(:,1) = first state, etc.)
%   Y         output trajectories (Y(:,1) = first output, etc)
%
%
%  See also  GEAR, PSYS, PVEC.

%  Author: P. Gahinet  6/94, Revised 11/13/96
%  Copyright 1995-2004 The MathWorks, Inc.
%       $Revision: 1.7.2.3 $


if nargin<2,
  error('usage:   pdsimul(pds,ptraj,tf)');
elseif ~ispsys(pds),
  error('PDS must be a parameter-dependent system');
else
  if nargin<=2, tf=5; end
  if nargin<=3, ut='stepsml'; end
  if nargin<=4, xi=[]; end
  if nargin<=5, options=[]; end
end


if exist(ptraj) < 2,
  error(sprintf(['Undefined function ' ptraj]));
else
  p0 = feval(ptraj,0);
end

if exist(ut) < 2,
  error(sprintf(['Undefined function ' ut]));
else
  u0 = feval(ut,0);
end


[pdtyp,nv,ns,ni,no]=psinfo(pds);
pv=psinfo(pds,'par');
if isempty(pv),
  error(sprintf([...
  'The parameter vector description is missing! \n' ...
  '  Execute the command   pds = addpv(pds,pv) \n' ...
  '  and rerun PDSIMUL']));
end
[pvtyp,np]=pvinfo(pv);


% check consistency
if ~strcmp(pvtyp,'box'),
  error('PV must be of type ''box'' ');
elseif ~isempty(xi) & length(xi)~=ns,
  error(sprintf('Initial condition XI should have %d states',ns));
elseif np~=length(p0),
  error(sprintf(['The function ' ptraj ...
        ' should return a parameter vector of length %d'],np));
elseif ni~=length(u0),
  error(sprintf(['The input function UT ' ...
        'should return a parameter vector of length %d'],ni));
elseif isempty(xi),
  xi = zeros(ns,1);
end



range=pvinfo(pv,'par');
pds=pds(:,1:1+nv*(ns+ni+2));

if strcmp(pdtyp,'aff'),
    [t,x] = ode15s('affsim',[0 tf],xi,options,ut,ptraj,pds,pv,range);
    y = zeros(length(t),no);
    for i=1:length(t),
       y(i,:) = affsim(t(i),x(i,:).','output',ut,ptraj,pds,pv,range);
    end

else
    [t,x] = ode15s('polsim',[0 tf],xi,options,ut,ptraj,pds,pv,range);
    y = zeros(length(t),no);
    for i=1:length(t),
       y(i,:) = polsim(t(i),x(i,:).','output',ut,ptraj,pds,pv,range);
    end

end


if nargout>0,
   tout = t;
else
   plot(t,y)
   title('Output trajectory')
end







