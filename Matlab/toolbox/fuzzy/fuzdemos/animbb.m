function [sys, x0] = animbb(t, x, u, flag, action)
%ANIMBB Animation of BB (ball & beam) system.
%   Animation of the ball & beam (BB) system, where a Sugeno-type fuzzy
%   controller is used to move the ball to a target position indicated by
%   the red triangle.
%
%   If the target position is chosen as mouse-driven, you can click your
%   mouse inside the red triangle to move it to another position.
%
%   Animation S-function: animbb.m
%   SIMULINK file: slbb.m 

%   Roger Jang, 8-18-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.16.2.3 $  $Date: 2004/04/10 23:15:11 $

%   User data convention:
%   userdata = get(AnimBbFigH, 'userdata');
%   userdata(1, :) --> handles for standard SL gui control 
%   userdata(2, :) --> handles for additional gui control 
%   userdata(3, :) --> handles for animation objects

global AnimBbFigH AnimBbFigTitle AnimBbAxisH

if ~isempty(flag) & flag == 2,
    if any(get(0, 'children') == AnimBbFigH),
    if strcmp(get(AnimBbFigH, 'Name'), AnimBbFigTitle),
    pos = u(1); theta = u(2); curr_force = u(3); curr_ref = u(4);
    newuserdata= get(AnimBbFigH, 'userdata');
    tmp = newuserdata.tmp;
    winName=newuserdata.winName;
    objectH = tmp(3, :);

    % During simulation disenable the Target Position pop-up menu
    kids = get(AnimBbFigH,'Children');
    PopUpMenuHndl = findobj(kids,'Tag','SourceSelect');
    set(PopUpMenuHndl,'enable','off');

    % ====== update ball
    ballH = objectH(1);
    ball = get(ballH, 'userdata');
    new_ball = (ball + pos)*exp(j*theta);
    set(ballH, 'xdata', real(new_ball), 'ydata', imag(new_ball));
    % ====== update beam
    beamH = objectH(2);
    beam = get(beamH, 'userdata');
    new_beam = beam*exp(j*theta);
    set(beamH, 'xdata', real(new_beam), 'ydata', imag(new_beam));
    % ====== update force arrow
    tip1 = new_beam(1, :); % left lower corner
    tip2 = new_beam(2, :); % right lower corner
    forceH = objectH(3);
    force = get(forceH, 'userdata');
    if curr_force > 0,
        new_force = 2*curr_force*force + tip2;
    else
        new_force = abs(2*curr_force)*force + tip1;
    end
    set(forceH, 'xdata', real(new_force), 'ydata', imag(new_force));
    % ====== update reference triangle if not dragging
    refH = objectH(4);
    ref = get(refH, 'userdata');
    new_ref = (ref + curr_ref)*exp(j*theta);
    set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
    % ====== update time 
    newuserdata= get(AnimBbFigH, 'userdata');
    tmp = newuserdata.tmp;
    winName=newuserdata.winName;
    timeH = tmp(1, 6);
    set(timeH, 'String', ['Time: ', sprintf('%.2f', t)]);
    % ====== Store theta as one element of the userdata
    % This is used for mouse to set target position
%    tmp = get(AnimBbFigH, 'userdata');
    tmp(3,5) = theta;
    newuserdata.tmp=tmp;
    set(AnimBbFigH, 'userdata', newuserdata);
    end
    end
    % ====== return nothing
    sys = [];
    x0=[];
    drawnow;    % for invoking with rk45, etc.
elseif ~isempty(flag) & flag == 9,   % When simulation stops ...
    % ====== change labels of standard UI controls
    if any(get(0, 'children') == AnimBbFigH),
    if strcmp(get(AnimBbFigH, 'Name'), AnimBbFigTitle),
    newuserdata = get(AnimBbFigH, 'userdata');
    tmp = newuserdata.tmp;
    set(tmp(1, 1), 'visible', 'on');    % start
    set(tmp(1, 2:5), 'visible', 'off');

    % At end of simulation re-enable the Target Position pop-up menu
    kids = get(AnimBbFigH,'Children');
    PopUpMenuHndl = findobj(kids,'Tag','SourceSelect');
    set(PopUpMenuHndl,'enable','on');

    end
    end
elseif ~isempty(flag) & flag == 0,
    % ====== find animation block & figure
    [winName] = bdroot(gcs);
    AnimBbFigTitle = [winName, ': Ball & Beam Animation'];
    AnimBbFigH = findobj(0,'Name',AnimBbFigTitle);
    % ====== % No figure, initialize everything
    if isempty(AnimBbFigH),
        ui_row_n = 2;   % No. of UI rows
        % ###### default UI settings for SIMUINK ######
        AnimBbFigH = figure( ...
            'Name', AnimBbFigTitle, ...
            'NumberTitle', 'off',...
            'DockControls', 'off');
        figPos = get(AnimBbFigH, 'position');
        % ====== proportion of UI frame and axes
        ui_area = 0.2;
        axis_area = 1-ui_area;
        % ====== animation area 
        axisPos = [0 figPos(4)*ui_area figPos(3) figPos(4)*axis_area];
        % weird thing: if you don't use normalized unit for
        % axes, patch for ground doesn't appear
        axisPos = axisPos./[figPos(3) figPos(4) figPos(3) figPos(4)];
        AnimBbAxisH = ...
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
        newuserdata.tmp=tmp;
        newuserdata.winName=winName;
        set(AnimBbFigH, 'userdata', newuserdata);

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
        set(upH(4),'Tag','SourceSelect');
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
        olduserdata=get(AnimBbFigH, 'userdata');
        newuserdata.tmp=[olduserdata.tmp; tmp];
        newuserdata.winName=winName;
        set(AnimBbFigH, 'userdata', newuserdata);

        % ###### animation objects ######
        % ====== ball
        radius = 0.1; 
        theta = linspace(0, 2*pi, 21);
        ball = radius*exp(j*theta) + j*2*radius;
        ballH = patch(real(ball), imag(ball), 'm');
        set(ballH, 'erase', 'xor');
        set(ballH, 'userdata', ball);
        % ====== beam
        beam_length = 4.0;
        beam_width = radius;
        beam = beam_length/2*[-1 1 1 -1 -1]' + ...
            sqrt(-1)*(beam_width/2*[-1 -1 1 1 -1]' + beam_width/2);
        beamH = patch(real(beam), imag(beam), 'y');
        set(beamH, 'erase', 'xor');
        set(beamH, 'userdata', beam);
        % ====== force arrow 
        force_x = [-1 0 nan -0.1 0 -0.1];
        force_y = [0 0 nan 0.1 0 -0.1];
        force = force_x + j*force_y;
        force = force*exp(j*pi/2);
        forceH = line(real(force), imag(force), ...
            'erase', 'xor', 'color', 'c', 'clip', 'off');
        set(forceH, 'userdata', force, ...
            'xdata', [0], 'ydata', [0]);
        % ====== reference triangle
        ref = 2*beam_width*[-1 1 0 -1]' + ...
            sqrt(-1)*(4*beam_width*[0 0 1 0]' - 4*beam_width);
        refH = line(real(ref), imag(ref));
        set(refH, 'color', 'r', 'linewidth', 2);
        %refH = patch(real(ref), imag(ref), 'r');
        set(refH, 'erase', 'xor');
        set(refH, 'userdata', ref);
        % ====== support triangle
        support_height = radius*10;
        support_width = support_height;
        support = support_width/2*[-1 1 0 -1]' + ...
            sqrt(-1)*(support_height*[0 0 1 0]' - support_height);
        supportH = patch(real(support), imag(support), 'g');
        set(supportH, 'erase', 'xor');
        set(supportH, 'userdata', ref);
        % ====== axis settings
        pos_range = [-3 3];
        set(AnimBbAxisH, 'clim', [1 64], ...
            'xlim', pos_range, ...
            'ylim', [-1.5*support_height 2.98-1.5*support_height], ...
            'box', 'on');
        axis equal;
        set(AnimBbAxisH, 'visible', 'off');
        % ====== colormap settings for floor
        colormap(gray); %  To assign correct patch color
        patch([pos_range -pos_range], ...
            0.2*[-2 -2 0 0]-support_height, [10 10 55 55]);
        % ====== append the handles as third row of userdata
        tmp = [ballH beamH forceH refH -1 -1 -1 -1 -1 -1];

        olduserdata=get(AnimBbFigH, 'userdata');
        newuserdata.tmp=[olduserdata.tmp; tmp];
        newuserdata.winName=winName;

        set(AnimBbFigH, 'userdata', newuserdata);
        % ====== change to normalized units
        set(findobj(AnimBbFigH,'Units','pixels'), 'Units','normalized');
        % ====== move the reference triangle by mouse
        % action when button is first pushed down
        action1 = [mfilename '([], [], [], [], ''mouse_action'')'];
        % actions after the mouse is pushed down
        action2 = action1;
        % action when button is released
        action3 = action2;

        % temporary storage for the recall in the down_action
        set(AnimBbAxisH,'UserData',action2);

        % set action when the mouse is pushed down
        down_action=[ ...
            'set(AnimBbFigH,''WindowButtonMotionFcn'',get(AnimBbAxisH,''UserData''));' ...
            action1];
        set(AnimBbFigH,'WindowButtonDownFcn',down_action);

        % set action when the mouse is released
        up_action=[ ...
            'set(AnimBbFigH,''WindowButtonMotionFcn'','' '');', action3];
        set(AnimBbFigH,'WindowButtonUpFcn',up_action);
    end
    % ====== change labels of standard UI controls
    
    newuserdata= get(AnimBbFigH, 'userdata');
    tmp = newuserdata.tmp;
    set(tmp(1, 1), 'visible', 'off');
    set(tmp(1, 2:3), 'visible', 'on');
    sys = [0 0 0 4 0 0];
    x0=[];
    set(AnimBbFigH, 'HandleVisibility', 'on');
elseif nargin == 5, % for callbacks of GUI
    % ###### standard UI controls
    if strcmp(action, 'start_sl'),
%        tmp = get(AnimBbFigH, 'userdata');
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        set(tmp(1, 1), 'visible', 'off');
        set(tmp(1, 2:3), 'visible', 'on');
        winName = newuserdata.winName;
        set_param(winName, 'SimulationCommand', 'start');
    elseif strcmp(action, 'stop_sl'),
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        set(tmp(1, 1), 'visible', 'on');
        set(tmp(1, 2:5), 'visible', 'off');
        winName = newuserdata.winName;
        set_param(winName, 'SimulationCommand', 'stop');
    elseif strcmp(action, 'pause_sl'),
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        winName=newuserdata.winName;
        set(tmp(1, 3), 'visible', 'off');
        set(tmp(1, 4:5), 'visible', 'on');
%        [winName] = bdroot(gcs);
        set_param(winName, 'SimulationCommand', 'pause');
    elseif strcmp(action, 'step_sl'),
        newuserdata= get(AnimBbFigH, 'userdata');
        winName=newuserdata.winName;
        set_param(winName, 'SimulationCommand', 'step');
    elseif strcmp(action, 'continue_sl'),
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        winName=newuserdata.winName;
        set(tmp(1, 3), 'visible', 'on');
        set(tmp(1, 4:5), 'visible', 'off');
        set_param(winName, 'SimulationCommand', 'continue');
    elseif strcmp(action, 'info'),
        helpwin(mfilename);
    %   title = get(AnimBbFigH, 'Name');
    %   content = ...
    %   ['                                                    '
    %    ' Animation of the ball & beam (BB) system, where a  '
    %    ' Sugeno-type fuzzy controller is used to move the   '
    %    ' ball to a target position indicated by the red     '
    %    ' triangle.                                          '
    %    '                                                    '
    %    ' If the target position is chosen as mouse-driven,  '
    %    ' you can click your mouse inside the red triangle   '
    %    ' to move it to another position.                    '
    %    '                                                    '
    %    ' Animation S-function: animbb.m                     '
    %    ' SIMULINK file: slbb.m                              '];
    %   fhelpfun(title, content);
    elseif strcmp(action, 'close'),
%       [winName, sysName] = get_param;
%       set_param(winName, 'Simulation running', 'stop');
        delete(AnimBbFigH);

    % ###### additional UI controls
    elseif strcmp(action, 'target_pos'),
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        winName=newuserdata.winName;
        if strcmp(get_param(winName,'SimulationStatus'),'running')
            error('Cannot change target position when simulation is running')
        end
        signal_block = [winName, '/Target Position'];
        constant_block = [winName, '/Constant'];
        signalH = tmp(2, 1);
        signal = get(signalH, 'value');
        if signal == 1, % sinusoid wave
            set_param(signal_block, 'wave', 'sine');
            set_param(constant_block, 'value','1');
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
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        winName=newuserdata.winName;
        dispmodeH = tmp(2, 2);
        objectH = tmp(3, 1:4);
        dispmode = get(dispmodeH, 'value');
        if dispmode == 0,   % xor
            set(objectH, 'erasemode', 'xor');
            set(AnimBbFigH, 'color', get(AnimBbFigH, 'color'));
        else
            set(objectH, 'erasemode', 'none');
        end
    elseif strcmp(action, 'clear_trail'),
        refresh(AnimBbFigH);
    elseif strcmp(action, 'mouse_action')
        newuserdata= get(AnimBbFigH, 'userdata');
        tmp = newuserdata.tmp;
        winName=newuserdata.winName;
        if str2double(get_param([winName, '/Constant'], 'value')) < 0,
            curr_info = get(AnimBbAxisH, 'CurrentPoint');
%            tmp = get(AnimBbFigH, 'UserData');
            beamH = tmp(3, 2);
            refH = tmp(3, 4);
            theta = tmp(3, 5);
            beam = get(beamH, 'userdata');
            beam_length = real(beam(2)) - real(beam(1));

            desired_pos = curr_info(1,1)/cos(theta);
            desired_pos = min(max(desired_pos, ...
                -beam_length/2.5), beam_length/2.5);
            ref = get(refH, 'userdata');
            new_ref = (ref + desired_pos)*exp(j*theta);
            set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
            set_param([winName, '/Target Position',13,'(Mouse-Driven)'],...
                'value', num2str(desired_pos));
        end
    else
        fprintf('Unknown action string: %s.\n', action);
    end
end
