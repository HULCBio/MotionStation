%ADD_PARAM Add a parameter to a Simulink system.
%   ADD_PARAM('SYS','PARAMETER1','VALUE1','PARAMETER2','VALUE2',...), where
%   'SYS' is a system, adds the specified parameters to the system and
%   initializes them to the specified values.  Case is ignored for
%   parameter names.  Value strings are case sensitive.  The value
%   of the parameter must be a string.  Once the parameter is
%   added to a system, set_param and get_param can be used on the
%   new parameters as if they were standard Simulink parameters.  
%   
%   Examples:
%   
%       add_param('vdp','Param1','Value1','Param2','Value2')
%   
%   adds the parameters Param1 and Param2 with values 'Value1' and
%   'Value2' to the vdp system.
%   
%   See also DELETE_PARAM, GET_PARAM, and SET_PARAM

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.6 $
%   Built-in function.

