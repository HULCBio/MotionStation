function [A,B,C,D]=dlinmodv5(fcn,varargin)
%DLINMODV5 linearization for discrete-time and hybrid systems
%
%   DLINMODV5 is the DLINMOD algorithm which was shipped with MATLAB 5.x.
%   It uses numerical perturbations to obtain the linear model.  The new
%   DLINMOD can obtain exact linearizations which are independent of
%   perturbation size.
%
%   [A,B,C,D]=DLINMODV5('SYS',TS) obtains a discrete-time state-space linear
%   model (with sample time TS) of the system of mixed continuous and 
%   discrete systems described in the S-function 'SYS' when the state
%   variables and inputs are set to zero.
% 
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA) allows a vector of parameters
%   to be set.  PARA(1) sets the perturbation level for obtaining the
%   linear model (default PARA(1)=1e-5) according to:
%      XPERT= PARA(1)+1e-3*PARA(1)*ABS(X)
%      UPERT= PARA(1)+1e-3*PARA(1)*ABS(U)
%   where XPERT and UPERT are the perturbation levels for the system's states
%   and inputs. For systems that are functions of time PARA(2) may be set with
%   the value of t at which the linear model is to be obtained (default PARA(2)=0).
%   Set PARA(3)=1 to remove extra states associated with blocks that have no path
%   from input to output.
% 
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA,XPERT,UPERT) allows the perturbation
%   levels for all of the elements of X and U to be set. Any or all of  PARA, 
%   XPERT, UPERT may be empty matrices in which case these parameters will be
%   assumed to be undefined and the default option will be used.
%
%   To see more help, enter TYPE DLINMODV5.
%   See also DLINMOD, LINMOD, LINMOD2, TRIM.

%
%   [A,B,C,D]=DLINMODV5('SYS',TS,X,U,PARA,XPERT,UPERT) allows the
%   perturbation levels for all of the elements of X and U to be set.
%   The default is otherwise  XPERT=PARA(1)+1e-3*PARA(1)*abs(X),
%   UPERT=PARA(1)+1e-3*PARA(1)*abs(U).
%
%   Any or all of  PARA, XPERT, UPERT may be empty matrices in which case
%   these parameters will be assumed to be undefined and the default
%   option will be used.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.2 $
%   Andrew Grace 11-12-90.

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
eval('[A,B,C,D]=dlinmod_alg(fcn,varargin{:});','errmsg=lasterr;');

% Release the compiled model
feval(fcn, [], [], [], 'term');
local_pop_context(fcn, have, preloaded);

% Issue an error if one occured during the trim.
if ~isempty(errmsg),
  error(errmsg);
end

% end dlinmod

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [A,B,C,D]=dlinmod_alg(fcn,st,x,u,para,xpert,upert)

% ---------------Options--------------------
[sizes x0 x_str ts tsx]=feval(fcn,[],[],[],'sizes');
sizes=[sizes(:); zeros(6-length(sizes),1)];
nxz=sizes(1)+sizes(2); nu=sizes(4); ny=sizes(3);
nx=sizes(1);

if ~isempty(tsx), tsx = tsx(:,1); end

if nargin<2, st = []; end
if nargin<3, x=[]; end
if nargin<4, u=[]; end
if nargin<5, para=[]; end
if nargin<6, xpert=[]; end
if nargin<7, upert=[]; end

if isempty(u), u=zeros(nu,1); end
if isempty(x), x=zeros(nxz,1); end
if isempty(para) , para=[0;0;0]; end
if para(1)==0, para(1)=1e-5; end
if isempty(upert), upert=para(1)+1e-3*para(1)*abs(u); end
if isempty(xpert), xpert=para(1)+1e-3*para(1)*abs(x); end
if length(para)>1, t=para(2); else t=0; end
if length(para)<3, para(3)=0; end

ts = [0 0; ts];

% Eliminate sample times that are the same with different offsets.
tsnew = unique(ts(:,1));
[nts] = length(tsnew);

if isempty(st)
  st = local_vlcm(tsnew(find(tsnew>0)));
  if isempty(st)
    warning('No sample time found in the model.  Defaulting to 1.');
    st = 1;
  end
end

% Initialize A and B, prepare for loop over sample times
A = zeros(nxz,nxz); B = zeros(nxz, nu); Acd = A; Bcd = B;
Aeye = eye(nxz,nxz);

% Starting with smallest sample time, convert those models to the
% next smallest sample time.  Each pass through the loop removes a
% sample time from the list (and from the model).  Stop when the
% system is single-rate.

for m = 1:nts
  % Choose the next sample time
  if length(tsnew) > 1
    stnext = min(st, tsnew(2));
  else
    stnext = st;
  end
  storig = tsnew(1);
  index = find(tsx == storig);		% states with Ts = storig
  nindex = find(tsx ~= storig);		% states with another Ts
  oldA = Acd;
  oldB = Bcd;

  %% Begin linearization algorithm (formerly LINALL)

  %% This code block performs the simple linearization based on perturbations
  %% about x0, u0.  A sample time is specified not as the time at which the
  %% linearization occurs, but rather as a "granularity" or sampling time over
  %% which we are interested.  Thus, states with long sampling times will not
  %% change due to perturbations/linearization around shorter sampling times.

  %% Here t really is the time at which linearization occurs, same as linmod.
  %% storig is the sampling time for the current linearization

  feval(fcn, storig, [], [], 'all');	% update blocks with Ts <= storig
  Acd=zeros(nxz,nxz); Bcd=zeros(nxz,nu); C=zeros(ny,nxz); D=zeros(ny,nu);

  % Compute unperturbed values (must occur each time through the loop,
  % after the call to 'all' with a given sampling time.  Otherwise, 
  % linearizations about nonzero initial states might get munged.
  oldx=x; oldu=u;
  y  = feval(fcn, t, x, u, 'outputs');
  dx = feval(fcn, t, x, u, 'derivs');
  ds = feval(fcn, t, x, u, 'update');
  dall = [dx; ds];
  oldy=y; olddall=dall;

  % A and C matrices
  for i=1:nxz;
    x(i)=x(i)+xpert(i);
    y = feval(fcn, t, x, u, 'outputs');
    dx = feval(fcn, t, x, u, 'derivs');
    ds = feval(fcn, t, x, u, 'update');
    dall = [dx; ds];
    Acd(:,i)=(dall-olddall)./xpert(i);
    if ny > 0
      C(:,i)=(y-oldy)./xpert(i);
    end
    x=oldx;
  end
  
  % B and D matrices
  for i=1:nu
    u(i)=u(i)+upert(i);
    y = feval(fcn, t, x, u, 'outputs');
    dx = feval(fcn, t, x, u, 'derivs');
    ds = feval(fcn, t, x, u, 'update');
    dall = [dx; ds];
    if ~isempty(Bcd),
      Bcd(:,i)=(dall-olddall)./upert(i);
    end
    if ny > 0
      D(:,i)=(y-oldy)./upert(i);
    end
    u=oldu;
  end
  
  %% End linearization algorithm (formerly LINALL)

  % Update A, B matrices with any new information
  % Any differences between this linearization (Acd) and the last (oldA)
  % get premultiplied by the ZOH B-matrix associated with those states..
  % see the update method for Aeye below.

  A = A + Aeye * (Acd - oldA);
  B = B + Aeye * (Bcd - oldB);
  n = length(index);

  % Convert states at Ts=storig to sample time stnext
  % States with Ts > storig are treated as inputs (since they are constant
  % over one period at storig..) so the relevant columns of A are treated
  % as columns of B instead, via premultiplication by bd2.

  if n & storig ~= stnext
    if storig ~=  0
      if stnext ~= 0
        [ad2,bd2] = d2d(A(index, index),eye(n,n),storig, stnext);
      else
        [ad2,bd2] = d2ci(A(index, index),eye(n,n),storig);
      end
    else
      [ad2,bd2] = c2d(A(index, index),eye(n,n),stnext);
    end
    A(index, index)  =  ad2;

    if length(nindex)
      A(index, nindex) = bd2*A(index,nindex);
    end
    if nu
      B(index,:) = bd2*B(index,:);
    end

    % Any further updates to these states also get hit with bd2
    Aeye(index,index) = bd2*Aeye(index,index);
    tsx(index) =  stnext(ones(length(index),1));
  end

  % Remove this sample time (storig) from the list
  tsnew(1) = [];
end

if norm(imag(A), 'inf') < sqrt(eps), A = real(A); end
if norm(imag(B), 'inf') < sqrt(eps), B = real(B); end

% para(3) is set to 1 to remove extra states from blocks that are not in the
% input/output path. This removes a class of uncontrollable and unobservable
% states but does not remove states caused by pole/zero cancellation.
if para(3) == 1
   [A,B,C] = minlin(A,B,C);
end

% Return transfer function model
if nargout == 2
  disp('Returning transfer function model')
  % Eval it in case its not on the path
  [A, B] = feval('ss2tf',A,B,C,D,1);
end

%---

function M = local_vlcm(x)
% VLCM  find least common multiple of several sample times

% Protect against a few edge cases
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

set_param(model, 'Dirty', old.Dirty); %% should be the last set_param

if preloaded == 0
  close_system(model,0);
end
