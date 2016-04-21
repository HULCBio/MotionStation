function [neq, tspan, ntspan, next, t0, tfinal, tdir, y0, f0, args, ...
          options, threshold, rtol, normcontrol, normy, hmax, htry, htspan, ...
          dataType] =   ...
    odearguments(FcnHandlesUsed, solver, ode, tspan, y0, options, extras)
%ODEARGUMENTS  Helper function that processes arguments for all ODE solvers.
%
%   See also ODE113, ODE15I, ODE15S, ODE23, ODE23S, ODE23T, ODE23TB, ODE45.

%   Mike Karr, Jacek Kierzenka
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.12.4.5 $  $Date: 2004/04/16 22:06:47 $

if strcmp(solver,'ode15i')
  FcnHandlesUsed = true;   % no MATLAB v. 5 legacy for ODE15I
end  

if FcnHandlesUsed  % function handles used
  msg = ['When the first argument to ', solver,' is a function handle, '];
  if isempty(tspan) || isempty(y0) 
    error('MATLAB:odearguments:TspanOrY0NotSupplied',...
          [msg 'the tspan and y0 arguments must be supplied.']);
  end      
  if length(tspan) < 2
    error('MATLAB:odearguments:SizeTspan',...
          [msg 'the tspan argument must have at least two elements.']);
  end  
  htspan = abs(tspan(2) - tspan(1));  
  tspan = tspan(:);
  ntspan = length(tspan);
  t0 = tspan(1);  
  next = 2;       % next entry in tspan
  tfinal = tspan(end);     
  args = extras;                 % use f(t,y,p1,p2...) 

else  % ode-file used   (ignored when solver == ODE15I)
  if ~( isempty(options) || isa(options,'struct') )
    if (length(tspan) == 1) && (length(y0) == 1) && (min(size(options)) == 1)
      tspan = [tspan; y0];
      y0 = options;
      options = [];
      warning('MATLAB:odearguments:ObsoleteSyntax',['Obsolete syntax.  Use ' ...
               '%s(fun,tspan,y0,...) instead.'],solver);
    else
      error('MATLAB:odearguments:IncorrectSyntax',...
            ['Correct syntax is ', solver, '(', funstring(ode), ...
             ',tspan,y0,options).']);      
    end
  end   
  % Get default tspan and y0 from the function if none are specified.
  if isempty(tspan) || isempty(y0) 
    if exist(ode)==2 && ( nargout(ode)<3 && nargout(ode)~=-1 ) 
      % nargout M-files only
      msg = sprintf('Use %s(%s,tspan,y0,...) instead.',solver,funstring(ode));
      error('MATLAB:odearguments:NoDefaultParams',...
            ['No default parameters in ' funstring(ode) '.  ' msg]);
    end
    [def_tspan,def_y0,def_options] = feval(ode,[],[],'init',extras{:});
    if isempty(tspan)
      tspan = def_tspan;
    end
    if isempty(y0)
      y0 = def_y0;
    end
    options = odeset(def_options,options);
  end  
  tspan = tspan(:);
  ntspan = length(tspan);
  if ntspan == 1    % Integrate from 0 to tspan   
    t0 = 0;          
    next = 1;       % Next entry in tspan.
  else              
    t0 = tspan(1);  
    next = 2;       % next entry in tspan
  end
  htspan = abs(tspan(next) - t0);
  tfinal = tspan(end);   
  
  % The input arguments of f determine the args to use to evaluate f.
  if (exist(ode)==2)               % M-file
    if (nargin(ode) == 2)           
      args = {};                   % f(t,y)
    else
      args = [{''} extras];        % f(t,y,'',p1,p2...)
    end
  else  % MEX-files, etc.
    try 
      args = [{''} extras];        % try f(t,y,'',p1,p2...)     
      feval(ode,tspan(1),y0(:),args{:});   
    catch
      lasterr('');
      args = {};                   % use f(t,y) only
    end
  end
end

y0 = y0(:);
neq = length(y0);

% Test that tspan is internally consistent.
if t0 == tfinal
  error('MATLAB:odearguments:TspanEndpointsNotDistinct',...
        'The last entry in tspan must be different from the first entry.');
end
tdir = sign(tfinal - t0);
if any( tdir*diff(tspan) <= 0 )
  error('MATLAB:odearguments:TspanNotMonotonic',...
        'The entries in tspan must strictly increase or decrease.');
end

f0 = feval(ode,t0,y0,args{:});   % ODE15I sets args{1} to yp0.
[m,n] = size(f0);
if n > 1
  error('MATLAB:odearguments:FoMustReturnCol',...
        [funstring(ode) ' must return a column vector.'])
elseif m ~= neq
  msg = sprintf('an initial condition vector of length %d.',m);
  error('MATLAB:odearguments:SizeIC', ['Solving ' funstring(ode) ' requires ' msg]);
end

% Determine the dominant data type
classT0 = class(t0);
classY0 = class(y0);
classF0 = class(f0);
if strcmp(solver,'ode15i')  
  classYP0 = class(args{1});  % ODE15I sets args{1} to yp0.
  dataType = superiorfloat(t0,y0,args{1},f0);

  if ~( strcmp(classT0,dataType) && strcmp(classY0,dataType) && ...
        strcmp(classF0,dataType) && strcmp(classYP0,dataType))
    warning('MATLAB:odearguments:InconsistentDataType',...
            ['Mixture of single and double data for ''t0'', ''y0'', ''yp0'', ',...
             'and ''f(t0,y0,yp0)'' in call to %s.'],solver);
  end    
else  
  dataType = superiorfloat(t0,y0,f0);
  
  if ~( strcmp(classT0,dataType) && strcmp(classY0,dataType) && ...
        strcmp(classF0,dataType))
    warning('MATLAB:odearguments:InconsistentDataType',...
            ['Mixture of single and double data for ''t0'', ''y0'', and ''f(t0,y0)'' ',...
             'in call to %s.'],solver);
  end        
end

% Get the error control options, and set defaults.
rtol = odeget(options,'RelTol',1e-3,'fast');
if (length(rtol) ~= 1) || (rtol <= 0)
  error('MATLAB:odearguments:RelTolNotPosScalar', 'RelTol must be a positive scalar.');
end
if rtol < 100 * eps(dataType) 
  rtol = 100 * eps(dataType);
  warning('MATLAB:odearguments:RelTolIncrease', ...
          'RelTol has been increased to %g.',rtol)
end
atol = odeget(options,'AbsTol',1e-6,'fast');
if any(atol <= 0)
  error('MATLAB:odearguments:AbsTolNotPos', 'AbsTol must be positive.');
end
normcontrol = strcmp(odeget(options,'NormControl','off','fast'),'on');
if normcontrol
  if length(atol) ~= 1
    error('MATLAB:odearguments:NonScalarAbsTol',...
          'Solving with NormControl ''on'' requires a scalar AbsTol.');
  end
  normy = norm(y0);
else
  if (length(atol) ~= 1) && (length(atol) ~= neq)
    error('MATLAB:odearguments:SizeAbsTol',...
          'Solving %s requires a scalar AbsTol, or a vector AbsTol of length %i',...
           funstring(ode), neq); 
  end
  atol = atol(:);
  normy = [];
end
threshold = atol / rtol;

% By default, hmax is 1/10 of the interval.
hmax = min(abs(tfinal-t0), abs(odeget(options,'MaxStep',0.1*(tfinal-t0),'fast')));
if hmax <= 0
  error('MATLAB:odearguments:MaxStepLEzero', 'Option ''MaxStep'' must be greater than zero.');
end
htry = abs(odeget(options,'InitialStep',[],'fast'));
if ~isempty(htry) && (htry <= 0)
  error('MATLAB:odearguments:InitialStepLEzero',...
        'Option ''InitialStep'' must be greater than zero.');
end
