function invkine(action)
%INVKINE Inverse kinematics of a robot arm.
%   INVKINE opens a window for animation of the inverse kinematics 
%   problem of the two-joint robot arm system. The ellipse is the 
%   desired trajectory; you can change the location of the ellipse by
%   clicking mouse inside it and dragging it to another location.
%   The x marks in the background indicate the location of each
%   training data pair.
%
%   The training of ANFIS for this problem was done off-line.
%   To see how the training data set was collected and how to do
%   the training, see the file traininv.m. To see both the surfaces
%   for forward and backward kinematics, try invsurf.m.
%
%   File: invkine.m
%
%   See also INVSURF, TRAININV.

%   Roger Jang, 3-31-94, 10-17-94, 12-23-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $  $Date: 2004/04/10 23:15:19 $

if nargin == 0,
    action = 'initialize';
end

global InvKineInsideEllipse InvKineCurrPt
global InvKineFigH InvKineFigTitle InvKineAxisH
global InvKineAnimRunning InvKineAnimStepping InvKineAnimPause
global InvKineAnimClose InvKineCount InvKineFisMat1 InvKineFisMat2

if strcmp(action, 'initialize'),
    InvKineFigTitle = 'Two-Joint Planar Robot Arm: Animation';
    InvKineFigH = findobj(0, 'Name', InvKineFigTitle);
    InvKineCount = 1;
    if isempty(InvKineFigH)
        %eval([mfilename, '(''set_standard_gui'')']);
        %eval([mfilename, '(''set_extra_gui'')']);
        eval([mfilename, '(''set_all_gui'')']);
        eval([mfilename, '(''set_anim_obj'')']);
        eval([mfilename, '(''set_mouse_action'')']);
        eval([mfilename, '(''load_fis_mat'')']);
        eval([mfilename, '(''single_loop'')']);
        % ====== change to normalized units
        set(findobj(InvKineFigH,'Units','pixels'), 'Units','normal');
        % ====== make all UI interruptable
        set(findobj(InvKineFigH,'Interrupt','off'), 'Interrupt','on');
    else
        eval([mfilename, '(''set_init_cond'')']);
%	set(gcf, 'color', get(gcf, 'color'));
	refresh(gcf);
    end
    eval([mfilename, '(''set_constant'')']);
elseif strcmp(action, 'set_constant'),
    InvKineAnimRunning = 0;
    InvKineAnimStepping = 0;
    InvKineAnimPause = 0;
    InvKineAnimClose = 0;
elseif strcmp(action, 'set_all_gui'),
%elseif strcmp(action, 'set_standard_gui'),
    % ====== standard UI's
    % ====== % No figure, initialize everything
    ui_row_n = 2;   % No. of UI rows
    % ###### default UI settings for SIMUINK ######
    InvKineFigH = figure( ...
        'Name', InvKineFigTitle, ...
        'NumberTitle', 'off', ...
        'DockControls', 'off');
    % Set V4 default color
    colordef(InvKineFigH, 'black');
    set(InvKineFigH, 'color', [0 0 0]);
    set(0, 'Currentfigure', InvKineFigH);
    figPos = get(InvKineFigH, 'position');
    % ====== proportion of UI frame and axes
    ui_area = 0.2;
    axis_area = 1-ui_area;
    % ====== animation area 
    axisPos = [0 figPos(4)*ui_area figPos(3) figPos(4)*axis_area];
    % weird thing: if you don't use normalized unit for
    % axes, patch for ground doesn't appear
    axisPos = axisPos./[figPos(3) figPos(4) figPos(3) figPos(4)];
    InvKineAxisH = ...
        axes('unit', 'normal', 'pos', axisPos, 'box', 'on');
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
    cb1 = [mfilename '(''info'')'];
    cb2 = [mfilename '(''close'')'];
    [lrH, lrPos] = uiarray(rPos, 1, 2, spacing, spacing, ...
        str2mat('push', 'push'), ...
        str2mat(cb1, cb2), ...
        str2mat('Help', 'Close'));
    infoH = lrH(1); set(infoH, 'tag', 'info');
    closeH = lrH(2); set(closeH, 'tag', 'close');
    % ====== lower-left UI's (same for all SL animation)
    cb1 = '';
    cb2 = [mfilename '(''set_init_cond'');' mfilename '(''main_loop'');'];
    cb3 = '';
    cb4 = '';
    [llH, llPos] = uiarray(lPos, 1, 4, spacing, spacing, ...
        str2mat('text', 'push', 'text', 'text'), ...
        str2mat(cb1, cb2, cb3, cb4), ...
        str2mat('0', 'Start Animation ...','',''));
    countH = llH(1); set(countH, 'tag', 'count');
    % ====== extend the width of start button
    delete(llH(3:4));
    startH = llH(2); set(startH, 'tag', 'start');
    startPos = llPos(2,:);
    startPos(3) = 3*startPos(3)+2*spacing;
    set(startH, 'pos', startPos);
    % ====== create stop and pause (under start)
    cb1 = [mfilename '(''stop_anim'')'];
    cb2 = [mfilename '(''pause_anim'')'];
    cb3 = '';
    [h, pos] = uiarray(startPos, 1, 3, 0,spacing,'push', ...
        str2mat(cb1, cb2, cb3), ...
        str2mat('Stop', 'Pause ...', ''));
    set(h, 'visible', 'off');
    stopH = h(1); set(stopH, 'tag', 'stop');
    pauseH = h(2); set(pauseH, 'tag', 'pause');
    % ====== extend the width of pause button
    delete(h(3));
    pausePos = pos(2, :);
    pausePos(3) = 2*pausePos(3)+spacing;
    set(pauseH, 'pos', pausePos);
    % ===== create continue and step (under pause)
    cb1 = [mfilename '(''continue_anim'')'];
    cb2 = [mfilename '(''step_anim'')'];
    [h, pos] = uiarray(pausePos, 1, 2, 0, spacing, ...
        'push', ...
        str2mat(cb1, cb2), ...
        str2mat('Continue', 'Step'));
    set(h, 'visible', 'off');
    contH = h(1); set(contH, 'tag', 'continue');
    stepH = h(2); set(stepH, 'tag', 'step');
    %===== put UI handles into current figure's user data 
    tmp = [startH stopH pauseH contH stepH countH -1 -1 -1 -1];
    set(InvKineFigH, 'userdata', tmp, 'HandleVisibility', 'on');

%elseif strcmp(action, 'set_extra_gui'),    % extra UI's
    % ====== extra UI
    % ====== The upper UI controls (Specific to each animation)
    cb1 = [mfilename '(''show_trail'')'];
    cb2 = [mfilename '(''clear_trail'')'];
    cb3 = '';
    cb4 = [mfilename '(''target_pos'')'];

    string1 = 'Show Trails';
    string2 = 'Clear Trails';
    string3 = 'Using mouse to drag target oval inside yellow x marked area';
    string4 = 'Ellipse|Mouse-Driven|';

    [upH, upPos] = uiarray(Pos(1,:), 1, 4, spacing, 1*spacing, ...
        str2mat('check', 'push', 'text', 'popup'), ...
        str2mat(cb1, cb2, cb3, cb4), ...
        str2mat(string1, string2, string3, string4));
    set(upH(3), 'HorizontalAlignment', 'right');
    showTrailH = upH(1); set(showTrailH, 'tag', 'show_trail');
    signalH = upH(4);
    % The following will be put back if we have more than one
    % desired trajectory
    thispos1=get(upH(2),'Position');
    thispos1(1)=thispos1(1)*.7;
    thispos1(3)=thispos1(3)*.8;
    set(upH(2),  'Position', thispos1);
    thispos=get(upH(3),'Position');
    thispos(3)=thispos(3)*2.4;
    thispos(1)=thispos(1)*.8;
    set(upH(3),  'Position', thispos);
%    delete(upH(3));
    delete(upH(4));
    % ====== Appending handles as the second row of userdata
    tmp = [signalH showTrailH -1 -1 -1 -1 -1 -1 -1 -1];
    set(InvKineFigH, 'userdata', [get(InvKineFigH, 'userdata'); tmp]);

    % ====== change labels of standard UI controls
%   tmp = get(InvKineFigH, 'userdata');
%   set(tmp(1, 1), 'visible', 'off');
%   set(tmp(1, 2:3), 'visible', 'on');

elseif strcmp(action, 'set_mouse_action'),
    % action when button is first pushed down
    action1 = [mfilename '(''mouse_action1'')'];
    % actions after the mouse is pushed down
    action2 = [mfilename '(''mouse_action2'')'];
    % action when button is released
    action3 = [mfilename '(''mouse_action3'')'];

    % temporary storage for the recall in the down_action
    set(gca,'UserData',action2);

    % set action when the mouse is pushed down
    down_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'',get(gca,''UserData''));' ...
        action1];
    set(gcf,'WindowButtonDownFcn',down_action);

    % set action when the mouse is released
    up_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'','' '');', action3];
    set(gcf,'WindowButtonUpFcn',up_action);
elseif strcmp(action, 'set_init_cond'),
    % This is called whenevern going from "stop" to "start"
    InvKineCount = 1;
    % set desired trajectory
    r1 = 5; r2 = 3;         % axes for reference ellipse
    center = 11*exp(j*pi/4);    % center for reference ellipse
    data_n = 50;
    t = linspace(0, 2*pi, data_n)-pi/2;
    desired_traj = r1*cos(t) + j*r2*sin(t) +  center;
    tmp = get(findobj(0, 'name', InvKineFigTitle), 'userdata');
    desired_trajH = tmp(3, 4);
    set(desired_trajH, 'xdata', real(desired_traj));
    set(desired_trajH, 'ydata', imag(desired_traj));
    % set actually trajectory
    actual_trajH = tmp(3, 5);
    data = desired_traj(1)*ones(2,1);
    set(actual_trajH, 'xdata', real(data));
    set(actual_trajH, 'ydata', imag(data));
    eval([mfilename, '(''clear_trail'')']);
elseif strcmp(action, 'set_anim_obj'),
    l1 = 10; l2 = 7;        % specifications for robot arms
    r1 = 5; r2 = 3;         % axes for reference ellipse
    % ====== arm 1
    init_pos = [0; l1] + j*[0; 0];
    arm1H = line(real(init_pos), imag(init_pos));
    set(arm1H, 'userdata', l1);
    set(arm1H, 'erasemode', 'xor', 'color', 'r', 'linewidth', 4);
    set(arm1H, 'clipping', 'off');
    % ====== arm 2
    init_pos = [l1; l1+l2] + j*[0; 0];
    arm2H = line(real(init_pos), imag(init_pos));
    set(arm2H, 'userdata', l2);
    set(arm2H, 'erasemode', 'xor', 'color', 'c', 'linewidth', 4);
    set(arm2H, 'clipping', 'off');
    % ====== small circle showing actual trajectory
    dotH = line(0, 0);
    set(dotH, 'Marker', 'o', 'color', 'g', 'erasemode', 'xor');
    set(dotH, 'linewidth', 2);
    % ====== desired trajectory
    center = 11*exp(j*pi/4);    % center for reference ellipse
    data_n = 50;
    t = linspace(0, 2*pi, data_n)-pi/2;
    desired_traj = r1*cos(t) + j*r2*sin(t) +  center;
    desired_trajH = line(real(desired_traj), imag(desired_traj));
    set(desired_trajH, 'erasemode', 'xor');
    set(desired_trajH, 'linewidth', 2, 'userdata', desired_traj);
    set(desired_trajH, 'clipping', 'off');
    % ====== actual trajectory
    actual_trajH = line([1 1]*real(desired_traj(1)), ...
        [1 1]*imag(desired_traj(1)));
    set(actual_trajH, 'erase', 'none', 'color', 'w');
    set(actual_trajH, 'clipping', 'off');
    set(actual_trajH, 'linewidth', 2, 'linestyle', '--');
    % ====== setting axis
    axis([0 l1+l2 0 l1+l2]);
    axis equal;
    axis square;
    % ====== Plot locations for the training data
    load invkine.mat
    tmp = line(invkine1(:, 1), invkine1(:, 2));
    set(tmp, 'Marker', 'x', 'LineStyle', 'none');
    xlabel('X'); ylabel('Y');
    % ====== set 'userdata'
    tmp = [arm1H arm2H dotH desired_trajH actual_trajH -1 -1 -1 -1 -1];
    set(InvKineFigH, 'userdata', [get(InvKineFigH, 'userdata'); tmp]);
elseif strcmp(action, 'single_loop'),
    % ====== get animation objects
    tmp = get(InvKineFigH, 'userdata');
    arm1H = tmp(3, 1);
    arm2H = tmp(3, 2);
    dotH = tmp(3, 3);
    desired_trajH = tmp(3, 4);
    actual_trajH = tmp(3, 5);
    l1 = get(arm1H, 'userdata');
    l2 = get(arm2H, 'userdata');
    countH = tmp(1, 6);
    % ====== get FIS handle
    fisH1 = tmp(3, 6);
    fisH2 = tmp(3, 7);
    % ====== get desired position
    desired_traj = get(desired_trajH,'xdata')+j*get(desired_trajH,'ydata');
    desired_pos = desired_traj(rem(InvKineCount, length(desired_traj))+1);
    x = real(desired_pos);
    y = imag(desired_pos);
    % ====== evaluate FIS to get joint angles
    theta1 = evalfis([x, y], InvKineFisMat1);
    theta2 = evalfis([x, y], InvKineFisMat2);
    % ====== count operation
    set(countH, 'string', int2str(InvKineCount));
    InvKineCount = InvKineCount+1;
    % ====== update animation objects
    set(dotH, 'xdata', x, 'ydata', y);
    end1 = l1*exp(j*theta1);
    end2 = end1 + l2*exp(j*(theta1+theta2));
    set(arm1H, 'xdata', [0 real(end1)], 'ydata', [0 imag(end1)]);
    set(arm2H, 'xdata', [real(end1) real(end2)], ...
        'ydata', [imag(end1) imag(end2)]);
    tmp_x = get(actual_trajH, 'xdata');
    tmp_y = get(actual_trajH, 'ydata');
    set(actual_trajH, 'xdata', [tmp_x(2), real(end2)], ...
        'ydata', [tmp_y(2), imag(end2)]);
    drawnow;
elseif strcmp(action, 'main_loop'),
    InvKineAnimRunning = 1;
    % ====== get animation objects
    tmp = get(InvKineFigH, 'userdata');
    % ====== change visibility of GUI's 
    set(tmp(1, 1), 'visible', 'off');
    set(tmp(1, 4:5), 'visible', 'off');
    set(tmp(1, 2:3), 'visible', 'on');
    % ====== looping
    while 1 & ~InvKineAnimClose
        if ~InvKineAnimRunning | InvKineAnimPause,
            break;
        end
        eval([mfilename, '(''single_loop'')']);
    end
    % ====== shut down 
    if InvKineAnimClose,
        delete(InvKineFigH);
    end
elseif strcmp(action, 'load_fis_mat'),
    tmp = get(InvKineFigH, 'userdata');
    % ====== Read FIS matrices if necessary 
    if tmp(3, 6) < 0,   % FIS not been build
        % ====== read FIS matrix
        InvKineFisMat1 = readfis('invkine1');
        InvKineFisMat2 = readfis('invkine2');
        % ====== change flag
        tmp(3, 6) = 1;
        set(InvKineFigH, 'userdata', tmp);
    end
elseif strcmp(action, 'mouse_action1'),
    % mouse action when button is first pushed down
    tmp = get(InvKineFigH, 'userdata');
    desired_trajH = tmp(3, 4);
    curr_info = get(gca, 'CurrentPoint');
    InvKineCurrPt = curr_info(1, 1) + j*curr_info(1,2);
    now_ball_x = get(desired_trajH, 'xdata');
    now_ball_y = get(desired_trajH, 'ydata');
    now_ball = now_ball_x + j*now_ball_y;
    InvKineInsideEllipse = inside(InvKineCurrPt, now_ball.');
elseif strcmp(action, 'mouse_action2'),
    % mouse actions after the mouse is pushed down and dragged
    if InvKineInsideEllipse,
        tmp = get(InvKineFigH, 'userdata');
        desired_trajH = tmp(3, 4);
        prev_pt = InvKineCurrPt;
        curr_info = get(gca, 'CurrentPoint');
        InvKineCurrPt = curr_info(1,1) + j*curr_info(1,2);
        displace = InvKineCurrPt - prev_pt;
        old_ball_x = get(desired_trajH, 'xdata');
        old_ball_y = get(desired_trajH, 'ydata');
        new_ball = old_ball_x + j*old_ball_y + displace;
        set(desired_trajH, 'xdata', real(new_ball));
        set(desired_trajH, 'ydata', imag(new_ball));
    end
elseif strcmp(action, 'mouse_action3'),
    % mouse action when button is released
    eval([mfilename, '(''mouse_action2'')']);
% ###### standard UI controls
%elseif strcmp(action, 'start_anim'),
%   tmp = get(InvKineFigH, 'userdata');
%   set(tmp(1, 1), 'visible', 'off');
%   set(tmp(1, 2:3), 'visible', 'on');
%   if InvKineAnimRunning == 0,
%       InvKineAnimRunning = 1;
%   end
%   eval([mfilename, '(''start'')']);
elseif strcmp(action, 'stop_anim'),
    tmp = get(InvKineFigH, 'userdata');
    set(tmp(1, 1), 'visible', 'on');
    set(tmp(1, 2:5), 'visible', 'off');
    InvKineAnimRunning = 0;
    InvKineAnimPause = 0;
elseif strcmp(action, 'pause_anim'),
    tmp = get(InvKineFigH, 'userdata');
    set(tmp(1, 3), 'visible', 'off');
    set(tmp(1, 4:5), 'visible', 'on');
    InvKineAnimRunning = 0;
    InvKineAnimClose = 0;
    InvKineAnimPause = 1;
elseif strcmp(action, 'step_anim'),
    InvKineAnimStepping = 1;
    eval([mfilename, '(''single_loop'')']);
elseif strcmp(action, 'continue_anim'),
    tmp = get(InvKineFigH, 'userdata');
    set(tmp(1, 3), 'visible', 'on');
    set(tmp(1, 4:5), 'visible', 'off');
    InvKineAnimRunning = 1;
    InvKineAnimPause = 0;
    InvKineAnimClose = 0;
    InvKineAnimStepping = 0;
    eval([mfilename, '(''set_constant'')']);
    eval([mfilename, '(''main_loop'')']);
elseif strcmp(action, 'info'),
    helpwin(mfilename);
    %title = get(InvKineFigH, 'Name');
    %content = ...
    %['                                                    '
    % ' Animation of the inverse kinematics problem        '
    % ' when applied to the two-joint robot arm system.    '
    % ' The ellipse is the desired trajectory; you can     '
    % ' change the location of the ellipse by clicking     '
    % ' mouse inside it and dragging it to another         '
    % ' location. The crosses at background indicate       '
    % ' the locations of each training data pair.          '
    % '                                                    '
    % ' The training of ANFIS for this problem was done    '
    % ' off-line. To see how the training data set is      '
    % ' collected and how to do the training, see the      '
    % ' file traininv.m. To see both the surfaces for      '
    % ' forward and backward kinematics, try invsurf.m.    '
    % '                                                    '
    % ' File: invkine.m                                    '];
    %fhelpfun(title, content);
elseif strcmp(action, 'close'),
    if InvKineAnimRunning == 1,
        InvKineAnimClose = 1;   % close via main_loop
    else    % close when animation is stopped or paused
        delete(InvKineFigH);
    end
% ###### additional UI controls
%elseif strcmp(action, 'target_pos'),
%   signalH = tmp(2, 1);
%   signal = get(signalH, 'value');
%   if signal == 1, % Ellipse
%       set_param(signal_block, 'wave', 'sin');
%       set_param(constant_block, 'value', 1);
%   elseif signal == 2, % Mouse-driven
%       set_param(signal_block, 'wave', 'sqr');
%       set_param(constant_block, 'value', 1);
%   else
%       error('Unknown target_pos option!');
%   end
elseif strcmp(action, 'show_trail'),
    tmp = get(InvKineFigH, 'userdata');
    showTrailH = tmp(2, 2);
    objectH = tmp(3, 1:4);
    dispmode = get(showTrailH, 'value');
    if dispmode == 0,   % xor
        set(objectH, 'erasemode', 'xor');
    %   set(InvKineFigH, 'color', get(InvKineFigH, 'color'));
        refresh(InvKineFigH);
    else
        set(objectH, 'erasemode', 'none');
    end
elseif strcmp(action, 'clear_trail'),
%   set(InvKineFigH, 'color', get(InvKineFigH, 'color'));
    refresh(InvKineFigH);

else
    fprintf('Action string = %s\n', action);
    error('Unknown action string!');
end
