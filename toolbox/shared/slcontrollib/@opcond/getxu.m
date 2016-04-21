% GETXU Extract states and inputs from operating points
%
%   X = GETXU(OP_POINT) extracts a vector of state values, X, from the 
%   operating point object, OP_POINT. The ordering of states in X is the 
%   same as that used by Simulink. 
%
%   [X,U] = GETXU(OP_POINT) extracts a vector of state values, X, and a 
%   vector of input values, U, from the operating point object, OP. 
%   The ordering of states in X, and inputs in U, is the same as that used 
%   by Simulink. 
%
%   [X,U,XSTRUCT] = GETXU(OP_POINT) extracts a vector of state values, X, 
%   a vector of input values, U, and a structure of state values, XSTRUCT, 
%   from the operating point object, OP_POINT. The structure of state 
%   values, XSTRUCT, has the same format as that returned from a Simulink 
%   simulation. The ordering of states in X and XSTRUCT, and inputs in U, 
%   is the same as that used by Simulink.
%
%   See also OPERPOINT, OPERSPEC, OPCOND/SETXU.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:20 $
