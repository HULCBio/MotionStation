function io = linio(block,portnumber,varargin);
% LINIO Construct linearization I/O settings for Simulink model
%
%   IO=LINIO('blockname',PORTNUM) creates a linearization I/O object for 
%   the signal that originates from the outport with port number, PORTNUM, 
%   of the block, 'blockname', in a Simulink model. The default I/O type 
%   is 'in', and the default OpenLoop property is 'off'. Use io with the 
%   function LINEARIZE to create linearized models. 
%
%   IO=LINIO('blockname',PORTNUM,TYPE) creates a linearization I/O object 
%   has the type given by TYPE. A list of available types is given below. 
%   The default OpenLoop property is 'off'. 
%   
%   IO=LINIO('blockname',PORTNUM,TYPE,OPENLOOP) creates a linearization 
%   I/O object where the open loop status is given by OPENLOOP.  The 
%   openloop property is set to 'off' when the I/O is not an open loop 
%   point and is set to 'on' when the I/O is an open loop point. 
%
%   Available linearization I/O types are 
%       'in', linearization input point 
%       'out', linearization output point 
%       'inout', linearization input then output point 
%       'outin', linearization output then input point 
%       'none', no linearization input/output point 
%
%   To upload the settings in the I/O object to the Simulink model, use 
%   the SETLINIO function.
%
%   See also GETLINIO, SETLINIO.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:35:12 $
    
% Construct the linearization object
io = LinearizationObjects.LinearizationIO; 

% Work through the various input combinations
if (nargin < 2 || nargin > 4)
    error('slcontrol:InvalidNumberInputsLINIO', ['The command linio must'...
            'have between 2 and 4 inputs.']);
elseif nargin == 2;
    set(io,'Block',block,'PortNumber',portnumber)
elseif nargin == 3
    set(io,'Block',block,'PortNumber',portnumber,'Type',varargin{1})
elseif nargin == 4
    set(io,'Block',block,'PortNumber',portnumber,'Type',varargin{1},...
                'OpenLoop',varargin{2})
end
