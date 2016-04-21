function [a,b,c,d,J] = dlinmod(model, Ts, varargin)
%DLINMOD Obtains linear models from systems of ODEs and discrete-time systems.
%   [A,B,C,D]=DLINMOD('SYS',TS) obtains a discrete-time state-space linear
%   model (with sample time TS) of the system of mixed continuous and 
%   discrete systems described in the block diagram 'SYS' when the state
%   variables and inputs are set to the defaults specified in the block 
%   diagram.
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U) allows the state vector, X, and
%   input, U, to be specified. A linear model will then be obtained
%   at this operating point.
% 
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,PARA) allows a vector of parameters to
%   be set.  PARA(1) sets the perturbation level (obsolete in R12 unless
%   using the 'v5' option - see below). For systems that are functions of 
%   time PARA(2) may be set with the the value of t at which the linear 
%   model is to be obtained (default t=0). Set PARA(3)=1 to remove extra 
%   states associated with blocks that have no path from input to output.
%
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5') uses the full-model-perturbation 
%   algorithm that was found in MATLAB 5.x.  The current algorithm 
%   uses pre-programmed linearizations for some blocks, and should be more
%   accurate in most cases.  The new algorithm also allows for special
%   treatment of problematic blocks such as the Transport Delay and
%   the Quantizer.  See the mask dialog of these blocks for more
%   information and options.
%     
%   [A,B,C,D]=DLINMOD('SYS',TS,X,U,'v5',PARA,XPERT,UPERT) uses the 
%   full-model-perturbation algorithm that was found in MATLAB 5.x. 
%   If XPERT and UPER are not given, PARA(1) will set the perturbation level 
%   according to:
%      XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%      UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%   The default perturbation level is PARA(1)=1e-5.
%   If vectors XPERT and UPERT are given they will be used as the perturbation
%   level for the systems states and inputs.
%
%   See also: DLINMODV5, LINMOD, LINMOD2, TRIM

%   S = DLINMOD('SYS',...) returns a structure containing the state-space
%   matrices, state names, operating point, and other information about
%   the linearized model.
%
%   [A,B,C,D,J] = DLINMOD('SYS',...) returns the sparse Jacobian structure
%   in addition to the state-space matrices.
%

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.47.4.4 $
%   Andrew Grace 11-12-90, 7-24-97
%   Greg Wolodkin 09-09-1999

% Ts is optional
if nargin < 2, Ts = []; end;

ni = nargin-2;
lmflag = 0;
v5flag = 0;
spflag = 0;
apflag = 'off';

% Accept a number of string arguments at the end of the list
while (ni > 0) && ischar(varargin{ni})
  lastarg = varargin{ni};
  ni = ni - 1;
  switch lower(lastarg)
  case 'ignorediscretestates'
    lmflag = 1;
    if ~isequal(Ts,0)
      warning('Forcing sample time to zero in LINMOD mode.');
      Ts = 0;
    end
  case 'v5'
    v5flag = 1;
  case 'sparse'
    spflag = 1;
  case 'useanalysisports'
    apflag = 'on';
  otherwise
    error('Unrecognized option.  HELP DLINMOD for more details.');
  end
end

if v5flag
    if spflag
        warning('Sparse matrices are not supported with ''v5'' option.');
    end
    if strcmp(apflag,'on')
        warning('Analysis ports are not supported with ''v5'' option.');
    end
    if (lmflag) 
      [a,b,c,d] = linmodv5(model,varargin{1:ni});
    else
      [a,b,c,d] = dlinmodv5(model,Ts,varargin{1:ni});
    end
    return
end

% Parameter settings we need to set/cache before linearizing
want = struct('AnalyticLinearization','on',...
	      'UseAnalysisPorts', apflag, ...
	      'BufferReuse', 'off',...
	      'SimulationMode', 'normal',...
	      'RTWInlineParameters', 'on');

% Old argument parsing
if ni < 1, x    = []; else    x = varargin{1}; end
if ni < 2, u    = []; else    u = varargin{2}; end
if ni < 3, para = []; t = []; else para = varargin{3}; end

if isempty(para), para = [0;0;0]; end

% If [x,u] are given we need some info from the model
if ni > 0
  [sizes, x0, x_str, pp, qq] = feval(model,[],[],[],'sizes'); 
  StateName = LocalUniqueNames(x_str);

  if isempty(x), x = x0; end;
  if isempty(u), u = zeros(sizes(4),1); end
  t = 0;

  if para(1) == 0, para(1) = 1e-5; end          % unused
  if length(para)>1, t = para(2); end
  if length(para)<3, para(3) = 0; end

  % Time in the first column, u in the remaining columns
  if length(u) == sizes(4)
    u = [t reshape(u,1,sizes(4))];
  else
    error(sprintf('Expecting an input vector of length %i', sizes(4)));
  end

  % Allow for a structure to specify initial states (LTI viewer)
  % Re-order these if necessary, in case block sorting order has changed.
  if isstruct(x),
    try
      xNames = LocalUniqueNames(x.Names);
      x = x.Values;
    catch
      error('State structure must contain fields ''Names'' and ''Values''.');
    end
    [garb,indOld,indNew]=intersect(xNames,StateName);
    if ~isequal(indOld,indNew),
      x(indNew) = x(indOld);
    end
  end 

  nxz = sizes(1)+sizes(2);
  if length(x) < nxz
    warning('Extra states are being set to zero.');
    x = [x(:); zeros(nxz-length(x),1)];
  end

  % More block diagram state settings unique to [t,x,u] case
  if (sizes(1)+sizes(2) > 0)
    want = setfield(want, 'InitialState', mat2str(x));
    want = setfield(want, 'LoadInitialState', 'on');
  end
  if (sizes(4) > 0)
    want = setfield(want, 'ExternalInput', mat2str(u));
    want = setfield(want, 'LoadExternalInput', 'on');
  end
  want = setfield(want, 'StartTime', mat2str(t));
  want = setfield(want, 'StopTime',  mat2str(t+1));
  want = setfield(want, 'OutputOption', 'RefineOutputTimes');
end

% Load model, save old settings, install new ones suitable for linearization
[have, preloaded] = local_push_context(model, want);

% Don't let sparse math re-order columns
autommd_orig = spparms('autommd');
spparms('autommd', 0);

try
  J = get_param(model,'Jacobian');
  a = J.A; b = J.B; c = J.C; d = J.D; M = J.Mi;

  if (lmflag)      % LINMOD mode

    % Remove discrete states
    if any(J.Ts(1:size(a,1)))
      warning('Ignoring discrete states (use DLINMOD for proper handling)');
      ix = find(J.Ts(1:size(a,1)) ~= 0);
      a(ix,:) = [];
      a(:,ix) = [];
      b(ix,:) = [];
      c(:,ix) = [];
    end

    P = speye(size(d,1)) - d*M.E;
    Q = P \ c;
    R = P \ d;

    % Close the LFT
    a = a + b * M.E * Q;
    b = b * (M.F + M.E * R * M.F);
    c = M.G * Q;
    d = M.H + M.G * R * M.F;
    
  else              % DLINMOD mode
    
    [ny,nu] = size(d);
    nxz = size(a,1);
    Tsx = J.Ts(1:nxz);
    Tsy = J.Ts(nxz+1:end);
    Tuq = unique(J.Ts(J.Ts >= 0));
    
    % Default is least common multiple of all sample times.
    if isempty(Ts)
      Ts = local_vlcm(Tuq);
      if isempty(Ts)
        % if model has fixed step size specified use that
        modelSolver = get_param(model,'Solver');
        modelFixedStepSize = get_param(model,'FixedStep');
        if ( ~strcmpi(modelFixedStepSize,'auto') && ...
             ( strcmp(modelSolver,'ode5') || ...
               strcmp(modelSolver,'ode4') || ...
               strcmp(modelSolver,'ode3') || ...
               strcmp(modelSolver,'ode2') || ...
               strcmp(modelSolver,'ode1') || ...
               strcmp(modelSolver,'FixedStepDiscrete')))
          warning(['No sample time found in the model. ',...
                   'Defaulting to fixed step size']);
          Ts = str2num(modelFixedStepSize);
        else
          warning('No sample time found in the model.  Defaulting to 1');
          Ts = 1;
        end
      end
    end
    
    Tslist = [ Tuq ; Ts ];
    Eslow  = M.E;
    
    for k=1:length(Tslist)-1
      % Start with the fastest rate
      ts_current = Tslist(k);
      ts_next    = min(Ts, Tslist(k+1));
      
      xix = find(Tsx == ts_current);
      nix = find(Tsx ~= ts_current);
      
      % Close the fastest loops
      [ix,jx,px] = find(Eslow);
      ux    = ismember(jx, find(Tsy==ts_current));
      Efast = sparse(ix(ux),jx(ux),px(ux),nu,ny);
      
      % And mark them as closed (remove them from interconnection matrix)
      Eslow = Eslow - Efast;
      P = speye(ny) - d*Efast;
      
      % But leave the matrices "full-sized" for later connection 
      c = P \ c;
      d = P \ d;
      a = a + b * Efast * c;
      b = b * (speye(nu) + Efast*d);
      
      % if the target rate is the slowest rate we are done
      if ts_current ~= ts_next
	
	% Otherwise use c2d/d2d/d2c to reach the next rate
	nxfast = length(xix);
	atmp = full(a(xix,xix));
	
	if ts_current ~= 0
	  if ts_next ~= 0
	    [Phi,Gam] = d2d(atmp, eye(nxfast), ts_current, ts_next);
	  else
	    [Phi,Gam] = d2ci(atmp, eye(nxfast), ts_current);
	  end
	else
	  [Phi,Gam] = c2d(atmp, eye(nxfast), ts_next);
	end
	a(xix,xix) = Phi;
	if length(nix)
	  a(xix,nix) = Gam*a(xix,nix);
	end
	if nu
	  b(xix,:) = Gam*b(xix,:);
	end
      end
      Tsx(xix) = ts_next;
    end

    % Apply analysis input and output selection
    b = b * M.F;
    c = M.G * c;
    d = M.H + M.G * d * M.F;

  end    % LINMOD/DLINMOD

  % Compatibility..
  if spflag == 0
    a = full(a); b = full(b); c = full(c); d = full(d);
  end

  if para(3) == 1, [a,b,c] = minlin(a,b,c); end

  if nargout == 2
    disp('Returning transfer function model')
    % Eval it in case it's not on the path
    [a,b] = feval('ss2tf',a,b,c,d,1);
  end

  % Structure return for single-output case
  if nargout == 1
    op = struct('x',x(:),'u',u(2:end),'t',t);
    a = struct('a',a,'b',b,'c',c,'d',d,...
               'StateName', {J.StateName},...
               'OutputName',{J.Mi.OutputName},...
               'InputName', {J.Mi.InputName},...
               'OperPoint',op,...
               'Ts',Ts);
  end
  errmsg = [];
catch
  errmsg = lasterr;
end

% Restore sparse math and block diagram settings
spparms('autommd', autommd_orig);
local_pop_context(model, have, preloaded);
error(errmsg)

%---

function xNames = LocalUniqueNames(xNames)
% Append numbers to names which are not unique

[xTemp,ix,jx] = unique(xNames);
if length(xTemp) < length(xNames),
   for k=1:length(xNames)
      if jx(k) > 0
         kx = find(jx==jx(k));
         if length(kx) > 1
            for n=1:length(kx)
               xNames{kx(n)} = [xNames{kx(n)} '(' int2str(n) ')'];
            end
            jx(kx) = zeros(size(kx));
         end
      end
   end
end

%---

function M = local_vlcm(x)
% VLCM  find least common multiple of several sample times

% Protect against a few edge cases, remove zeros and Infs before computing LCM
x(~x) = [];
x(isinf(x)) = [];
if isempty(x), M = []; return; end;

[a,b]=rat(x);
v = b(1);
for k = 2:length(b), v=lcm(v,b(k)); end
d = v;

y = round(d*x);         % integers
v = y(1);
for k = 2:length(y), v=lcm(v,y(k)); end
M = v/d;

%---

function [old, preloaded] = local_push_context(model, new)
% Save model parameters before setting up new ones
  
% Make sure the model is loaded
if isempty(find_system('SearchDepth',0,'CaseSensitive','off','Name',model))
  preloaded = 0;
  load_system(model);
else 
  preloaded = 1;
end 

% Save this before calling set_param() ..
old = struct('Dirty', get_param(model,'Dirty'));

f = fieldnames(new);
for k = 1:length(f)
  prop = f{k};
  have_val = get_param(model, prop);
  want_val = getfield(new, prop);
  if ~isequal(have_val, want_val)
    set_param(model, prop, want_val);
    old = setfield(old, prop, have_val);
  end
end

%---

function local_pop_context(model, old, preloaded)
% Restore model parameters from previous context

f = fieldnames(old);
for k = 1:length(f)
  prop = f{k};
  if ~isequal(prop,'Dirty')
    set_param(model, prop, getfield(old, prop));
  end
end

set_param(model, 'Dirty', old.Dirty); %% man, should be the last set_param

if preloaded == 0
  close_system(model,0);
end
