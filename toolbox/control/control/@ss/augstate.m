function sys = augstate(sys)
%AUGSTATE  Appends states to the outputs of a state-space model.
%
%   ASYS = AUGSTATE(SYS)  appends the states to the outputs of 
%   the state-space model SYS.  The resulting model is:
%      .                       .
%      x  = A x + B u   (or  E x = A x + B u for descriptor SS)
%
%     |y| = [C] x + [D] u
%     |x|   [I]     [0]
%
%   This command is useful to close the loop on a full-state
%   feedback gain  u = Kx.  After preparing the plant with
%   AUGSTATE,  you can use the FEEDBACK command to derive the 
%   closed-loop model.
%
%   See also FEEDBACK, SS, LTIMODELS.

%       Author(s): A. Potvin, 12-1-95
%       Copyright 1986-2002 The MathWorks, Inc. 
%       $Revision: 1.15 $  $Date: 2002/04/10 06:02:21 $

error(nargchk(1,1,nargin))
nx = size(sys,'order');
if length(nx)>1,
   error('Only applicable to model arrays with uniform number of states.') 
end

ny = size(sys.d,1);
nu = size(sys.d,2);
for k=1:prod(size(sys.a)),
   sys.c{k} = [sys.c{k} ; eye(nx)];
   sys.d(1:ny+nx,:,k) = [sys.d(:,:,k) ; zeros(nx,nu)];
end

% Update Output Names
sys.lti = augstate(sys.lti,sys.StateName);


