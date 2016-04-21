function doc_func_handle1
%% Use Save As in the File menu to create 
% an editable version of this M-file
%
% Example for function handle hg callbacks
% without panels and using subfunctions instead of 
% nested functions. Handles are passed as arguments
% to the callbacks

% Copyright 2002-2004 The MathWorks, Inc.
%
% Define GUI layout
h_figure = figure('Units','characters',...
    'Position',[72 38 120 35],...
    'Color',get(0,'DefaultUicontrolBackgroundColor'),...
    'HandleVisibility','callback');
h_axes = axes('Units','characters',...
    'Position',[10 4.5 72 26],...
    'Parent',h_figure);
h_listbox_label = uicontrol(h_figure,'Style','text','Units','characters',...
    'Position',[88 29 24 2],...
    'String','Select 2 Workspace Variables');
h_listbox = uicontrol(h_figure,'Style','listbox','Units','characters',...
    'Position',[88 18.5 24 10],...
    'BackgroundColor','white',...
    'Max',10,'Min',1,...
    'Callback',@listbox_callback);
h_popup_label = uicontrol(h_figure,'Style','text','Units','characters',...
    'Position',[88 13 24 2],...
    'String','Plot Type');
h_popup = uicontrol(h_figure,'Style','popupmenu','Units','characters',...
    'Position',[88 12 24 2],...
    'BackgroundColor','white',...
    'String',{'Plot','Bar','Stem'});
h_hold_toggle = uicontrol(h_figure,'Style','toggle','Units','characters',...
    'Position',[88 8 24 2],...
    'String','Hold State',...
    'Callback',{@hold_toggle_callback,h_axes});
h_plot_button = uicontrol(h_figure,'Style','pushbutton','Units','characters',...
    'Position',[88 3.5 24 2],...
    'String','Create Plot',...
    'Callback',{@plot_button_callback,h_listbox,h_popup,h_axes});

% Initialize list box
listbox_callback(h_listbox,[])
hold_toggle_callback(h_hold_toggle,[],h_axes)

% ------------ Callback Functions ---------------

function listbox_callback(obj,eventdata)
% -----------------------------------------------
% create some dummy vars for demo purposes
evalin('base','test_var_x = 0:pi/24:2*pi;')
evalin('base','test_var_y = cos(0:pi/24:2*pi);')
% -----------------------------------------------
% Load workspace vars into listbox
vars = evalin('base','who');
set(obj,'String',vars)

% Callback for hold state toggle button
function hold_toggle_callback(obj,eventdata,h_axes)
button_state = get(obj,'Value');
if button_state == get(obj,'Max')
    % toggle button is pressed
    set(h_axes,'NextPlot','add')
    set(obj,'String','Hold On')
elseif button_state == get(obj,'Min')
    % toggle button is not pressed
    set(h_axes,'NextPlot','replace')
    set(obj,'String','Hold Off')
end

% Callback for plot button
function plot_button_callback(obj,eventdata,h_listbox,h_popup,h_axes)
% Get workspace variables
vars = get(h_listbox,'String');
var_index = get(h_listbox,'Value');
if length(var_index) ~= 2
        errordlg('You must select two variables',...
            'Incorrect Selection','modal')
        return
end
% Get data from base workspace
x = evalin('base',vars{var_index(1)});
y = evalin('base',vars{var_index(2)});
% Get plotting command
selected_cmd = get(h_popup,'Value');
% Make the GUI axes current and create plot
axes(h_axes)
switch selected_cmd
case 1 % user selected plot
    plot(x,y)
    %evalin('base',['plot(' vars{var_index(1)} ',' vars{var_index(2)} ')'])
case 2 % user selected bar
    bar(x,y)
    %evalin('base',['bar(' vars{var_index(1)} ',' vars{var_index(2)} ')'])
case 3 % user selected stem
    stem(x,y)
    %evalin('base',['stem(' vars{var_index(1)} ',' vars{var_index(2)} ')'])  
end
