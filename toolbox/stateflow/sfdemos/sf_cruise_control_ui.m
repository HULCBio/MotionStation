function varargout = sf_cruise_control_ui(varargin)
% CRUISE2_UI Application M-file for cruise2_ui.fig
%    FIG = sf_cruise_control_ui launch cruise2_ui GUI.
%    sf_cruise_control_ui('callback_name', ...) invoke the named callback.

% Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.2.1 $  $Date: 2004/04/15 00:52:59 $

% Last Modified by GUIDE v2.0 15-Jun-2001 11:13:17

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);

    imData = imread('sf_cruise_normal.bmp');
    image('Parent',handles.axes1,'Cdata',imData);
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.


% --------------------------------------------------------------------
function varargout = window_bd(h, eventdata, handles, varargin)
h
% pushbutton3 => inc
% pushbutton4 => dec
switch(get_param(h,'Tag'))
case 'pushbutton3'
    varargout = inc_bd(h, eventdata, handles, varargin{:});
case 'pushbutton4'
    varargout = dec_bd(h, eventdata, handles, varargin{:});
end

% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
% Set
try,
    blockH = get_param('sf_cruise_control/hg/set','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

switch(get_param(blockH,'Value'))
case '0'
    set_param(blockH,'Value','1');
case '1'
    set_param(blockH,'Value','0');
end


% --------------------------------------------------------------------
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
% Resume
try
    blockH = get_param('sf_cruise_control/hg/resume','Handle');
catch
    blockH = [];
end
if isempty(blockH)
    return;
end

switch(get_param(blockH,'Value'))
case '0'
    set_param(blockH,'Value','1');
case '1'
    set_param(blockH,'Value','0');
end




% --------------------------------------------------------------------
function varargout = inc_bd(h, eventdata, handles, varargin)
try
    blockH = get_param('sf_cruise_control/hg/inc','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

set_param(blockH,'Value','1');

% --------------------------------------------------------------------
function varargout = inc_bu(h, eventdata, handles, varargin)
try
    blockH = get_param('sf_cruise_control/hg/inc','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

set_param(blockH,'Value','0');



% --------------------------------------------------------------------
function varargout = dec_bd(h, eventdata, handles, varargin)
try
    blockH = get_param('sf_cruise_control/hg/dec','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

set_param(blockH,'Value','1');


% --------------------------------------------------------------------
function varargout = dec_bu(h, eventdata, handles, varargin)
try,
    blockH = get_param('sf_cruise_control/hg/dec','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

set_param(blockH,'Value','0');



% --------------------------------------------------------------------
function varargout = slider1_Callback(h, eventdata, handles, varargin)
% accelerator
try,
    blockH = get_param('sf_cruise_control/hg/accl_pedal','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

val = get(h,'Value');
set_param(blockH,'Value',num2str(val));

% --------------------------------------------------------------------
function varargout = slider2_Callback(h, eventdata, handles, varargin)
% brake
try,
    blockH = get_param('sf_cruise_control/hg/brake','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

val = get(h,'Value');
set_param(blockH,'Value',num2str(val));

% --------------------------------------------------------------------
function varargout = radiobutton1_Callback(h, eventdata, handles, varargin)
% Power
try,
    blockH = get_param('sf_cruise_control/hg/pwr','Handle');
catch
    blockH = [];
end

if isempty(blockH)
    return;
end

if (get(h,'Value')==1),
    set_param(blockH,'Value','1');
else
    set_param(blockH,'Value','0');
end

