function [Jconstant,Jfcn,Jargs,Joptions] = ...
    odejacobian(fcnHandlesUsed,ode,t0,y0,options,extras)
%ODEJACOBIAN  Helper function for the Jacobian function in ODE solvers
%    ODEJACOBIAN determines whether the Jacobian is constant and if so,
%    returns its value as Jfcn. If an analytical Jacoban is available from
%    a function, ODEJACOBIAN initiallizes Jfcn and creates a cell array of
%    additional input arguments. For numerical Jacobian, ODEJACOBIAN tries to
%    extract JPattern and sets JOPTIONS for use with ODENUMJAC.
%
%   See also ODE15S, ODE23S, ODE23T, ODE23TB, ODENUMJAC.

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2003/05/19 11:16:25 $

Jconstant = strcmp(odeget(options,'JConstant','off','fast'),'on');
Jfcn = [];
Jargs = {};
Joptions = [];   

Janalytic = false;

if fcnHandlesUsed
  Jfcn = odeget(options,'Jacobian',[],'fast');
  if ~isempty(Jfcn)
    if isnumeric(Jfcn)
      Jconstant = true;
    else
      Janalytic = true;
      Jargs = extras;
    end
  end  
else  % ode-file used  
  joption = odeget(options,'Jacobian','off','fast');  
  switch lower(joption)
    case 'on'    % ode(t,y,'jacobian',p1,p2...)
      Janalytic = true;
      Jfcn = ode;
      Jargs = [{'jacobian'} extras];  
    case 'off'   % use odenumjac
    otherwise
      error('MATLAB:odejacobian:InvalidJOption',...
            ['Unrecognized option ''Jacobian'': ' joption]);
  end    
end  

if ~Janalytic   % odenumjac will be used
  Joptions.diffvar  = 2;       % df(t,y)/dy
  Joptions.vectvars = [];  
  vectorized = strcmp(odeget(options,'Vectorized','off','fast'),'on');  
  if vectorized
    Joptions.vectvars = 2;     % f(t,[y1,y2]) = [f(t,y1), f(t,y2)] 
  end
  
  atol = odeget(options,'AbsTol',1e-6,'fast');
  Joptions.thresh = zeros(size(y0))+ atol(:);  
  Joptions.fac  = [];
  
  if fcnHandlesUsed  
    jpattern = odeget(options,'JPattern',[],'fast'); 
  else  % ode-file used
    jp_option = odeget(options,'JPattern','off','fast'); 
    switch lower(jp_option)
      case 'on'
        jpattern = feval(ode,[],[],'jpattern',extras{:}); 
      case 'off'  % no pattern provided
        jpattern = [];
      otherwise
        error('MATLAB:odejacobian:InvalidJpOption',...
              ['Unrecognized option ''JPattern'': ' jp_option]);        
    end          
  end  
  if ~isempty(jpattern)
    Joptions.pattern = jpattern;    
    Joptions.g = colgroup(jpattern);
  end  
end
    
