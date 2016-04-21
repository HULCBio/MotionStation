function [boardnum,procnum] = boardprocsel(varargin)
% BOARDPROCSEL Board and Processor selection tool for Code Composer Studio(R).
%    [BN,PN] = BOARDPROCSEL launches a GUI window that lists all available
%    DSP boards and processors configured for Code Composer Studio(R). 
%    The return values are the selected board and processor number.
%    These numbers can be used to construct the CCSDSP object, for example:
%    CC = CCSDSP('boardnum',BN,'procnum',PN);
%
%    Note - if the window is canceled by the user, this routine
%    will return BN,PN = []
%    
%    See also CCSDSP, CCSBOARDINFO.

% BOARDPROCSEL('callback_name', ...) invoke the named callback.
% Last Modified by GUIDE v2.0 14-Nov-2000 17:05:19
% $Revision: 1.6.4.2 $ $Date: 2004/04/06 01:05:00 $
% Copyright 2001-2004 The MathWorks, Inc.

if nargin == 0  % LAUNCH GUI
    try
        ccopt = ccsboardinfo;
    catch
        error(generateccsmsgid('MethodNotUsed'),...
            sprintf('%s\n%s', lasterr, 'Failed to use ''ccsboardinfo'' to query Code Composer Studio(R)'));
    end
    nboards = length(ccopt);
    if nboards == 0,
        error('No boards configured by Code Composer Studio(R)');
    elseif nboards == 1,
        nprocs = length(ccopt(1).proc);
        if nprocs == 1,
            msg = { 'Code Composer Studio(R) has configured a single processsor',
                ['Board: '  ccopt(1).name ],
                ['Proc:  '  ccopt(1).proc(1).name ],
                ['Type:  '  ccopt(1).proc(1).type ],
                'This device will be used for the Code Composer Link'
            };
            
            uiwait(msgbox(msg,'Selecting Boardnum & Procnum','help','modal'));
            boardnum = ccopt(1).number;
            procnum = ccopt(1).proc(1).number;
            return;
        end
    end
    
    % OK open the dialog box
    fig = openfig(mfilename,'reuse');
    
    % Use system color scheme for figure:
    defbackc = get(0,'defaultUicontrolBackgroundColor');
    set(fig,'Color',defbackc);
    
    set(fig,'UserData',ccopt);
    
    % Generate a structure of handles to pass to callbacks, and store it. 
    handles = guihandles(fig);
    guidata(fig, handles);
    
    set(handles.frameboard,'backgroundcolor',defbackc);
    set(handles.frameproc,'backgroundcolor',defbackc);
    
    set(handles.boardnum,'backgroundcolor',defbackc);
    set(handles.procnum,'backgroundcolor',defbackc);
    set(handles.proctype,'backgroundcolor',defbackc);
    
    set(handles.textprocnum,'backgroundcolor',defbackc);
    set(handles.textboardnum,'backgroundcolor',defbackc);
    set(handles.textprocname,'backgroundcolor',defbackc);
    set(handles.textboardname,'backgroundcolor',defbackc);
    set(handles.textproctype,'backgroundcolor',defbackc);
    set(handles.texttitle,'backgroundcolor',defbackc);
    
    % Configure ListBoxes/Editboxes from ccopt structure
    % Create Board and Processor Cell Arrays
    
    for ib=1:nboards,
        bdi = ccopt(ib).number + 1;
        boardnames{bdi} = ccopt(ib).name;
        nprocs = length(ccopt(ib).proc);
        for ip = 1:nprocs,
            if ~strcmpi(ccopt(ib).proc(ip).type,'BYPASS')
                pci = ccopt(ib).proc(ip).number + 1;
                temp_proc{pci} = ccopt(ib).proc(ip).name;
                temp_type{pci} = ccopt(ib).proc(ip).type;
            end
        end
        procnames{bdi} = temp_proc;
        typenames{bdi} = temp_type;
        clear temp_proc;
        clear temp_type;
    end
    set(handles.boardname,'String',boardnames);
    set(handles.procname,'String',procnames{1});
    set(handles.proctype,'String',typenames{1}{1});
    
    set(handles.boardname,'Value',1);
    set(handles.procname,'Value',1);
    
    set(handles.procname,'UserData',procnames);
    set(handles.proctype,'UserData',typenames);
    
    % Wait for callbacks to run and window to be dismissed:
    
    uiwait(fig);
    try 
        % a Cancel will cause handle.procname/fig to be invalid
        pindex = get(handles.procname,'Value');
        bindex = get(handles.boardname,'Value');
        boardnum = bindex-1;
        procnum = pindex-1;
        delete(fig);
    catch
        boardnum = [];
        procnum = [];
    end
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    
    try
        feval(varargin{:}); % FEVAL switchyard
    catch
        error(lasterr);
    end
end


%----------------------------LOCAL FUNCTION------------------------------------
function setuicolor(handles)
% Set the backgroundcolor of the uicontrol to the system color




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
function boardname_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.popupmenu2.
bindex = get(h,'Value');
set(handles.boardnum,'String',num2str(bindex-1));

procnames = get(handles.procname,'UserData');
typenames = get(handles.proctype,'UserData');

set(handles.procname,'Value',1);
set(handles.procname,'String',procnames{bindex});
set(handles.proctype,'String',typenames{bindex}{1});

set(handles.procnum,'String','0');

% --------------------------------------------------------------------
function procname_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.edit1.
pindex = get(h,'Value');
bindex = get(handles.boardname,'Value');
set(handles.procnum,'String',num2str(pindex-1));

typenames = get(handles.proctype,'UserData');
set(handles.proctype,'String',typenames{bindex}{pindex});

% --------------------------------------------------------------------
function varargout = quitbutton_Callback(h, eventdata, handles, varargin)
% Stub for Callback of the uicontrol handles.quitbutton.
uiresume(gcbf);