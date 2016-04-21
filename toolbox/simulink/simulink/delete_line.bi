function [varargout] = delete_line(varargin)
%DELETE_LINE Delete a line from a Simulink system.
%   DELETE_LINE('SYS','OPORT','IPORT') deletes the line extending from the
%   specified block output port 'OPORT' to the specified block input port
%   'IPORT'.  'OPORT' and 'IPORT' are strings consisting of a block name and
%   a port identifier in the form 'block/port'.  Most block ports are
%   identified by numbering the ports from top to bottom or from left to
%   right, such as 'Gain/1' or 'Sum/2'.  Enable, Trigger, State or Ifaction
%   ports are identified by name, such as 'subsystem_name/Enable', 
%   'Integrator/State' or 'subsystem_name/Ifaction'.
%   
%   DELETE_LINE('SYSTEM',[X Y]) deletes one of the lines in the system that
%   contains the specified point (X,Y), if any such line exists.
%   
%   Example:
%   
%       delete_line('mymodel','Sum/1','Mux/2')
%   
%   removes the line from the mymodel system connecting the Sum block to the
%   second input of the Mux block.
%   
%   See also ADD_LINE.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.16.2.2 $
%   Built-in function.

if nargout == 0
  builtin('delete_line', varargin{:});
else
  [varargout{1:nargout}] = builtin('delete_line', varargin{:});
end
