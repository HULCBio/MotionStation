function varargout = f14ex(varargin)
% F14EX Application M-file for f14ex.fig
%   F14EX, by itself, creates a new F14EX or raises the existing
%   singleton*.
%
%   H = F14EX returns the handle to a new F14EX or the handle to
%   the existing singleton*.
%
%   F14EX('CALLBACK',hObject,eventData,handles,...) calls the local
%   function named CALLBACK in F14EX.M with the given input arguments.
%
%   F14EX('Property','Value',...) creates a new F14EX or raises the
%   existing singleton*.  Starting from the left, property value pairs are
%   applied to the GUI before f14ex_OpeningFunction gets called.  An
%   unrecognized property name or invalid value makes property application
%   stop.  All inputs are passed to f14ex_OpeningFcn via varargin.
%
%   *See GUI Options - GUI allows only one instance to run (singleton).
%
%   F14EX('Callback') and F14EX('Callback', hObject, ...) call the
%   named function in F14EX.M with the given input arguments.
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help f14ex

% Last Modified by GUIDE v2.5 08-Apr-2002 16:36:39

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',          mfilename, ...
                   'gui_Singleton',     gui_Singleton, ...
                   'gui_OpeningFcn',    @f14ex_OpeningFcn, ...
                   'gui_OutputFcn',     @f14ex_OutputFcn, ...
                   'gui_LayoutFcn',     [], ...
                   'gui_Callback',      []);
if nargin & isstr(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    varargout{1:nargout} = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before f14ex is made visible.
function f14ex_OpeningFcn(hObject, eventdata, handles)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to f14ex (see VARARGIN)

fig = handles.F14ControllerEditor;

% ------------------------------------------------------------
% If f14.mdl is not open: open it and bring GUI to front
% Also set model parameters to match GUI settings
% ------------------------------------------------------------

model_open(handles)

% Choose default command line output for f14ex
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes f14ex wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = f14ex_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% ------------------------------------------------------------
% Ensure that the Simulink model is open
% ------------------------------------------------------------
function model_open(handles)
% Make sure the diagram is still open
if  isempty(find_system('Name','f14')),
	open_system('f14'); open_system('f14/Controller')
	set_param('f14/Controller/Gain','Position',[275 14 340 56])
	figure(handles.F14ControllerEditor)
	% Put  values of Kf and Ki from the GUI into the Block dialogs
	set_param('f14/Controller/Gain','Gain',...
		get(handles.KfCurrentValue,'String'))
	set_param('f14/Controller/Proportional plus integral compensator',...
		'Numerator',...
		get(handles.KiCurrentValue,'String'))
end

% ------------------------------------------------------------
% Callback for Proportional(Kf) slider
% ------------------------------------------------------------
function varargout = KfValueSlider_Callback(h, eventdata, handles)
% hObject    handle to KfValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Ensure model is open
model_open(handles)

% Get the new value for the Kf Gain from the slider
NewVal = get(h,'Value');

% Set the value of the KfCurrentValue to the new value set by slider
set(handles.KfCurrentValue,'String',NewVal)

% Set the Gain parameter of the Kf Gain Block to the new value
set_param('f14/Controller/Gain','Gain',num2str(NewVal))

% ------------------------------------------------------------
% Callback for Kf Current value text box
% ------------------------------------------------------------
function varargout = KfCurrentValue_Callback(h, eventdata, handles)
% hObject    handle to KfCurrentValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% Ensure model is open
model_open(handles)

% Get the new value for the Kf Gain
NewStrVal = get(h,'String');
NewVal = str2double(NewStrVal);

% Check that the entered value falls within the allowable range
if  isempty(NewVal) | (NewVal< -5) | (NewVal>0),
	% Revert to last value, as indicated by KfValueSlider
	OldVal = get(handles.KfValueSlider,'Value');
	set(h,'String',OldVal)
	
else
	% Set the value of the KfValueSlider to the new value
	set(handles.KfValueSlider,'Value',NewVal)
	
	% Set the Gain parameter of the Kf Gain Block to the new value
	set_param('f14/Controller/Gain','Gain',NewStrVal)
end

% ------------------------------------------------------------
% Callback for Integral(Ki) slider
% ------------------------------------------------------------
function varargout = KiValueSlider_Callback(h, eventdata, handles)
% hObject    handle to KiValueSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% Ensure model is open
model_open(handles)

% Get the new value for the Ki Gain from the slider
NewVal = get(h,'Value');

% Set the value of the KiCurrentValue to the new value set by slider
set(handles.KiCurrentValue,'String',NewVal)

% Set the Numerator parameter of the Ki Tranfer function Block to the new value
set_param('f14/Controller/Proportional plus integral compensator','Numerator',num2str(NewVal))

% ------------------------------------------------------------
% Callback for Ki Current value text box
% ------------------------------------------------------------
function varargout = KiCurrentValue_Callback(h, eventdata, handles)
% hObject    handle to KiCurrentValue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

% Ensure model is open
model_open(handles)

% Get the new value for the Ki Gain
NewStrVal = get(h,'String');
NewVal = str2num(NewStrVal);

% Check that the entered value falls within the allowable range
if  isempty(NewVal) | (NewVal< -5) | (NewVal>0),
	% Revert to last value, as indicated by KiValueSlider
	OldVal = get(handles.KiValueSlider,'Value');
	set(h,'String',OldVal)
	
else, % Use new Ki value
	% Set the value of the KiValueSlider to the new value
	set(handles.KiValueSlider,'Value',NewVal)
	
	% Set the Numerator parameter of the Ki Tranfer function Block to the new value
	set_param('f14/Controller/Proportional plus integral compensator','Numerator',NewStrVal)
end

% ------------------------------------------------------------
% Callback for the Simulate and store results button
% ------------------------------------------------------------
function varargout = SimulateButton_Callback(h, eventdata, handles)
% hObject    handle to SimulateButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[timeVector,stateVector,outputVector] = sim('f14');

% Retrieve old results data structure
if isfield(handles,'ResultsData') & ~isempty(handles.ResultsData)
	ResultsData = handles.ResultsData;
	% Determine the maximum run number currently used.
	maxNum = ResultsData(length(ResultsData)).RunNumber;
	ResultNum = maxNum+1;
else, % Set up the results data structure
	ResultsData = struct('RunName',[],'RunNumber',[],...
		'KiValue',[],'KfValue',[],'timeVector',[],'outputVector',[]);
	ResultNum = 1;
end

if isequal(ResultNum,1),
	%--Enable the Plot and Remove buttons
	set([handles.RemoveButton,handles.PlotButton],'Enable','on')
end

% Get Ki and Kf values to store with the data and put in the results list.
Ki = get(handles.KiValueSlider,'Value');
Kf = get(handles.KfValueSlider,'Value');

ResultsData(ResultNum).RunName = ['Run',num2str(ResultNum)];
ResultsData(ResultNum).RunNumber = ResultNum;
ResultsData(ResultNum).KiValue = Ki;
ResultsData(ResultNum).KfValue = Kf;
ResultsData(ResultNum).timeVector = timeVector;
ResultsData(ResultNum).outputVector = outputVector;

% Build the new results list string for the listbox
ResultsStr = get(handles.ResultsList,'String');
if isequal(ResultNum,1)
	ResultsStr = {['Run1          ',num2str(Kf),'   ',num2str(Ki)]};
else
	ResultsStr = [ResultsStr; {['Run',num2str(ResultNum),'          ',num2str(Kf),'   ',num2str(Ki)]}];
end
set(handles.ResultsList,'String',ResultsStr);

% Store the new ResultsData
handles.ResultsData = ResultsData;
guidata(h,handles)

% ------------------------------------------------------------
% Callback for the Remove push button
% ------------------------------------------------------------
function varargout = RemoveButton_Callback(h, eventdata, handles)
% hObject    handle to RemoveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Callback of the uicontrol handles.RemoveButton.
currentVal = get(handles.ResultsList,'Value');
resultsStr = get(handles.ResultsList,'String');
numResults = size(resultsStr,1);

% Remove the data and list entry for the selected value
resultsStr(currentVal) =[];
handles.ResultsData(currentVal)=[];

% If there are no other entries, disable the Remove and Plot button
% and change the list sting to <empty>
if isequal(numResults,length(currentVal)),
	resultsStr = {'<empty>'};
	currentVal = 1;
	set([handles.RemoveButton,handles.PlotButton],'Enable','off')	
end

% Ensure that list box Value is valid, then reset Value and String
currentVal = min(currentVal,size(resultsStr,1));
set(handles.ResultsList,'Value',currentVal,'String',resultsStr)

% Store the new ResultsData
guidata(h,handles)

% ------------------------------------------------------------
% Callback for the Plot push button
% ------------------------------------------------------------
function varargout = PlotButton_Callback(h, eventdata, handles)
% hObject    handle to PlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Callback of the uicontrol handles.PlotButton.
currentVal = get(handles.ResultsList,'Value');

% Get data to plot
legendStr = cell(length(currentVal),1);
plotColor = {'b','g','r','c','m','y','k'};
for ctVal = 1:length(currentVal);
	PlotData{(ctVal*3)-2} = handles.ResultsData(currentVal(ctVal)).timeVector;
	PlotData{(ctVal*3)-1} = handles.ResultsData(currentVal(ctVal)).outputVector;	
	numColor = ctVal - 7*( floor((ctVal-1)/7) );
	PlotData{ctVal*3} = plotColor{numColor};
	legendStr{ctVal} = [handles.ResultsData(currentVal(ctVal)).RunName,';  Kf=', ...
			num2str(handles.ResultsData(currentVal(ctVal)).KfValue),';  Ki=', ...
			num2str(handles.ResultsData(currentVal(ctVal)).KiValue)];
end

% If necessary, create the plot figure and store in handles structure
if ~isfield(handles,'PlotFigure') | ~ishandle(handles.PlotFigure),
	handles.PlotFigure = figure('Name','F14 Simulation Output','Visible','off',...
		'NumberTitle','off','HandleVisibility','off','IntegerHandle','off');
	handles.PlotAxes = axes('Parent',handles.PlotFigure);
	guidata(h,handles)
end 

% Plot data
pHandles = plot(PlotData{:},'Parent',handles.PlotAxes);

% Add a legend, and bring figure to the front
legend(pHandles(1:2:end),legendStr{:})
% Make the figure visible and bring it forward
figure(handles.PlotFigure)

% ------------------------------------------------------------
% Callback for the Help push button
% ------------------------------------------------------------
function varargout = HelpButton_Callback(h, eventdata, handles)
% hObject    handle to HelpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Callback of the uicontrol handles.HelpButton.
HelpPath = which('f14ex_help.html');
web(HelpPath); 

% ------------------------------------------------------------
% Callback for the Close push button
% ------------------------------------------------------------
function varargout = CloseButton_Callback(h, eventdata, handles)
% hObject    handle to CloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Close the GUI and any plot window that is open
if isfield(handles,'PlotFigure') & ishandle(handles.PlotFigure),
	close(handles.PlotFigure);
end
close(handles.F14ControllerEditor); 

% --- Executes during object creation, after setting all properties.
function ResultsList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResultsList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background, change
%       'usewhitebg' to 0 to use default.  See ISPC and COMPUTER.
usewhitebg = 1;
if usewhitebg
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end




