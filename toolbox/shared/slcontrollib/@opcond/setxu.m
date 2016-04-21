%SETXU Set states and inputs in operating points.
%
%   OP_NEW=SETXU(OP_POINT,X,U) sets the states and inputs in the operating 
%   point, OP_POINT, with the values in X and U. A new operating point 
%   containing these values, OP_NEW, is returned. The variable X can be a 
%   vector or a structure with the same format as those returned from a 
%   Simulink simulation. The variable U can be a vector. Both X and U can 
%   be extracted from another operating point object with the GETXU function.
% 
%   See also OPCOND/GETXU, OPERPOINT.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:22 $
