function [k,s,e] = lqry(a,b,c,d,q,r,varargin)
%LQRY  Linear-quadratic regulator design with output weighting.
%
%   [K,S,E] = LQRY(SYS,Q,R,N) calculates the optimal gain matrix K 
%   such that: 
%
%     * if SYS is a continuous-time system, the state-feedback law  
%       u = -Kx  minimizes the cost function
%
%             J = Integral {y'Qy + u'Ru + 2*y'Nu} dt
%                                       .
%       subject to the system dynamics  x = Ax + Bu,  y = Cx + Du
%
%     * if SYS is a discrete-time system, u[n] = -Kx[n] minimizes 
%
%             J = Sum {y'Qy + u'Ru + 2*y'Nu}
%
%       subject to  x[n+1] = Ax[n] + Bu[n],   y[n] = Cx[n] + Du[n].
%                
%   The matrix N is set to zero when omitted.  Also returned are the
%   the solution S of the associated algebraic Riccati equation and 
%   the closed-loop eigenvalues E = EIG(A-B*K).
%
%   See also  LQR, LQGREG, CARE, DARE.

%Old help
%LQRY   Linear quadratic regulator design with output weighting
%   for continuous-time systems.
%
%   [K,S,E] = LQRY(A,B,C,D,Q,R) calculates the optimal feedback
%   gain matrix K such that the feedback law  u = -Kx  minimizes
%   the cost function:
%
%      J = Integral {y'Qy + u'Ru} dt
%
%   subject to the constraint equation: 
%      .
%      x = Ax + Bu,  y = Cx + Du
%                
%   Also returned is S, the steady-state solution to the associated 
%   algebraic Riccati equation and the closed loop eigenvalues
%   E = EIG(A-B*K).
%
%   The controller can be formed using REG.
%
%   See also: LQR, LQR2 and REG.

%   J.N. Little 7-11-88
%   Revised: 7-18-90 Clay M. Thompson, P. Gahinet 7-24-96
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:24:16 $

error(nargchk(6,7,nargin));

% Check dimensions
error(abcdchk(a,b,c,d));

% Call lti/lqry
[k,s,e] = lqry(ss(a,b,c,d),q,r,varargin{:});

% end lqry
