function [K,S,E] = lqr(sys,q,r,varargin)
%LQR  Linear-quadratic regulator design for state space systems.
%  
%     [K,S,E] = LQR(SYS,Q,R,N) calculates the optimal gain matrix K 
%     such that: 
%  
%       * For a continuous-time state-space model SYS, the state-feedback  
%         law u = -Kx  minimizes the cost function
%  
%               J = Integral {x'Qx + u'Ru + 2*x'Nu} dt
%                                         .
%         subject to the system dynamics  x = Ax + Bu
%  
%       * For a discrete-time state-space model SYS, u[n] = -Kx[n] minimizes 
%  
%               J = Sum {x'Qx + u'Ru + 2*x'Nu}
%  
%         subject to  x[n+1] = Ax[n] + Bu[n].
%                  
%     The matrix N is set to zero when omitted.  Also returned are the
%     the solution S of the associated algebraic Riccati equation and 
%     the closed-loop eigenvalues E = EIG(A-B*K).
%
%     [K,S,E] = LQR(A,B,Q,R,N) is an equivalent syntax for continuous-time
%     models where A, B specify the model dx/dt = Ax + Bu
%  
%     See also LQRY, LQGREG, DLQR, CARE, DARE.

%   Author(s): J.N. Little 4-21-85
%   Revised    P. Gahinet  7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2002/11/11 22:21:44 $

ni = nargin;
error(nargchk(3,4,ni))
if ~isa(sys,'ss'),
   error('First input must be a state-space model.')
elseif hasdelay(sys),
   if sys.Ts ~= 0 
      error('Not supported for systems with delays. Use delay2z to add delay to states');
   else
      error('Not supported for systems with delays.');
   end
elseif length(size(sys))>2
    error('Not supported for arrays of state-space models');
end

% Extract system data 
[a,b,c,d,e] = dssdata(sys);
Ts = sys.Ts;
if ni==4
    nn = varargin{1};
    if isempty(nn) | isequal(nn,0),
       nn = zeros(size(b));
    end
else
    nn = zeros(size(b));
end

% Check dimensions and symmetry
Nx = size(a,1);
Nu = size(b,2);
if Nx~=size(b,1),
   error('The A and B matrices must have the same number of rows.')
elseif any(size(q)~=Nx)
   error('The A and Q matrices must be the same size.')
elseif any(size(r)~=Nu),
   error('The R matrix must be square with as many columns as B.')
elseif ~isequal(size(nn),[Nx Nu]),
   error('The B and N matrices must be the same size.')
elseif ~isreal(q) || ~isreal(r) || ~isreal(nn)
   error('The weight matrices Q, R, N must be real valued.')
elseif norm(q'-q,1) > 100*eps*norm(q,1),
   warning('Q is not symmetric and has been replaced by (Q+Q'')/2).')
elseif norm(r'-r,1) > 100*eps*norm(r,1),
   warning('R is not symmetric and has been replaced by (R+R'')/2).')
end

% Enforce symmetry and check positivity
q = (q+q')/2;
r = (r+r')/2;
vr = eig(r);
vqnr = eig([q nn;nn' r]);
if min(vr)<=0,
   error('The R matrix must be positive definite.')
elseif min(vqnr)<-1e2*eps*max(0,max(vqnr)),
   warning('The matrix [Q N;N'' R] should be positive semi-definite.')
end

if Ts==0
   % Call CARE
   [S,E,K,report] = care(a,b,q,r,nn,e);
else 
   % Call DARE
   [S,E,K,report] = dare(a,b,q,r,nn,e);
end

% Handle failure
if report<0
   L1 = 'The plant model cannot be stabilized by feedback or the optimal design';
   L2 = 'problem is ill posed.';
   L3 = ' ';
   L4 = 'To remedy this problem, you may';
   L5 = '  * Make sure that all unstable poles of A are controllable through B';
   L6 = '    (use MINREAL to check)';
   L7 = '  * Modify the weights Q and R to make [Q N;N'' R] positive definite';
   L8 = '    (use EIG to check positivity)';
   error(sprintf('%s\n%s\n%s\n%s\n%s\n%s\n%s\n%s',L1,L2,L3,L4,L5,L6,L7,L8))
end

if ~isequal(e,eye(size(a))),
   S = e'*S*e;  
   S = (S+S')/2;
end
