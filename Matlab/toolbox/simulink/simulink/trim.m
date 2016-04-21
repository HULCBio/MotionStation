function [x,u,y,dx,options]=trim(fcn,varargin)
%TRIM   Finds steady state parameters for a Simulink system. 
%
%   TRIM solves for steady-state parameters that satisfy 
%   certain input, output and state conditions.
%
%   [X,U,Y,DX]=TRIM('SYS') attempts to find values for X, U and Y
%   that set the state derivatives, DX, of the S-function 'SYS' to
%   zero. TRIM uses a constrained optimization technique.
%
%   [X,U,Y,DX]=TRIM('SYS',X0,U0) sets the initial starting guesses
%   for X and U to X0 and U0, respectively.
%
%   [X,U,Y,DX]=TRIM('SYS',X0,U0,Y0,IX,IU,IY) fixes X, U and Y to
%   X0(IX), U0(IU) and Y0(IY). The variables IX, IU and IY are vectors
%   of indices.  If no solution to this problem can be found then TRIM
%   will attempt to find values that minimize the maximum deviation
%   from the intended values.
%   If IX is not empty, but does not include all the states, then the
%   states not indexed in IX are free to vary. Similarly, if IU is not
%   empty and does not include all the inputs, then the inputs omitted
%   from IU are free to vary.
%
%   [X,U,Y,DX]=TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX) fixes the
%   derivatives indexed by IDX to DX(IDX). Derivatives not indexed are
%   free to vary.
%
%   [X,U,Y,DX]=TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX,IDX,OPTIONS) allows
%   the optimization parameters to be set. See CONSTR in the 
%   Optimization Toolbox for details.  If you don't have this toolbox,
%   see the online documentation.
%
%   [X,U,Y,DX]=TRIM('SYS',X0,U0,Y0,IX,IU,IY,DX0,IDX,OPTIONS,T) sets the   
%   time to T if 'SYS' is dependent on time.
%
%   To see more help, enter TYPE TRIM.
%   See also LINMOD.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.37 $
%   Andrew Grace 11-12-90.
%   Revised: Marc Ullman 8-26-96

%   Any or all of X0,U0,Y0,IX,IU,IY,DX0,IDX,OPTIONS,T
%   may be empty matrices in which case these parameters will be assumed
%   to be undefined and the default option will be used.
%   For example,  TRIM('SYS',X0,U0,Y0) is equivalent to
%   TRIM('SYS',X0,U0,Y0,[],[],[]);
%

% make sure model is supported
supportMsg = linmodsupported(fcn);
if ~isempty(supportMsg)
    error(supportMsg);
end

load_system(fcn);

% Save, set and then restore the folloing set params, dirty has to be first.
pnames  = {'Dirty', 'SimulationMode'};
pnewval = {'',      'normal'};
for i=1:length(pnames),
  poldval{i} = get_param(fcn,pnames{i});
  if ~isempty(pnewval{i}),
    set_param(fcn, pnames{i}, pnewval{i});
  end
end  

lasterr('');
errmsg = '';

try
  % Pre-compile the model
  feval(fcn, [], [], [], 'lincompile');
  
  try 
    % Run the algorithm as a subroutine so we can trap errors and <CTRL-C>
    [x,u,y,dx,options]=trim_alg(fcn,varargin{:});
  catch
    errmsg = lasterr;
  end
  % Release the compiled model
  feval(fcn, [], [], [], 'term');
  
catch
  errmsg = lasterr;
end

% restore the set_params in the reverse order, so that dirty gets restored last.
for i=length(pnames):-1:1
  set_param(fcn, pnames{i}, poldval{i});
end

% Issue an error if one occured during the trim.
if ~isempty(errmsg),
  error(errmsg);
end

% end trim

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,u,y,dx,options]=trim_alg(fcn,x0,u0,y0,ix,iu,iy,dx0,idx,para,t)

[sizes,state0,Order,Ts]=feval(fcn, [], [], [], 'sizes');

sizes=[sizes(:); zeros(6-length(sizes),1)];
nxz=sizes(1)+sizes(2); nu=sizes(4); ny=sizes(3); nx = sizes(1);

if nxz == 0
  error('System must have at least one state in order to be trimmed.')
end

% If arguments not defined then make empty
if nargin<2, x0=[]; end
if nargin<3, u0=[]; end
if nargin<4, y0=[]; end
if nargin<5, ix=[]; end
if nargin<6, iu=[]; end
if nargin<7, iy=[]; end
if nargin<8, dx0=[]; end
if nargin<9, idx=[]; end
if nargin<10, para=[]; end
if nargin<11, t=0; end

% If no intial guesses then use system's initial state
if isempty(x0), x0=state0; end

% If no intial guesses then use zeros
if isempty(u0), u0=zeros(nu,1); end
if isempty(y0), y0=zeros(ny,1); end
if isempty(dx0), dx0=zeros(sizes(1),1); end
if isempty(para), para=0; end


% If no fixed elements set index to minimize worst deviation from given
% values:
if isempty([ix(:);iy(:);iu(:)]), ix=[1:nxz]; iy=[1:ny]; iu=[1:nu]; end
if isempty(idx); idx=[1:nx]; end

% Set up nx+nz equality constraints to force the derivatives to zero.
para(13)=length(idx);
para(7) = 1; % Use minimax merit function and Hessian update.

% Initial guesses
x=x0;
u=u0;

y = feval(fcn, t, x, u, 'outputs');
gg=[x(ix)-x0(ix);y(iy)-y0(iy);u(iu)-u0(iu)];
% Objective function is lambda
lambda=max(abs(gg));
caller = 'trim';
[xu,options] = simcnstr(caller,'trimfcn',...
                        [x;u;lambda],para,[],[],[],fcn,t,x0,u0,y0,...
                        ix,iu,iy,dx0,idx);
% Unravel x and u
x=xu(1:nxz); u=xu(nxz+1:nxz+nu);
y = feval(fcn, t, x, u, 'outputs');
dx = feval(fcn, t, x, u, 'derivs');
