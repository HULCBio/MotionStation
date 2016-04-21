function doc_func_handle2
    %% Use Save As in the File menu to create 
    % an editable version of this M-file 
    %
    % Example for function handle hg callbacks
    % without panels
    %

% Copyright 2004 The MathWorks, Inc.

% Create some dummy vars for demo purposes
        evalin('base','test_var_x = 0:pi/24:2*pi;')
        evalin('base','test_var_y = cos(0:pi/24:2*pi);')

% ------------ Callback Functions ---------------

    function listbox_callback(src,eventdata)
        % Load workspace vars into listbox
        vars = evalin('base','who');
        set(src,'String',vars)
    end % listbox_callback

    % Callback for hold state toggle button
    function hold_toggle_callback(src,eventdata)
        button_state = get(src,'Value');
        if button_state == get(src,'Max')
            % toggle button is depressed
            set(h_axes,'NextPlot','add')
            set(src,'String','Hold On')
        elseif button_state == get(src,'Min')
            % toggle button is not depressed
            set(h_axes,'NextPlot','replace')
            set(src,'String','Hold Off')
        end
    end % hold_toggle_callback

    % Callback for plot button
    function plot_button_callback(src,eventdata)
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
        case 2 % user selected bar
            bar(x,y)
        case 3 % user selected stem
            stem(x,y)
        end
    end % plot_button_callback


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
        'Callback',@hold_toggle_callback);
    h_plot_button = uicontrol(h_figure,'Style','pushbutton','Units','characters',...
        'Position',[88 3.5 24 2],...
        'String','Create Plot',...
        'Callback',@plot_button_callback);

    % Initialize list box
    listbox_callback(h_listbox,[])
    hold_toggle_callback(h_hold_toggle)


end % doc_func_handle2
