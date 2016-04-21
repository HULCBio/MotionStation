%SET_PARAM Set Simulink system and block parameters.
%   SET_PARAM('OBJ','PARAMETER1',VALUE1,'PARAMETER2',VALUE2,...), where
%   'OBJ' is a system or block path name, sets the specified parameters to
%   the specified values.  Case is ignored for parameter names.  Value
%   strings are case sensitive.  Any parameters that correspond to dialog
%   box entries have string values.
%   
%   Examples:
%   
%       set_param('vdp','Solver','ode15s','StopTime','3000')
%   
%   sets the Solver and StopTime parameters of the vdp system.
%   
%       set_param('vdp/Mu','Gain','1000')
%   
%   sets the Gain of block Mu in the vdp system to 1000 (stiff).
%   
%       set_param('vdp/Fcn','Position',[50 100 110 120])
%   
%   sets the Position of block Fcn in the vdp system.
%   
%       set_param('mymodel/Zero-Pole','Zeros','[2 4]','Poles','[1 2 3]')
%   
%   sets the Zeros and Poles parameters of the Zero-Pole block in system
%   mymodel.
%   
%       set_param('mymodel/Compute','OpenFcn','my_open_fcn')
%   
%   sets the OpenFcn callback parameter of block Compute in system mymodel.
%   The function 'my_open_fcn' will execute when the user double-clicks on
%   the Compute block.
%   
%   See also GET_PARAM, FIND_SYSTEM.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.15 $
%   Built-in function.

