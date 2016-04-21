function [varargout] = add_line(varargin)
%ADD_LINE Add a line to a Simulink system.
%   ADD_LINE('SYS','OPORT','IPORT') adds a straight line to a system from
%   the specified block output port 'OPORT' to the specified block input
%   port 'IPORT'.  'OPORT' and 'IPORT' are strings consisting of a block
%   name and a port identifier in the form 'block/port'.  Most block ports
%   are identified by numbering the ports from top to bottom or from left to
%   right, such as 'Gain/1' or 'Sum/2'.  Enable, Trigger, State and Ifaction
%   ports are identified by name, such as 'subsystem_name/Enable',
%   'Integrator/State' or 'subsystem_name/Ifaction'.
%   
%   ADD_LINE('SYS',POINTS) adds a segmented line to a system.  Each row
%   of the POINTS array specifies the x and y coordinates of a point on a
%   line segment.  The origin is the top left corner of the window.  The
%   signal flows from the point defined in the first row to the point
%   defined in the last row.  If the start of the new line is close to the
%   output of an existing line or block, a connection is made.  Likewise, if
%   the end of the line is close to an existing input, a connection is made.
%   
%   ADD_LINE('SYS','OPORT','IPORT', 'AUTOROUTING','ON') works like
%   ADD_LINE('SYS','OPORT','IPORT') except it routes the line around
%   any intervening blocks.
%   default is 'off'
%   
%   Examples:
%   
%       add_line('mymodel','Sine Wave/1','Mux/1')
%   
%   adds a line to the mymodel system connecting the output of the Sine Wave
%   block to the first input of the Mux block.
%   
%   add_line('mymodel','Sine Wave/1','Mux/1','autorouting','on')
%   
%   adds a line to the mymodel system connecting the output of the Sine Wave
%   block to the first input of the Mux block and routes the line around any
%   intervening blocks
%
%   add_line('mymodel',[20 55; 40 10; 60 60])
%   
%   adds a line to the mymodel system extending from (20,55) to (40,10) to
%   (60,60).
%
%   
%   See also DELETE_LINE.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.17.2.2 $
%   Built-in function.
 

if nargout == 0
  builtin('add_line', varargin{:});
else
  [varargout{1:nargout}] = builtin('add_line', varargin{:});
end
