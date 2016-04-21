function [sys, x0, str, ts] = rlspps(t,x,u,flag,name,order,char_poly,dt)
%RLSPPS S-function which performs pole placement.
%   This M-file is designed to be used in a Simulink S-function block.
%   It computes the gains for a filter placed in the feed forward path
%   of a control system such that the closed loop has the desired
%   characteristic polynomial.  The gains are returned as a single
%   vector with P as the first half, and L as the second half.
%   
%   The input arguments are
%   sys_name:   the name of the block diagram system
%   blk_name:   the name of the discrete controller in the block diagram
%   order:      the order of the model
%   ic:         the initial condition for the model parameters
%   char_poly:  the desired characteristic polynomial
%   dt:         how often to sample points (secs)
%
%   See also SFUNTMPL.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.20 $
%   Rick Spada 6-17-92

switch flag,

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0,
    [sys,x0,str,ts]=mdlInitializeSizes(order,dt);

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%

  case 2,
    sys=mdlUpdate(t,x,u,name,order,char_poly);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3,
    sys=mdlOutputs(t,x,u);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9,
    sys=mdlTerminate(t,x,u);

  %%%%%%%%%%%
  % 'reset' %
  %%%%%%%%%%%
  case 'reset'
    LocalResetController(name);
    
  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

%end rlspps.m

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes(order,dt)
% return sizes of parameters and initial conditions

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = order*2;   % 2*order discrete states (num and den)
sizes.NumOutputs     = order*2;;  % 2*order outputs (num and den)
sizes.NumInputs      = order*2;   % 2*order inputs (num and den)
sizes.DirFeedthrough = 0;         % no direct feedthrough
sizes.NumSampleTimes = 1;  % 1 sample time

sys = simsizes(sizes);
%
% initialize the initial conditions and sample times
%
x0 = zeros(order*2,1);
ts = [dt, 0];
% str is always an empty matrix
%
str = [];

% end mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,name,order,char_poly)

  num = [0,u(1:order)'];
  den = [1,u(order+1:2*order)'];
  [l,p] = rlsppd(num,den,char_poly);
  if ~isempty(l) & ~isempty(p)
    sys = [l,p];
    num=['[' sprintf('%.16g ',p) ']'];
    den=['[' sprintf('%.16g ',l) ']'];
    dirty = get_param(bdroot,'Dirty');
    set_param(name,'Numerator',num,'Denominator',den);
    set_param(bdroot,'Dirty',dirty);
  end

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

  sys = x;
  sys = sys(:);

% end mdlOutputs

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate

%
%=============================================================================
% LocalResetController
% Resets the controller block with safe initial values
%=============================================================================
%
function LocalResetController(name)

mdl = bdroot(name);
dirty = get_param(mdl, 'Dirty');
set_param(name, 'Numerator', '[0.5 0.5]', 'Denominator', '[1 -1]');
set_param(mdl, 'Dirty',dirty);

%
%=============================================================================
% rlsppd
% Local function
%=============================================================================
%
function [l,p] = rlsppd(b_num,a_den,char_poly)
%RLSPPD Discrete pole placement (difference operator formulation)
%
%   Computes the controller polynomials given the discrete time
%   system defined by the polynomials A and B, and the desired poles
%   of the closed loop defined by Am.
%
%   The control law is defined by:
%        -1    -1       -1    -1      -1       -1    -1     -1
%   ( L(z  )A(z  ) + B(z  )P(z  ) )y(z  ) = B(z  )P(z  )uc(z  )
%
%       -1    -1        -1     -1
%   Am(z  )y(z  ) = Bm(z  )uc(z  )
%
%   where:
%
%       B :     plant numerator polynomial
%       A :     plant denominator polynomial
%       P :     controller numerator polynomial
%       L :     controller denominator polynomial
%
%   The solution for L and P given Am is defined by:
%         -1
%   [l p] = Me  * Am
%
%   where
%
%        | a0             b0             |
%        | a1             b1             |
%        | .              .              |
%        | .              .              |
%        | .              .              |
%   Me = | an             bn             |
%        |     an             bn         |
%        |         an             bn     |
%        |            an              bn |
%
%   See also pp 146-148, "Adaptive Filtering, Prediction, and Control",
%   G. C. Goodwin & K. S. Sin.
%

n = length(a_den) - 1;
Me = zeros(2 * n);
for i = 1:n
  Me(i:i+n,i) = a_den';
  Me(i:i+n,i+n) = b_num';
end

if rcond (Me) > eps
  lp = Me \ char_poly';
  l = lp(1:n)';
  p = lp(n+1:2*n)';
else
  disp('The eliminant matrix is singular.');
  l = [];
  p = [];
end


