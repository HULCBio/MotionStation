function [A,B,C,D]=linmodv5(fcn,varargin)
%  LINMODV5 Obtains linear models from systems of ord. diff. equations (ODEs) 
%     using the full-model-perturbation algorithm that was found in MATLAB 5.x.
% 
%     [A,B,C,D]=LINMODV5('SYS') obtains the state-space linear model of the
%     system of ordinary differential equations described in the
%     block diagram 'SYS' when the state variables and inputs are set
%     to zero.
%  
%     [A,B,C,D]=LINMODV5('SYS',X,U) allows the state vector, X, and
%     input, U, to be specified. A linear model will then be obtained
%     at this operating point.
%  
%     [A,B,C,D]=LINMODV5('SYS',X,U,PARA) allows a vector of parameters
%     to be set.  PARA(1) sets the perturbation level for obtaining the
%     linear model (default PARA(1)=1e-5) according to:
%        XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%        UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%     where XPERT and UPERT are the perturbation levels for the system's states
%     and inputs. For systems that are functions of time PARA(2) may be set with
%     the value of t at which the linear model is to be obtained (default PARA(2)=0).
%     Set PARA(3)=1 to remove extra states associated with blocks that have no path
%     from input to output.
% 
%     [A,B,C,D]=LINMOD('SYS',X,U,PARA,XPERT,UPERT) allows the perturbation
%     levels for all of the elements of X and U to be set. Any or all of  PARA, 
%     XPERT, UPERT may be empty matrices in which case these parameters will be
%     assumed to be undefined and the default option will be used.
% 
%     See also LINMOD, LINMOD2, DLINMOD, TRIM.

% Copyright 1999-2003 The MathWorks, Inc.

% make sure model is supported
supportMsg = linmodsupported(fcn);
if ~isempty(supportMsg)
    error(supportMsg);
end

% Disable acceleration and force inline parameters
want = struct('SimulationMode','normal','RTWInlineParameters','on');
[have, preloaded] = local_push_context(fcn, want);

% Pre-compile the model
feval(fcn, [], [], [], 'lincompile');

% Run the algorithm as a subroutine so we can trap errors and <CTRL-C>
lasterr('')
errmsg='';
eval('[A,B,C,D]=linmod_alg(fcn,varargin{:});','errmsg=lasterr;')

% Release the compiled model
feval(fcn, [], [], [], 'term');
local_pop_context(fcn, have, preloaded);

% Issue an error if one occured during the trim.
if ~isempty(errmsg),
  error(errmsg);
end

% end linmod

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D]=linmod_alg(fcn,x,u,para,xpert,upert)

% ---------------Options--------------------
sizes = feval(fcn, [], [], [], 'sizes');
sizes=[sizes(:); zeros(6-length(sizes),1)];
nxz=sizes(1)+sizes(2); nu=sizes(4); ny=sizes(3);
nx=sizes(1);

if nargin<2, x=[]; end
if nargin<3, u=[]; end
if nargin<4, para=[]; end
if nargin<5, xpert=[]; end
if nargin<6, upert=[]; end

if isempty(u), u=zeros(nu,1); end
if isempty(x), x=zeros(nxz,1); end
if isempty(para) , para=[0;0;0]; end
if para(1)==0, para(1)=1e-5; end
if isempty(upert), upert=para(1)+1e-3*para(1)*abs(u); end
if isempty(xpert), xpert=para(1)+1e-3*para(1)*abs(x); end
if length(para)>1, t=para(2); else t=0; end
if length(para)<3, para(3)=0; end
if length(x)<nxz
  warning('Extra states are being set to zero.')
  x=[x(:); zeros(nxz-length(x),1)];
end

if nxz > nx
  warning('Ignoring discrete states (use dlinmod for proper handling).');
end

A=zeros(nx,nx); B=zeros(nx,nu); C=zeros(ny,nx); D=zeros(ny,nu);

% Initialization
oldx=x; oldu=u;
y = feval(fcn, t, x ,u, 'outputs');
dx = feval(fcn, t, x, u, 'derivs');
oldy=y; olddx=dx;

% A and C matrices
for i=1:nx;
  x(i)=x(i)+xpert(i);
  y = feval(fcn, t, x ,u, 'outputs');
  dx = feval(fcn, t, x, u, 'derivs');
  A(:,i)=(dx-olddx)./xpert(i);
  if ny > 0
    C(:,i)=(y-oldy)./xpert(i);
  end
  x=oldx;
end

% B and D matrices
for i=1:nu
  u(i)=u(i)+upert(i);
  y = feval(fcn, t, x ,u, 'outputs');
  dx = feval(fcn, t, x, u, 'derivs');
  if ~isempty(B),
    B(:,i)=(dx-olddx)./upert(i);
  end
  if ny > 0
    D(:,i)=(y-oldy)./upert(i);
  end
  u=oldu;
end

% para(3) is set to 1 to remove extra states from blocks that are not in the
% input/output path. This removes a class of uncontrollable and unobservable
% states but does not remove states caused by pole/zero cancellation.
if para(3) == 1 
   [A,B,C] = minlin(A,B,C);
end

% Return transfer function model
if nargout == 2
  disp('Returning transfer function model')
  % Eval it in case it's not on the path
  [A, B] = feval('ss2tf',A,B,C,D,1);
end

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

set_param(model, 'Dirty', old.Dirty); %% should be the last set_param

if preloaded == 0
  close_system(model,0);
end

