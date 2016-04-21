%COPY  Create copy of operating point or operating point specification 
%
%   OP_POINT2=COPY(OP_POINT1) returns a copy of the operating point object
%   OP_POINT1. You can create OP_POINT1 with the function OPERPOINT.
%
%   OP_SPEC2=COPY(OP_SPEC1) returns a copy of the operating point
%   specification object OP_SPEC1. You can create OP_SPEC1 with the
%   function OPERSPEC. 
%
%   Note: The command OP_POINT2=OP_POINT1 does not create a copy of
%   OP_POINT1 but creates a pointer to OP_POINT1. In this case any changes
%   made to OP_POINT2 will also be made to OP_POINT1. 
%
%   Example:
%   Create an operating point object for the model, magball.
%     opp=operpoint('magball');
%   Create a copy of this object.
%     new_opp=copy(opp)
%
%   See Also OPERPOINT, OPERSPEC

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.4.1 $ $Date: 2004/04/19 01:31:18 $
