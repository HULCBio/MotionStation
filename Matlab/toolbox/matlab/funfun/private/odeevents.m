function [haveeventfun,eventFcn,eventArgs,eventValue,teout,yeout,ieout] =...
    odeevents(FcnHandlesUsed,ode,t0,y0,options,extras) 
%ODEEVENTS  Helper function for the events function in ODE solvers
%    ODEEVENTS initializes eventFcn to the events function, and creates a
%    cell-array of its extra input arguments. ODEEVENTS evaluates the events
%    function at(t0,y0).    
%
%   See also ODE113, ODE15S, ODE23, ODE23S, ODE23T, ODE23TB, ODE45.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/05/19 11:16:24 $

haveeventfun = 0;   % no Events function
eventArgs = [];
eventValue = [];
teout = [];
yeout = [];
ieout = [];

eventFcn = odeget(options,'Events',[],'fast');
if isempty(eventFcn)
  return
end

if FcnHandlesUsed     % function handles used 
  haveeventfun = 1;   % there is an Events function
  eventArgs = extras;
  eventValue = feval(eventFcn,t0,y0,eventArgs{:});   

else   % ode-file used    
  switch lower(eventFcn)
    case 'on'
      haveeventfun = 1;   % there is an Events function
      eventFcn = ode;            % call ode(t,y,'events',p1,p2...)
      eventArgs = [{'events'}, extras];
      eventValue = feval(eventFcn,t0,y0,eventArgs{:});   
    case 'off'
    otherwise 
      error('MATLAB:odeevents:MustSetOnOrOff',...
            ['The ODE option ''Events'' must be set to ' ...
             '''on'' | ''off'' '])
  end  
  
end
