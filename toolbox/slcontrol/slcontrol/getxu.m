% GETXU Extract states and inputs from operating points
%
%   X = GETXU(OP_POINT) extracts a vector of state values, X, from the 
%   operating point object, OP_POINT. The ordering of states in X is the 
%   same as that used by Simulink. 
% 
%   [X,U] = GETXU(OP_POINT) extracts a vector of state values, X, and a 
%   vector of input values, U, from the operating point object, OP. The 
%   ordering of states in X, and inputs in U, is the same as that used 
%   by Simulink. 
% 
%   [X,U,XSTRUCT] = getxu(OP_POINT) extracts a vector of state values, X, 
%   a vector of input values, U, and a structure of state values, xstruct, 
%   from the operating point object, OP_POINT. The structure of state values, 
%   xstruct, has the same format as that returned from a Simulink simulation. 
%   The ordering of states in X and XSTRUCT, and inputs in U, is the same as 
%   that used by Simulink.
% 
%   See also SETXU.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:08:31 $
