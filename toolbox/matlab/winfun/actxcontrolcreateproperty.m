function varargout = actxcontrolcreateproperty(varargin)
%ACTXCONTROLCREATEPROPERTY actxcontrolselect help dialog.
%
%  See also ACTXCONTROLSELECT, ACTXSERVER.

% Copyright 1984-2004 The MathWorks, Inc.
% $Revision: 1.0

% Last Modified by GUIDE v2.5 02-Jul-2003 11:30:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @actxcontrolcreateproperty_OpeningFcn, ...
                   'gui_OutputFcn',  @actxcontrolcreateproperty_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before actxcontrolcreateproperty is made visible.
function actxcontrolcreateproperty_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

if nargin>3 && ishandle(varargin{1}) && strcmpi(get(varargin{1},'Type'), 'Figure') ...
    && isfield(guidata(varargin{1}),'Preview')

    handles.output = handles.figure1;
    handles.MainFigure = varargin{1};
    data = guidata(handles.MainFigure);
    handles.ProgID = get(data.ProgIDLabel,'String');
    handles.Parent = data.Parent;
    handles.Position = data.Position;
    handles.Preview = data.Preview;
    handles.EventCallback = data.EventCallback;
    
    %create uitrable for events & callbacks
    handles.EventTable = uitable(handles.figure1);
    mode = javax.swing.ListSelectionModel.MULTIPLE_INTERVAL_SELECTION;
    handles.EventTable.Table.setSelectionMode(mode);
    scroll = handles.EventTable.TableScrollPane;
    scroll.setVerticalScrollBarPolicy(scroll.VERTICAL_SCROLLBAR_AS_NEEDED);
    scroll.setHorizontalScrollBarPolicy(scroll.HORIZONTAL_SCROLLBAR_AS_NEEDED);
    oldunit = get(handles.EventListbox,'Units');
    set(handles.EventListbox,'Units','Pixels');
    pos= get(handles.EventListbox,'pos');
    handles.EventTable.setPosition(pos);
    set(handles.EventListbox,'Units',oldunit);
        
    % Update handles structure
    guidata(hObject, handles);

    % center this dialog around the main figure
    pos = get(handles.MainFigure, 'Position');
    mypos = get(hObject, 'Position');
    mypos(1) = pos(1) + (pos(3) - mypos(3))/2;
    mypos(2) = pos(2) + (pos(4) - mypos(4))/2;
    set(hObject, 'Position', mypos);
    
    % This is a modal dialog
    set(handles.figure1, 'HandleVisibility','off');
    set(handles.figure1, 'WindowStyle','modal');

    Local_InitializeControls(handles);
    

    % UIWAIT makes actxcontrolcreateproperty wait for user response (see UIRESUME)
    uiwait(handles.figure1);
else
    handles.output = [];
    % Update handles structure
    guidata(hObject, handles);
end

function Local_InitializeControls(handles)

[fighandles, fignames] = Local_FindFigure;
handles.Figures = fighandles;
if (ishandle(handles.Preview))
    if isempty(handles.EventCallback)
        objevents =events(handles.Preview);
        eventnames= {};
        callbacks = {};
        if ~isempty(objevents)
            eventnames = fieldnames(objevents);
            callbacks = cell(length(eventnames),1);
            for i=1:length(eventnames)
                callbacks{i} = '';
            end
        end
        set(handles.EventListbox,'Value',1);
        set(handles.EventListbox,'ListboxTop',1);
        handles.EventCallback = cell(length(eventnames),2);
        for i=1:length(eventnames)
            handles.EventCallback{i,1} = eventnames{i};
            handles.EventCallback{i,2} = '';
        end
    end
end

set(handles.ProgIDLabel,'String', handles.ProgID);
set(handles.ParentPopup,'String', fignames);
pindex = find(ismember(fighandles, handles.Parent));
if (isempty(pindex))
    set(handles.ParentPopup,'Value', 1);
    handles.Parent = fighandles(1);
else
    set(handles.ParentPopup,'Value', pindex(end));
end

max = 2000;
set(handles.XSlider,'Max', max, 'Min',0,'Value',max/2, 'SliderStep',[2/max, 2/max]);
setappdata(handles.XSlider,'Attachee', handles.XEdit);
setappdata(handles.XSlider,'OldValue', get(handles.XSlider,'Value'));
set(handles.YSlider,'Max', max, 'Min',0,'Value',max/2,'SliderStep',[2/max,2/max]);
setappdata(handles.YSlider,'Attachee', handles.YEdit);
setappdata(handles.YSlider,'OldValue', get(handles.YSlider,'Value'));
set(handles.WidthSlider,'Max', max, 'Min',0,'Value',max/2, 'SliderStep',[2/max,2/max]);
setappdata(handles.WidthSlider,'Attachee', handles.WidthEdit);
setappdata(handles.WidthSlider,'OldValue', get(handles.WidthSlider,'Value'));
set(handles.HeightSlider,'Max', max, 'Min',0,'Value',max/2, 'SliderStep',[2/max,2/max]);
setappdata(handles.HeightSlider,'Attachee', handles.HeightEdit);
setappdata(handles.HeightSlider,'OldValue', get(handles.HeightSlider,'Value'));

guidata(handles.figure1, handles);

Local_UpdatePosition(handles, 1);

Local_PopulateEventList(handles);

function Local_UpdateCallbackFromTable(handles)

table = handles.EventTable;
data = table.Data;
for i=1:length(data)
    handles.EventCallback{i,2} = data(i,2);
end
guidata(handles.figure1,handles);

function Local_UpdatePosition(handles, ispush)

if ispush
    set(handles.XEdit,'String', num2str(handles.Position(1)));
    set(handles.YEdit,'String', num2str(handles.Position(2)));
    set(handles.WidthEdit,'String', num2str(handles.Position(3)));
    set(handles.HeightEdit,'String', num2str(handles.Position(4)));
else
    handles.Position(1)= str2num(get(handles.XEdit,'String'));
    handles.Position(2)= str2num(get(handles.YEdit,'String'));
    handles.Position(3)= str2num(get(handles.WidthEdit,'String'));
    handles.Position(4)= str2num(get(handles.HeightEdit,'String'));
    guidata(handles.figure1, handles);
end

function Local_VerifyPosition(hObject)

needpush = 0;
try
    num = str2num(get(hObject,'String'));
    needpush = isempty(num);
    if ~needpush
        setappdata(hObject,'OldValue',num);
    end
catch
    needpush = 1;
end

Local_UpdatePosition(guidata(hObject), needpush);

function Local_UpdateSpinner(hObject)

try
    attachee = getappdata(hObject, 'Attachee');
    num = str2num(get(attachee,'String'));
    oldvalue = getappdata(hObject, 'OldValue');
    value = get(hObject,'value');
    if (value > oldvalue)
        set(attachee,'String', num +1);
    elseif (value < oldvalue)
        set(attachee,'String', num -1);
    end
    setappdata(hObject,'OldValue', value);
catch
end



function [fighandles, fignames] = Local_FindFigure

figs = findobj(get(0,'Children'),'type','Figure');

cf='Current Figure (gcf)';
if (~isempty(figs))
    tags = Local_FigureTitle(figs);
    fighandles = [gcf; figs(:)];
    fignames = {cf, tags{:}};    
else
    fighandles = -1;
    fignames = {cf};    
end

function titles = Local_FigureTitle(figs)

titles={};
for i=1:length(figs)
    fig = figs(i);
    title = get(fig,'Name');
    sep='';
    if ~isempty(title)
        sep=':';
    end
    if strcmp('on', get(fig,'NumberTitle'))
        title = ['Figure ', num2str(fig),sep, title];
    end
    titles{end+1} = title;
end

function Local_PopulateEventList(handles)

title = {'Event Name', 'Callback M-File'};
data = handles.EventCallback;
if isempty(handles.EventCallback)
    data = {'',''};    
end

handles.EventTable.setData(data);
handles.EventTable.setColumnNames(title);
handles.EventTable.Table.setColumnEditable(title{1}, 0);
if isempty(handles.EventCallback)
    handles.EventTable.Table.setColumnEditable(title{2}, 0);
else
    handles.EventTable.Table.setColumnEditable(title{2}, 1);
end


pos = handles.EventTable.getPosition;
handles.EventTable.setColumnWidth(pos(3)/2-10);

% --- Outputs from this function are returned to the command line.
function varargout = actxcontrolcreateproperty_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
output =  {};
delete(handles.figure1);
varargout = output;

% --- Executes on button press in OKButton.
function OKButton_Callback(hObject, eventdata, handles)
% hObject    handle to OKButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Local_UpdateCallbackFromTable(handles);
handles = guidata(handles.figure1);

data = guidata(handles.MainFigure);
data.Parent = handles.Parent;
data.Position = handles.Position;
data.EventCallback = handles.EventCallback;
guidata(handles.MainFigure, data);

uiresume(handles.figure1);






% --- Executes on button press in CancelButton.
function CancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to CancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];
guidata(handles.figure1, handles);
uiresume(handles.figure1);


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.output = [];
guidata(handles.figure1, handles);
if isequal(get(handles.figure1, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(handles.figure1);
else
    % The GUI is no longer waiting, just close it
    delete(handles.figure1);
end


% --- Executes during object creation, after setting all properties.
function ParentPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ParentPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in ParentPopup.
function ParentPopup_Callback(hObject, eventdata, handles)
% hObject    handle to ParentPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns ParentPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ParentPopup
handles.Parent = handles.Figures(get(hObject,'value'));
guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function EventListbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in EventListbox.
function EventListbox_Callback(hObject, eventdata, handles)
% hObject    handle to EventListbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns EventListbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EventListbox


% --- Executes during object creation, after setting all properties.
function XEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end

function XEdit_Callback(hObject, eventdata, handles)
% hObject    handle to XEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of XEdit as text
%        str2double(get(hObject,'String')) returns contents of XEdit as a
%        double

Local_VerifyPosition(hObject);

% --- Executes during object creation, after setting all properties.
function YLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function YLabel_Callback(hObject, eventdata, handles)
% hObject    handle to YLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YLabel as text
%        str2double(get(hObject,'String')) returns contents of YLabel as a double

% --- Executes during object creation, after setting all properties.
function WidthEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function WidthEdit_Callback(hObject, eventdata, handles)
% hObject    handle to WidthEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of WidthEdit as text
%        str2double(get(hObject,'String')) returns contents of WidthEdit as a double
Local_VerifyPosition(hObject);

% --- Executes during object creation, after setting all properties.
function HeightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function HeightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to HeightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of HeightEdit as text
%        str2double(get(hObject,'String')) returns contents of HeightEdit as a double
Local_VerifyPosition(hObject);

% --- Executes during object creation, after setting all properties.
function Yedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Yedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



% --- Executes during object creation, after setting all properties.
function YEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function YEdit_Callback(hObject, eventdata, handles)
% hObject    handle to YEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of YEdit as text
%        str2double(get(hObject,'String')) returns contents of YEdit as a double
Local_VerifyPosition(hObject);


% --- Executes on button press in BrowseButton.
function BrowseryButton_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cb = get(handles.CallbackEdit,'String');
cb = fliplr(deblank(fliplr(deblank(cb))));
selection = get(handles.EventListbox,'Value');    

for i=1:length(selection)
    handles.EventCallback{selection(i),2} = cb;
end

Local_PopulateEventList(handles);


% --- Executes on button press in BrowseButton.
function BrowseButton_Callback(hObject, eventdata, handles)
% hObject    handle to BrowseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

Local_UpdateCallbackFromTable(handles);

handles = guidata(handles.figure1);
[filename, pathname] = uigetfile('*.m', 'Pick a Callback M-File');
if ~isequal(filename,0) &&  ~isequal(pathname,0)
    [p,n,e]=fileparts(filename);
    selection = handles.EventTable.Table.getSelectedRows;
    if ~isempty(selection)
        for i=1:length(selection)
            handles.EventCallback{selection(i)+1,2} = n;
        end
        guidata(handles.figure1, handles);
        Local_PopulateEventList(handles);
    end
end
 


% --- Executes on slider movement.
function XSlider_Callback(hObject, eventdata, handles)
% hObject    handle to XSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Local_UpdateSpinner(hObject);

% --- Executes during object creation, after setting all properties.
function XSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to XSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function YSlider_Callback(hObject, eventdata, handles)
% hObject    handle to YSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Local_UpdateSpinner(hObject);

% --- Executes during object creation, after setting all properties.
function YSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to YSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function WidthSlider_Callback(hObject, eventdata, handles)
% hObject    handle to WidthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Local_UpdateSpinner(hObject);

% --- Executes during object creation, after setting all properties.
function WidthSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to WidthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on slider movement.
function HeightSlider_Callback(hObject, eventdata, handles)
% hObject    handle to HeightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Local_UpdateSpinner(hObject);

% --- Executes during object creation, after setting all properties.
function HeightSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to HeightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor',[.9 .9 .9]);
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


