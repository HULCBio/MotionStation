function [sys, x0] = animcpp1(t, x, u, flag, action)
%ANIMCPP1 Animation of CPP (cart & parallel poles) system.
%   This is animation of the cart & parallel poles (CPP) system, where a
%   Sugeno-type fuzzy controller is used to balance two poles of
%   different lengths, as well as move the cart to a target position
%   indicated by the green triangle. This system is different from the
%   ordinary CPP system in that one of the pole length is time varying;
%   which adds difficulty to the control task. In particular, when the
%   poles have the same length, it becomes an uncontrollable system.
%   Therefore this is a very sensitive system; you can easily make it
%   unstable by changing the pole length function.
%
%   If the target position is chosen as mouse-driven, you can click your
%   mouse inside the green triangle to move it to another position.
%   Also clicking "Show Trails" lets you have an idea of how the pole
%   length changes.
%
%   Animation S-function: animcpp1.m
%   SIMULINK file: slcpp1.m

%   Roger Jang, 3-31-94, 11-15-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.15.2.3 $  $Date: 2004/04/10 23:15:14 $

%   User data convention:
%   userdata = get(AnimCppFigH, 'userdata');
%   userdata(1, :) --> handles for standard SL gui control 
%   userdata(2, :) --> handles for additional gui control 
%   userdata(3, :) --> handles for animation objects

global AnimCppFigH AnimCppFigTitle AnimCppAxisH

if ~isempty(flag) & flag == 2,
    if any(get(0, 'children') == AnimCppFigH),
    if strcmp(get(AnimCppFigH, 'Name'), AnimCppFigTitle),
    theta1 = u(1); theta2 = u(2);
    pos = u(3); curr_force = u(4); curr_ref = u(5);
    tmp = get(AnimCppFigH, 'userdata');
    objectH = tmp(3, :);

    % During simulation disenable the Target Position pop-up menu
    kids = get(AnimCppFigH,'Children');
    PopUpMenuHndl = findobj(kids,'Tag','SourceSelect');
    set(PopUpMenuHndl,'enable','off');

    % ====== update cart
    cartH = objectH(1);
    cart = get(cartH, 'userdata');
    new_cart = cart + pos; 
    set(cartH, 'xdata', real(new_cart), 'ydata', imag(new_cart));
    cart_length = abs(real(cart(1)))*2;
    cart_height = abs(imag(cart(1)));
    % ====== update pole 1
    pole1H = objectH(2);
    %pole1 = get(pole1H, 'userdata');
    pole1 = 0.02*[-1 1 1 -1 -1] + j*(u(6)/2*[-1 -1 1 1 -1]+u(6)/2);
    new_pole1 = pole1*exp(-j*theta1) + pos - cart_length/4;
    set(pole1H, 'xdata', real(new_pole1), 'ydata', imag(new_pole1));
    % ====== update pole 2
    pole2H = objectH(3);
    pole2 = get(pole2H, 'userdata');
    %pole2 = 0.02*[-1 1 1 -1 -1] + j*(u(7)/2*[-1 -1 1 1 -1]+u(7)/2);
    new_pole2 = pole2*exp(-j*theta2) + pos + cart_length/4;
    set(pole2H, 'xdata', real(new_pole2), 'ydata', imag(new_pole2));
    % ====== update force arrow
    forceH = objectH(4);
    forceH = objectH(4);
    force = get(forceH, 'userdata');
    new_force = curr_force/4*force + pos - j*cart_height/2 ...
        - sign(curr_force)*cart_length/2;
    set(forceH, 'xdata', real(new_force), 'ydata', imag(new_force));
    % ====== update reference triangle if not dragging
    refH = objectH(5);
    ref = get(refH, 'userdata');
    new_ref = ref + curr_ref;
    set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
    % ====== update time 
    tmp = get(AnimCppFigH, 'userdata');
    timeH = tmp(1, 6);
    set(timeH, 'String', ['Time: ', sprintf('%.2f', t)]);
    end
    end
    % ====== return nothing
    sys = [];
    x0=[];
    drawnow;    % for invoking with rk45()
elseif ~isempty(flag) & flag == 9,   % When simulation stops ...
    % ====== change labels of standard UI controls
    if any(get(0, 'children') == AnimCppFigH),
    if strcmp(get(AnimCppFigH, 'Name'), AnimCppFigTitle),
    tmp = get(AnimCppFigH, 'userdata');
    set(tmp(1, 1), 'visible', 'on');    % start
    set(tmp(1, 2:5), 'visible', 'off');

    % At end of simulation re-enable the Target Position pop-up menu
    kids = get(AnimCppFigH,'Children');
    PopUpMenuHndl = findobj(kids,'Tag','SourceSelect');
    set(PopUpMenuHndl,'enable','on');

    end
    end
elseif ~isempty(flag) & flag == 0,
    % ====== find animation block & figure
    [winName] = bdroot(gcs);
    AnimCppFigTitle = [winName, ': Cart & Parallel Poles Animation'];
    [flag, AnimCppFigH] = figflag(AnimCppFigTitle);
    % ====== % No figure, initialize everything
    if ~flag,
        ui_row_n = 2;   % No. of UI rows
        % ###### default UI settings for SIMUINK ######
        AnimCppFigH = figure( ...
            'Name', AnimCppFigTitle, ...
            'NumberTitle', 'off', ...
            'DockControls', 'off');
        figPos = get(AnimCppFigH, 'position');
        % ====== proportion of UI frame and axes
        ui_area = 0.2;
        axis_area = 1-ui_area;
        % ====== animation area 
        axisPos = [0 figPos(4)*ui_area figPos(3) figPos(4)*axis_area];
        % weird thing: if you don't use normalized unit for
        % axes, patch for ground doesn't appear
        axisPos = axisPos./[figPos(3) figPos(4) figPos(3) figPos(4)];
        AnimCppAxisH = ...
            axes('unit', 'normal', 'pos', axisPos, 'visible', 'off');
        % ====== background frame
        coverPos = [0 0 figPos(3) figPos(4)*ui_area];
        [frameH, framePos] = uiarray(coverPos, 1, 1, 0);
        % ====== rows for UI controls
        spacing = 5;
        [H, Pos] = uiarray(framePos, ui_row_n, 1, spacing);
        % ====== split lower-most rows into 2 uneven regions
        delete(H(2));
        [tmpH, tmpPos] = uiarray(Pos(2,:), 1, 6, 0, spacing);
        % lower left frame
        delete(tmpH(2:4));
        lPos = tmpPos(1, :);
        lPos(3) = 4*lPos(3)+3*spacing;
        set(tmpH(1), 'pos', lPos);
        % lower right frame
        delete(tmpH(6));
        rPos = tmpPos(5, :);
        rPos(3) = 2*rPos(3)+spacing;
        set(tmpH(5), 'pos', rPos);
        % ====== lower-right UI's (same for all SL animation)
        cb1 = [mfilename '([], [], [], [], ''info'')'];
        cb2 = [mfilename '([], [], [], [], ''close'')'];
        [lrH, lrPos] = uiarray(rPos, 1, 2, spacing, spacing, ...
            str2mat('push', 'push'), ...
            str2mat(cb1, cb2), ...
            str2mat('Help', 'Close'));
        infoH = lrH(1);
        closeH = lrH(2);
        % ====== lower-left UI's (same for all SL animation)
        cb1 = '';
        cb2 = [mfilename '([], [], [], [], ''start_sl'')'];
        cb3 = '';
        cb4 = '';
        [llH, llPos] = uiarray(lPos, 1, 4, spacing, spacing, ...
            str2mat('text', 'push', 'text', 'text'), ...
            str2mat(cb1, cb2, cb3, cb4), ...
            str2mat('t = 0', 'Start Simulation ...','',''));
        timeH = llH(1);
        % ====== extend the width of start button
        delete(llH(3:4));
        startH = llH(2);
        startPos = llPos(2,:);
        startPos(3) = 3*startPos(3)+2*spacing;
        set(startH, 'pos', startPos);
        % ====== create stop and pause (under start)
        cb1 = [mfilename '([], [], [], [], ''stop_sl'')'];
        cb2 = [mfilename '([], [], [], [], ''pause_sl'')'];
        cb3 = '';
        [h, pos] = uiarray(startPos, 1, 3, 0,spacing,'push', ...
            str2mat(cb1, cb2, cb3), ...
            str2mat('Stop', 'Pause ...', ''));
        set(h, 'visible', 'off');
        stopH = h(1); pauseH = h(2);
        % ====== extend the width of pause button
        delete(h(3));
        pausePos = pos(2, :);
        pausePos(3) = 2*pausePos(3)+spacing;
        set(pauseH, 'pos', pausePos);
        % ===== create continue and step (under pause)
        cb1 = [mfilename '([], [], [], [], ''continue_sl'')'];
        cb2 = [mfilename '([], [], [], [], ''step_sl'')'];
        [h, pos] = uiarray(pausePos, 1, 2, 0, spacing, ...
            'push', ...
            str2mat(cb1, cb2), ...
            str2mat('Continue', 'Step'));
        set(h, 'visible', 'off');
        contH = h(1); stepH = h(2);
        %===== put UI handles into current figure's user data 
        tmp = [startH stopH pauseH contH stepH timeH -1 -1 -1 -1];
        set(AnimCppFigH, 'userdata', tmp);

        % ###### additional UI settings ######
        % ====== The upper UI controls (Specific to each animation)
        cb1 = [mfilename '([], [], [], [], ''show_trail'')'];
        cb2 = [mfilename '([], [], [], [], ''clear_trail'')'];
        cb3 = '';
        cb4 = [mfilename '([], [], [], [], ''target_pos'')'];

        string1 = 'Show Trails';
        string2 = 'Clear Trails';
        string3 = 'Target Position:';
        string4 = 'Sinusoid Wave|Square Wave|Saw Wave|Mouse-Driven';

        [upH, upPos] = uiarray(Pos(1,:), 1, 4, spacing, 2*spacing, ...
            str2mat('check', 'push', 'text', 'popup'), ...
            str2mat(cb1, cb2, cb3, cb4), ...
            str2mat(string1, string2, string3, string4));
        set(upH(3), 'HorizontalAlignment', 'right');
        signalH = upH(4);
        % Set the Tag of the pop-up menu so it can be found and disenabled during simulation
        set(signalH,'Tag','SourceSelect');
        dispmodeH = upH(1);
        % The value of signalH should match that of SL block
        [winName] = bdroot(gcs);
        signal_block = [winName, '/Target Position'];
        signal_value = get_param(signal_block, 'waveform');
        if strcmp(signal_value, 'sine'),
            set(signalH, 'value', 1);
        elseif strcmp(signal_value, 'square'),
            set(signalH, 'value', 2);
        elseif strcmp(signal_value, 'sawtooth'),
            set(signalH, 'value', 3);
        else
            error('Unknown signal generator!');
        end
        constant_block = [winName, '/Constant'];
        if str2double(get_param(constant_block, 'value')) < 0,
            set(signalH, 'value', 4);
        end
        % ====== Appending handles as the second row of userdata
        tmp = [signalH dispmodeH -1 -1 -1 -1 -1 -1 -1 -1];
        set(AnimCppFigH, 'userdata', [get(AnimCppFigH, 'userdata'); tmp]);

        % ###### animation objects ######
        % ====== cart
        cart_height = 0.2;
        cart_length = 0.4;
        cart = cart_length/2*[-1 1 1 -1 -1] + ...
            j*(cart_height/2*[-1 -1 1 1 -1]-cart_height/2+.005);
        cartH = patch(real(cart), imag(cart), 'm');
        set(cartH, 'erase', 'xor');
        set(cartH, 'userdata', cart);
        % ====== pole 1
        pole_length = 0.5;
        pole_radius = 0.02;
        pole1 = pole_radius*[-1 1 1 -1 -1] + ...
            j*(pole_length/2*[-1 -1 1 1 -1]+pole_length/2+.003);
        pole1H = patch(real(pole1), imag(pole1), 'r');
        set(pole1H, 'erase', 'xor', 'clipping', 'off');
        set(pole1H, 'userdata', pole1);
        % ====== pole 2
        pole_length = 1;
        pole_radius = 0.02;
        pole2 = pole_radius*[-1 1 1 -1 -1] + ...
            j*(pole_length/2*[-1 -1 1 1 -1]+pole_length/2);
        pole2H = patch(real(pole2), imag(pole2), 'y');
        set(pole2H, 'erase', 'xor', 'clipping', 'off');
        set(pole2H, 'userdata', pole2);
        % ====== force arrow
        force_x = [-1 0 nan -0.1 0 -0.1];
        force_y = [0 0 nan 0.1 0 -0.1];
        force = force_x + j*force_y;
        forceH = line(real(force), imag(force), ...
            'erase', 'xor', 'color', 'c', 'clip', 'off');
        set(forceH, 'userdata', force, ...
            'xdata', [0], 'ydata', [0]);
        % ====== reference triangle
        ref = cart_length/2*[-1 1 0 -1] + ...
            j*cart_height*([0 0 1 0] - 1.1);
        ref = ref - 2*j*cart_height;
        refH = line(real(ref), imag(ref));
        set(refH, 'color', 'g', 'linewidth', 2);
    %   refH = patch(real(ref), imag(ref), 'g');
        set(refH, 'erase', 'background');
        set(refH, 'userdata', ref);
        % ====== axis settings
        pos_range = [-2 2];
        set(AnimCppAxisH, 'clim', [1 64], ...
            'xlim', pos_range, ...
            'ylim', [-cart_height 1*1.2], ...
            'box', 'on');
        axis equal;
        set(AnimCppAxisH, 'visible', 'off');
        % ====== colormap settings for floor
        colormap(gray); %  To assign correct patch color
        patch([pos_range -pos_range], ...
            cart_height*[-2 -2 -1 -1], [10 10 55 55]);
        % ====== append the handles as third row of userdata
        tmp = [cartH pole1H pole2H forceH refH -1 -1 -1 -1 -1];
        set(AnimCppFigH, 'userdata', [get(AnimCppFigH, 'userdata'); tmp]);
        % ====== change to normalized units
        set(findobj(AnimCppFigH,'Units','pixels'), 'Units','normalized');
        % ====== move the reference triangle by mouse
        % action when button is first pushed down
        action1 = [mfilename '([], [], [], [], ''mouse_action'')'];
        % actions after the mouse is pushed down
        action2 = action1;
        % action when button is released
        action3 = action1;

        % temporary storage for the recall in the down_action
        set(AnimCppAxisH,'UserData',action2);

        % set action when the mouse is pushed down
        down_action=[ ...
            'set(AnimCppFigH,''WindowButtonMotionFcn'',get(AnimCppAxisH,''UserData''));' ...
            action1];
        set(AnimCppFigH,'WindowButtonDownFcn',down_action);

        % set action when the mouse is released
        up_action=[ ...
            'set(AnimCppFigH,''WindowButtonMotionFcn'','' '');', action3];
        set(AnimCppFigH,'WindowButtonUpFcn',up_action);


    end
    % ====== change labels of standard UI controls
    tmp = get(AnimCppFigH, 'userdata');
    set(tmp(1, 1), 'visible', 'off');
    set(tmp(1, 2:3), 'visible', 'on');
    closeHandle=findobj(AnimCppFigH, 'style', 'pushbutton', 'String', ' Close');
    set(closeHandle, 'Enable', 'off');
    sys = [0 0 0 6 0 0];
    x0=[];
    set(AnimCppFigH, 'HandleVisibility', 'on');
elseif nargin == 5, % for callbacks of GUI
    % ###### standard UI controls
    if strcmp(action, 'start_sl'),
        tmp = get(AnimCppFigH, 'userdata');
        set(tmp(1, 1), 'visible', 'off');
        set(tmp(1, 2:3), 'visible', 'on');
    closeHandle=findobj(AnimCppFigH, 'style', 'pushbutton', 'String', ' Close');
    set(closeHandle, 'Enable', 'off');
        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'start');
    elseif strcmp(action, 'stop_sl'),
        tmp = get(AnimCppFigH, 'userdata');
        set(tmp(1, 1), 'visible', 'on');
        set(tmp(1, 2:5), 'visible', 'off');
    closeHandle=findobj(AnimCppFigH, 'style', 'pushbutton', 'String', ' Close');
    set(closeHandle, 'Enable', 'on');
        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'stop');
    elseif strcmp(action, 'pause_sl'),
        tmp = get(AnimCppFigH, 'userdata');
        set(tmp(1, 3), 'visible', 'off');
        set(tmp(1, 4:5), 'visible', 'on');
        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'pause');
    elseif strcmp(action, 'step_sl'),
        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'step');
    elseif strcmp(action, 'continue_sl'),
        tmp = get(AnimCppFigH, 'userdata');
        set(tmp(1, 3), 'visible', 'on');
        set(tmp(1, 4:5), 'visible', 'off');
        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'continue');
    elseif strcmp(action, 'info'),
        helpwin(mfilename);
    %   title = get(AnimCppFigH, 'Name');
    %   content = [];
    %   fhelpfun(title, content);        
    elseif strcmp(action, 'close'),
%       [winName, sysName] = get_param;
%       set_param(winName, 'Simulation running', 'stop');
        delete(AnimCppFigH);

    % ###### additional UI controls
    elseif strcmp(action, 'target_pos'),
        [winName] = bdroot(gcs);
        signal_block = [winName, '/Target Position'];
        constant_block = [winName, '/Constant'];
        tmp = get(AnimCppFigH, 'userdata');
        signalH = tmp(2, 1);
        signal = get(signalH, 'value');
        if signal == 1, % sinusoid wave
            set_param(signal_block, 'wave', 'sine');
            set_param(constant_block, 'value', '1');
        elseif signal == 2, % square wave
            set_param(signal_block, 'wave', 'square');
            set_param(constant_block, 'value', '1');
        elseif signal == 3, % saw wave
            set_param(signal_block, 'wave', 'sawtooth');
            set_param(constant_block, 'value', '1');
        elseif signal == 4, % mouse-driven
            set_param(constant_block, 'value', '-1');
        else
            error('Unknown wave option!');
        end
    elseif strcmp(action, 'show_trail'),
        tmp = get(AnimCppFigH, 'userdata');
        dispmodeH = tmp(2, 2);
        objectH = tmp(3, 1:4);
        dispmode = get(dispmodeH, 'value');
        if dispmode == 0,   % xor
            set(objectH, 'erasemode', 'xor');
            set(AnimCppFigH, 'color', get(AnimCppFigH, 'color'));
        else
            set(objectH, 'erasemode', 'none');
        end
    elseif strcmp(action, 'clear_trail'),
        refresh(AnimCppFigH);
    elseif strcmp(action, 'mouse_action')
        [winName] = bdroot(gcs);
        if str2double(get_param([winName, '/Constant'], 'value')) < 0,
            curr_info = get(AnimCppAxisH, 'CurrentPoint');
            tmp = get(AnimCppFigH, 'UserData');
            refH = tmp(3, 5);

            desired_pos = curr_info(1,1);
            desired_pos = min(max(desired_pos, -1.5), 1.5);
            ref = get(refH, 'userdata');
            new_ref = ref + desired_pos;
            set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
            [windowname] = bdroot(gcs);
            set_param([windowname, '/Target Position',13,'(Mouse-Driven)'],...
                'value', num2str(desired_pos));
        end
    else
        fprintf('Unknown action string: %s.\n', action);
    end
end
