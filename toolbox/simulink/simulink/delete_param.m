%DELETE_PARAM Deletes a parameter from a Simulink system.
%   DELETE_PARAM('SYS','PARAMETER1', 'PARAMETER2', ...), where
%   'SYS' is a system, deletes the listed parameters if these
%   parameters were added to the system using the ADD_PARAM command.
%   An error will occurr when trying to delete a Simulink parameter. 
%   
%   Examples:
%   
%       add_param('vdp','Param1','Value1','Param2','Value2')
%       delete_param('vdp','Param1')
%
%   adds the parameters Param1 and Param2 to the vdp system, and
%   then deletes Param1 from the system.
%   
%   See also ADD_PARAM, GET_PARAM, and SET_PARAM

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.5 $
%   Built-in function.