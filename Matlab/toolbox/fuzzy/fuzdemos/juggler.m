function [o1,o2,o3] = juggler(x_prev, y_prev, v_prev, delta_t, action)
%JUGGLER Ball juggling system.
%   JUGGLER opens a window for the animation of the ball juggling
%   system. The small triangle indicates the desired ball position.
%   You can choose either human or fuzzy control to control this
%   system. If it is controlled by human, click the steering arrow
%   at the upper right corner to change the tilted angle of the
%   hitting board. If it is controlled by the fuzzy controller, use
%   the mouse to change the location of the triangle. (If fuzzy 
%   controller is selected, the position of the small triangle will
%   also be updated randomly every 200 steps)
%
%   File: juggler.m
%
%   See also FUZDEMOS.

%   Roger Jang, 3-9-94, 10-20-94, 12-23-94. Kelly Liu, 11-20-97
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.17.2.2 $  $Date: 2004/04/10 23:15:21 $

if nargin == 0,
    action = 'initialize';
end

global JugFigH JugFigTitle JugAxisH
global JugAnimRunning JugAnimStepping JugAnimPause JugAnimClose
global JugUpdateBoard JugCount
global JugBallRadius xMin xMax ProjAngle theta
global DesiredPos SamplingTime xNextHit g
global JugFisMat

if strcmp(action, 'next_pos'), % Returns [x, y, v] at the next point
    o1 = x_prev + real(v_prev)*delta_t;
    o2 = y_prev + imag(v_prev)*delta_t - 0.5*g*delta_t^2;
    o3 = real(v_prev) + j*(imag(v_prev) - g*delta_t);
elseif strcmp(action, 'single_loop'),
    % ====== get animation objects
   if ~ishandle(JugFigH)
      return;
   end
    ud = get(JugFigH, 'userdata');
    ballH = ud(3, 1);
    plateH = ud(3, 2);
    refH = ud(3, 3);
    countH = ud(1, 6);
    ball = get(ballH, 'userdata');
    controllerH = ud(2, 1);
    which_controller = get(controllerH, 'value');
    plate = get(plateH, 'userdata');
    ref = get(refH, 'userdata');
    % ====== get state variables
    x_prev = ud(3, 8);
    y_prev = ud(3, 9);
    v_prev = ud(3, 10);
    % ====== Change the desired position randomly if it's fuzzy 
    % this is good for self-running demo
    autoupdate = 1;
    if rem(JugCount, 200) == 0 & which_controller == 2 & autoupdate,
        bound = [xMin+1.5*JugBallRadius xMax-1.5*JugBallRadius];
        DesiredPos = rand*(bound(2)-bound(1))+bound(1);
        new_ref = ref + DesiredPos;
        set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
    end
    % ====== find next position
    [x, y, v] = eval([mfilename, ...
        '(x_prev, y_prev, v_prev, SamplingTime, ''next_pos'')']);

    % ====== When y is out of range
    if y < JugBallRadius,
        JugUpdateBoard = 1;
        vy_prev = imag(v_prev);
        t_hit = (vy_prev+(vy_prev*vy_prev+2*g*(y_prev-JugBallRadius))^0.5)/g;
        x_hit = x_prev + real(v_prev)*t_hit; 
        % When the ball really hits the plate first
        if xMin+JugBallRadius <= x_hit & x_hit <= xMax-JugBallRadius,
            [x, y, v] = ...
            eval([mfilename, ...
            '(x_prev,y_prev,v_prev,''ground'',''reflect'')']);
        end
    end
    % ====== When x is out of range
    if ~(xMin+JugBallRadius <= x & x <= xMax-JugBallRadius),
        JugUpdateBoard = 1;
        if x < xMin + JugBallRadius,
            bound = xMin + JugBallRadius;
        else
            bound = xMax - JugBallRadius;
        end
        t_hit = abs(bound - x_prev)/real(v_prev);
        y_hit = y_prev + imag(v_prev)*t_hit + 0.5*g*t_hit^2;
        % When the ball really hits the wall first
        if y_hit > JugBallRadius & x < xMin+JugBallRadius,
            [x, y, v] = ...
            eval([mfilename, ...
            '(x_prev,y_prev,v_prev,''left_wall'',''reflect'')']);
        elseif y_hit > JugBallRadius & x > xMin+JugBallRadius,
            [x, y, v] = ...
            eval([mfilename, ...
            '(x_prev,y_prev,v_prev,''right_wall'',''reflect'')']);
        end
    end
    % Update plate position when the ball passes its highest point
    % or when the ball hits X bounds while it's falling
    if imag(v) < 0 & JugUpdateBoard,
        vy = imag(v);
        xNextHit = (vy + (vy*vy+2*g*(y-JugBallRadius))^0.5)/g*real(v)+x;
        xNextHit = min(max(xNextHit, ...
            xMin + JugBallRadius), xMax - JugBallRadius);

        if which_controller == 1,   % human controlller
            set(plateH, 'xdata', xNextHit + real(plate));
        else        % fuzzy controller
            theta = ...
            eval([mfilename, '(x, y, v, [], ''fuzzy_controller'')']);
            theta = min(max(theta, -pi/4), pi/4);
            new_plate = plate*exp(j*theta);
            set(plateH, 'ydata', imag(new_plate), ...
                'xdata', xNextHit + real(new_plate));
        end
        JugUpdateBoard = 0;
    end
    % ====== count operation
    set(countH, 'string', int2str(JugCount));
    JugCount = JugCount+1;
    % ====== update ball 
    set(ballH, 'xdata', x + real(ball), 'ydata', y + imag(ball));
    drawnow;
    % ====== put current state variables back into userdata
    ud(3, 8) = x;
    ud(3, 9) = y;
    ud(3, 10) = v;
    if ishandle(JugFigH)
     set(JugFigH, 'userdata', ud);
    end
elseif strcmp(action, 'reflect')
    subaction = delta_t;
    if strcmp(subaction, 'ground'),
        % The ball did hit the plate first
        ProjAngle = ProjAngle + 2*theta;
        % ====== change project angle if it downward.
        if ProjAngle < 0,
            ProjAngle = -ProjAngle;
            fprintf('Bouncing from the ground, project angle = %d\n', ...
                ProjAngle*180/pi);
        elseif ProjAngle > pi,  
            ProjAngle = 2*pi - ProjAngle;
            fprintf('Bouncing from the ground, project angle = %d\n', ...
                ProjAngle*180/pi);
        end

        vy_prev = imag(v_prev);
        t_hit = (vy_prev + (vy_prev*vy_prev+2*g*(y_prev-JugBallRadius))^0.5)/g;
        [x_hit, y_hit, v_in] = ...
        eval([mfilename, '(x_prev, y_prev, v_prev, t_hit, ''next_pos'')']);
        v_out = abs(v_in)*exp(j*ProjAngle);
        [o1, o2, o3] = ...
        eval([mfilename, '(x_hit, y_hit, v_out, SamplingTime-t_hit, ''next_pos'')']);
        % ====== The ball hits the wall also
        if o1 < xMin + JugBallRadius,
            bound = xMin + JugBallRadius;
            [o1, o2, o3] = ...
            eval([mfilename, '(2*bound-x_hit,JugBallRadius, -conj(v_out), SamplingTime-t_hit, ''next_pos'')']);
            ProjAngle = pi - ProjAngle;
        elseif o1 > xMax - JugBallRadius,
            bound = xMax - JugBallRadius;
            [o1, o2, o3] = ...
            eval([mfilename, '(2*bound-x_hit,JugBallRadius, -conj(v_out), SamplingTime-t_hit, ''next_pos'')']);
            ProjAngle = pi - ProjAngle;
        end
        % ====== Stay at ground if the ball cannot bounce
        if o2 < JugBallRadius
            o2 = y_prev;
            o3 = v_prev;
        end
    elseif strcmp(subaction, 'left_wall')
        % The ball did hit the left wall first
        bound = xMin + JugBallRadius;
        x_prev = 2*bound - x_prev;
        v_prev = -conj(v_prev);
        [o1, o2, o3] = ...
        eval([mfilename, '(x_prev, y_prev, v_prev, SamplingTime, ''next_pos'')']);
        ProjAngle = pi - ProjAngle;

        % The ball hits the ground also
        if o2 < JugBallRadius,
            [o1, o2, o3] = ...
            eval([mfilename, '(x_prev, y_prev, v_prev, ''ground'', ''reflect'')']);
        end
    elseif strcmp(subaction, 'right_wall')
        % The ball did hit the right wall first
        bound = xMax - JugBallRadius;
        x_prev = 2*bound - x_prev;
        v_prev = -conj(v_prev);
        [o1, o2, o3] = ...
        eval([mfilename, '(x_prev, y_prev, v_prev, SamplingTime, ''next_pos'')']);
        ProjAngle = pi - ProjAngle;

        % The ball hits the ground also
        if o2 < JugBallRadius,
            [o1, o2, o3] = ...
            eval([mfilename, '(x_prev, y_prev, v_prev, ''ground'', ''reflect'')']);
        end
    else
        fprintf('Subaction string = %s\n', subaction);
        error('Unknown subaction string in ''reflect''!');
    end
elseif strcmp(action, 'initialize'),
    JugFigTitle = 'Ball Juggling Animation';
    JugFigH = findobj(0,'Name', JugFigTitle);
    JugCount = 1;
    if isempty(JugFigH)
        eval([mfilename, '(0,0,0,0,''set_all_gui'')']);
        eval([mfilename, '(0,0,0,0,''set_anim_obj'')']);
        eval([mfilename, '(0,0,0,0,''set_mouse_action'')']);
        eval([mfilename, '(0,0,0,0,''load_fis_mat'')']);
%       eval([mfilename, '(0,0,0,0,''single_loop'')']);
        % ====== change to normalized units
        set(findobj(JugFigH,'Units','pixels'), 'Units','normal');
        % ====== make all UI interruptable
        set(findobj(JugFigH,'Interrupt','off'), 'Interrupt','on');
    else
       % set(gcf, 'color', get(gcf, 'color'));
	refresh(JugFigH);
    end
    eval([mfilename, '(0,0,0,0,''set_constant'')']);
    eval([mfilename, '(0,0,0,0,''set_init_cond'')']);
    ud = get(JugFigH, 'userdata');


%   set(ud(1, 1), 'visible', 'off');
%   set(ud(1, 4:5), 'visible', 'off');
%   set(ud(1, 2:3), 'visible', 'on');
    set(JugFigH, 'HandleVisibility', 'callback');
elseif strcmp(action, 'set_constant'),
    JugAnimRunning = 0;
    JugAnimStepping = 0;
    JugAnimPause = 0;
    JugAnimClose = 0;
    JugUpdateBoard = 1;
    g = 9.8;
    SamplingTime = 0.02;
%elseif strcmp(action, 'set_standard_gui'), % standard UI's
elseif strcmp(action, 'set_all_gui'),
    % ====== standard UI's
    % ====== % No figure, initialize everything
    ui_row_n = 2;   % No. of UI rows
    % ###### default UI settings for SIMUINK ######
    JugFigH = figure( ...
        'Name', JugFigTitle, ...
        'CloseRequestFcn', 'juggler(0, 0, 0, 0, ''stop_anim''); closereq', ...                             
        'NumberTitle', 'off', ...
        'DockControls', 'off');
    % V4 default color
    colordef(JugFigH, 'black');
    % Black background
    set(JugFigH, 'color', [0 0 0]);
    set(0, 'Currentfigure', JugFigH);
    figPos = get(JugFigH, 'position');
    % ====== proportion of UI frame and axes
    ui_area = 0.2;
    axis_area = 1-ui_area;
    % ====== animation area 
    axisPos = [0 figPos(4)*ui_area figPos(3) figPos(4)*axis_area];
    k =  1.0;
    x = axisPos(1); y = axisPos(2); w = axisPos(3); h = axisPos(4);
    axisPos = [x+w*(1-k)/2 y+h*(1-k)/2 w*k, h*k];
    % weird thing: if you don't use normalized unit for
    % axes, patch for ground doesn't appear
    axisPos = axisPos./[figPos(3) figPos(4) figPos(3) figPos(4)];
    JugAxisH = axes('unit', 'normal', 'pos', axisPos-[0 .0 0 0]);
    set(JugAxisH, 'visible', 'off');
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
    cb1 = [mfilename '(0,0,0,0,''info'')'];
    cb2 = [mfilename '(0,0,0,0,''close'')'];
    [lrH, lrPos] = uiarray(rPos, 1, 2, spacing, spacing, ...
        str2mat('push', 'push'), ...
        str2mat(cb1, cb2), ...
        str2mat('Help', 'Close'));
    infoH = lrH(1); set(infoH, 'tag', 'info');
    closeH = lrH(2); set(closeH, 'tag', 'close');
    % ====== lower-left UI's (same for all SL animation)
    cb1 = '';
    cb2 = [mfilename '(0,0,0,0,''set_init_cond'');', ...
           mfilename '(0,0,0,0,''main_loop'');'];
    cb3 = '';
    cb4 = '';
    [llH, llPos] = uiarray(lPos, 1, 4, spacing, spacing, ...
        str2mat('text', 'push', 'text', 'text'), ...
        str2mat(cb1, cb2, cb3, cb4), ...
        str2mat('t = 0', 'Start Animation ...','',''));
    countH = llH(1); set(countH, 'tag', 'count');
    % ====== extend the width of start button
    delete(llH(3:4));
    startH = llH(2); set(startH, 'tag', 'start');
    startPos = llPos(2,:);
    startPos(3) = 3*startPos(3)+2*spacing;
    set(startH, 'pos', startPos);
    % ====== create stop and pause (under start)
    cb1 = [mfilename '(0,0,0,0,''stop_anim'')'];
    cb2 = [mfilename '(0,0,0,0,''pause_anim'')'];
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
    cb1 = [mfilename '(0,0,0,0,''continue_anim'')'];
    cb2 = [mfilename '(0,0,0,0,''step_anim'')'];
    [h, pos] = uiarray(pausePos, 1, 2, 0, spacing, ...
        'push', ...
        str2mat(cb1, cb2), ...
        str2mat('Continue', 'Step'));
    set(h, 'visible', 'off');
    contH = h(1); set(contH, 'tag', 'continue');
    stepH = h(2); set(stepH, 'tag', 'step');
    %===== put UI handles into current figure's user data 
    ud = [startH stopH pauseH contH stepH countH -1 -1 -1 -1];
    set(JugFigH, 'userdata', ud);

%elseif strcmp(action, 'set_extra_gui'),    % extra UI's
    % ====== extra UI
    % ====== The upper UI controls (Specific to each animation)
    cb1 = [mfilename '(0,0,0,0,''show_trail'')'];
    cb2 = [mfilename '(0,0,0,0,''clear_trail'')'];
    cb3 = '';
    cb4 = [mfilename '(0,0,0,0,''set_mouse_action'')'];

    string1 = 'Show Trails';
    string2 = 'Clear Trails';
    string3 = 'Controller:';
    string4 = 'Human|Fuzzy';

    [upH, upPos] = uiarray(Pos(1,:), 1, 4, spacing, 2*spacing, ...
        str2mat('check', 'push', 'text', 'popup'), ...
        str2mat(cb1, cb2, cb3, cb4), ...
        str2mat(string1, string2, string3, string4));
    set(upH(3), 'HorizontalAlignment', 'right');
    controllerH = upH(4);
    showTrailH = upH(1); set(showTrailH, 'tag', 'show_trail');
    set(controllerH, 'value', 2);
    % ====== Appending handles as the second row of userdata
    tmp = [controllerH showTrailH -1 -1 -1 -1 -1 -1 -1 -1];
    set(JugFigH, 'userdata', [get(JugFigH, 'userdata'); tmp]);

    % ====== change labels of standard UI controls
%   ud = get(JugFigH, 'userdata');
%   set(ud(1, 1), 'visible', 'off');
%   set(ud(1, 2:3), 'visible', 'on');
elseif strcmp(action, 'set_init_cond'),
    JugCount = 1;
    theta = 0;
    ProjAngle = pi/3;
    v_magnitude = 4.5;
    x_prev = xMin + JugBallRadius;
    y_prev = JugBallRadius;
    v_prev = v_magnitude*exp(j*ProjAngle);
    ud = get(findobj(0, 'name', JugFigTitle), 'userdata');
    ud(3, 8) = x_prev;
    ud(3, 9) = y_prev;
    ud(3, 10) = v_prev;
    set(JugFigH, 'userdata', ud);
    DesiredPos = (xMin+xMax)/2;
    % ====== set refH
    refH = ud(3, 3);
    ref = get(refH, 'userdata');
    new_ref = ref + DesiredPos;
    set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref)); 
    % ====== set plate
    plateH = ud(3, 2);
    plate = get(plateH, 'userdata');
    new_plate = plate*exp(j*theta);
    set(plateH, 'xdata', real(new_plate), 'ydata', imag(new_plate));
    % ====== set arrow
    arrowH = ud(3, 4);
    center = ud(3, 7);
    arrow = get(arrowH, 'userdata');
    new_arrow = arrow*exp(sqrt(-1)*theta) + center;
    set(arrowH, 'xdata', real(new_arrow), 'ydata', imag(new_arrow));
    % ====== redraw
    eval([mfilename, '(0,0,0,0,''clear_trail'')']);
elseif strcmp(action, 'set_anim_obj'),
    % ====== Setting up the axis
    xMin = -2.0; xMax = -xMin;
    y_min = -0.3; y_max = -xMin;
    axis([xMin xMax y_min y_max]);
    axis equal;
    % ====== Setting up the ground
    %colormap(gray); %  To assign correct patch color
    %patch([xMin xMax xMax xMin], ...
    %   [-y_max/8 -y_max/8 0 0], [10 10 55 55]);
    h = line([xMin xMax], [0 0]);
    set(h, 'color', 'b');
    % ====== Setting up the ball
    JugBallRadius = 0.1; 
    ball = JugBallRadius*exp(j*linspace(0, 2*pi, 21));
    %colormap(cool);
    %ballH = patch(real(ball), imag(ball), 64*ones(size(ball)));
    ballH = line(real(ball)+xMin + JugBallRadius, imag(ball)+JugBallRadius);
    set(ballH, 'color', 'c', 'clipping', 'off', 'erasemode','xor');
    set(ballH, 'userdata', ball);
    % ====== Setting up the plate
    plate_leng = (xMax-xMin)/10;
    plate = plate_leng*[-0.5 0.5]' + j*[0 0]';
    plateH = line(real(plate), imag(plate));
    set(plateH, 'color', 'y', 'erasemode', 'xor', 'linewidth', 5);
    set(plateH, 'userdata', plate);
    % ====== Setting up the base
    %baseH = line(real(plate), imag(plate));
    %set(baseH, 'color', 'r', 'erasemode', 'xor', 'linewidth', 5);
    %set(baseH, 'erase', 'xor', 'userdata', plate);
    %set(baseH, 'clipping', 'off');
    % ====== Setting the reference triangle
    ref = JugBallRadius*[-1 1 0 -1]' + j*2*JugBallRadius*[0 0 1 0]' - 2*j*JugBallRadius;
    refH = line(real(ref), imag(ref));
    set(refH, 'color', 'r', 'linewidth', 2);
    set(refH, 'erase', 'xor', 'clipping', 'off');
    set(refH, 'userdata', ref);
    % ====== Setting steering arrow
    sy_min = 1.50;  % min. of y of loc. of steering device
    sy_max = 2.00;  % max. of y of loc. of steering device
    s_JugBallRadius = (sy_max - sy_min)/sqrt(2);
    sx_min = 1.5;
    center = sx_min + j*((sy_max - sy_min)/2 + sy_min);
    tmp = s_JugBallRadius*exp(sqrt(-1)*linspace(-pi/4, pi/4, 100));
    arc = [0 tmp 0 s_JugBallRadius] + center;
    arrow_baseH = line(real(arc), imag(arc));
    dummyLine=line(real(center), real(center), 'color', 'black');
    set(arrow_baseH, 'clipping', 'off');
    arrow_x = [0 1 nan 0.9 1 0.9];
    arrow_y = [0 0 nan 0.1 0 -0.1];
    arrow = s_JugBallRadius*(arrow_x + sqrt(-1)*arrow_y);
    curr_arrow = arrow + center;
    arrowH = line(real(curr_arrow), imag(curr_arrow));
    set(arrowH, 'color', 'red', 'erasemode', 'xor');
    set(arrowH, 'clipping', 'off', 'userdata', arrow);
    set(arrowH, 'userdata', arrow);
    % ====== set 'userdata'
    ud = [ballH plateH refH arrowH arrow_baseH -1 center -1 -1 -1];
    % ud(6) is for JugFisMat flag, ud(8:10) is for x, y and v
    set(JugFigH, 'userdata', [get(JugFigH, 'userdata'); ud]);
elseif strcmp(action, 'set_mouse_action'),
    ud = get(JugFigH, 'userdata');
    which_controller = get(ud(2, 1), 'value');
    if which_controller == 1,   % human controller
        % ====== move refH to center
        DesiredPos = (xMin+xMax)/2;
        refH = ud(3, 3);
        ref = get(refH, 'userdata');
        new_ref = ref + DesiredPos;
        set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref)); 
        % ====== show steering arrow
        set(ud(3,4:5), 'visible', 'on');
        % ====== action when button is first pushed down
        action1 = [mfilename '(0,0,0,0,''mouse_action_steering'')'];
        % ====== actions after the mouse is pushed down
        action2 = action1;
        % ====== action when button is released
        action3 = action1;
    else                % automatic controller
        % ====== hide steering arrow
        set(ud(3,4:5), 'visible', 'off');
        % ====== action when button is first pushed down
        action1 = [mfilename '(0,0,0,0,''mouse_action_ref'')'];
        % ====== actions after the mouse is pushed down
        action2 = '';
        % ====== action when button is released
        action3 = '';
    end
    % ====== temporary storage for the recall in the down_action
    set(gca,'UserData',action2);
    % ====== set action when the mouse is pushed down
    down_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'',get(gca,''UserData''));' ...
        action1];
    set(gcf,'WindowButtonDownFcn',down_action);
    % ====== set action when the mouse is released
    up_action=[ ...
        'set(gcf,''WindowButtonMotionFcn'','' '');', action3];
    set(gcf,'WindowButtonUpFcn',up_action);
elseif strcmp(action, 'main_loop'),
    JugAnimRunning = 1;
    % ====== get animation objects
    tmp = get(JugFigH, 'userdata');
    % ====== change visibility of GUI's 
    set(tmp(1, 1), 'visible', 'off');
    set(tmp(1, 4:5), 'visible', 'off');
    set(tmp(1, 2:3), 'visible', 'on');
    % ====== looping
    while 1 & ~JugAnimClose
        if ~JugAnimRunning | JugAnimPause,
            break;
        end
        eval([mfilename, '(0, 0, 0, 0, ''single_loop'')']);
    end
    % ====== shut down 
    if JugAnimClose,
        delete(JugFigH);
    end
elseif strcmp(action, 'load_fis_mat'),
    ud = get(JugFigH, 'userdata');
    if ud(3, 6) < 0,    % FIS not been built
        JugFisMat = readfis('juggler');
        ud(3, 6) = 1;
        set(JugFigH, 'userdata', ud);
    end

    name='juggler';
    figNum=findobj(allchild(0), 'name', ['Rule Viewer: ' name]);
    if isempty(figNum)
     ruleview(JugFisMat);
     figNum=findobj(allchild(0), 'name', ['Rule Viewer: ' name]);
     pstn=get(figNum, 'Position');
     set(figNum, 'Position', pstn+[.35 -.3 0 0]);
     figure(JugFigH);
    else
     figure(figNum);
    end

elseif strcmp(action, 'mouse_action_steering')
    % Action for mouse when steered by human
    tmp = get(gca, 'currentpoint');
    tmp_x = tmp(1, 1); tmp_y = tmp(1, 2);
    ud = get(gcf, 'userdata');
    center = ud(3, 7);
    theta = angle(tmp_x + sqrt(-1)*tmp_y - center);,
    theta = min(max(theta, -pi/4), pi/4);
    plateH = ud(3, 2);
    arrowH = ud(3, 4);
    arrow = get(arrowH, 'userdata');
    plate = get(plateH, 'userdata');
    new_arrow = arrow*exp(sqrt(-1)*theta) + center;
    set(arrowH, 'xdata', real(new_arrow), 'ydata', imag(new_arrow));
    new_plate = plate*exp(j*theta);
    set(plateH, 'xdata', xNextHit + real(new_plate), ...
        'ydata', imag(new_plate));
elseif strcmp(action, 'mouse_action_ref')
    curr_info = get(gca, 'CurrentPoint');
    mouse_pos = curr_info(1,1);
    bound = [xMin+1.5*JugBallRadius xMax-1.5*JugBallRadius];
    DesiredPos = min(max(mouse_pos, bound(1)), bound(2));
    ud = get(JugFigH, 'userdata');
    refH = ud(3, 3);
    new_ref = get(refH, 'userdata') + DesiredPos;
    set(refH, 'xdata', real(new_ref), 'ydata', imag(new_ref));
elseif strcmp(action, 'ideal_controller'), % Ideal controller
    % ====== find where the ball hits the ground
    vy = imag(v_prev);
    t_hit = (vy + (vy*vy+2*g*(y_prev-JugBallRadius))^0.5)/g;
    x_hit = real(v_prev)*t_hit + x_prev;
    v_hit = real(v_prev) + j*(imag(v_prev) - g*t_hit);
    % ====== get animation objects
    % Note that sin(2*theta) = k has two solution theta1 and theta2,
    % and theta1 + theta2 = pi/2;
    tmp = g*(DesiredPos - x_hit)/abs(v_hit)^2;
    tmp = min(max(tmp, -1), 1);
    tmp_angle = asin(tmp);

    % tmp_angle is equal to two times the next_project_angle
    % tmp_angle must be in [0, 2*pi] in order to make the next
    % project angle between [0, pi].
    % For every tmp_angle, we can find another solution.

    if tmp_angle >= 0,
        solution1 = tmp_angle;
        solution2 = pi - tmp_angle;
    else 
        solution1 = pi - tmp_angle;
        solution2 = 2*pi + tmp_angle;
    end

    % To make next_proj_angle as close as possible to pi/2
    if abs(solution1-pi) < abs(solution2-pi),
        next_proj_angle = solution1/2;
    else
        next_proj_angle = solution2/2;
    end
    o1 = (next_proj_angle - ProjAngle)/2;
elseif strcmp(action, 'fuzzy_controller'), % fuzzy controller
    % ====== find where the ball hits the ground
    vy = imag(v_prev);
    t_hit = (vy + (vy*vy+2*g*(y_prev-JugBallRadius))^0.5)/g;
    x_hit = real(v_prev)*t_hit + x_prev;
    v_hit = real(v_prev) + j*(imag(v_prev) - g*t_hit);
    % ====== get animation objects
    ud = get(JugFigH, 'userdata');
    o1 = evalfis([x_hit - DesiredPos ProjAngle], JugFisMat);
    % ====== rule viewer
    xx=allchild(0);
    figN=[];
    for i=1:length(xx)
       name=get(xx(i), 'name');
       if length(name)>11 & strcmp(name(1:12), 'Rule Viewer:');
          figN=xx(i);
          break;
       end
    end
    if ~isempty(figN)
      set(figN, 'HandleVis', 'on');
      ruleview('#simulink', [x_hit - DesiredPos ProjAngle], figN);
      set(figN, 'HandleVis', 'callback');
    end
elseif strcmp(action, 'state_feedback_controller'), % SF controller
    % ====== find where the ball hits the ground
    vy = imag(v_prev);
    t_hit = (vy + (vy*vy+2*g*(y_prev-JugBallRadius))^0.5)/g;
    x_hit = real(v_prev)*t_hit + x_prev;
    v_hit = real(v_prev) + j*(imag(v_prev) - g*t_hit);
    % ====== get animation objects
    ud = get(JugFigH, 'userdata');
    % coef is obtained from showsurf.m
    coef = [0.12493010239152 -0.50000000017091 0.78539816478460]';
    state = [x_hit-DesiredPos ProjAngle 1];
    out = state*coef;
elseif strcmp(action, 'stop_anim'),
    ud = get(JugFigH, 'userdata');
    set(ud(1, 1), 'visible', 'on');
    set(ud(1, 2:5), 'visible', 'off');
    JugAnimRunning = 0;
    JugAnimPause = 0;
elseif strcmp(action, 'pause_anim'),
    ud = get(JugFigH, 'userdata');
    set(ud(1, 3), 'visible', 'off');
    set(ud(1, 4:5), 'visible', 'on');
    JugAnimRunning = 0;
    JugAnimClose = 0;
    JugAnimPause = 1;
elseif strcmp(action, 'step_anim'),
    JugAnimStepping = 1;
    eval([mfilename, '(0, 0, 0, 0, ''single_loop'')']);
elseif strcmp(action, 'continue_anim'),
    ud = get(JugFigH, 'userdata');
    set(ud(1, 3), 'visible', 'on');
    set(ud(1, 4:5), 'visible', 'off');
    JugAnimRunning = 1;
    JugAnimPause = 0;
    JugAnimClose = 0;
    JugAnimStepping = 0;
    eval([mfilename, '(0,0,0,0,''set_constant'')']);
    eval([mfilename, '(0,0,0,0,''main_loop'')']);
elseif strcmp(action, 'info'),
    helpwin(mfilename);
%   title = get(JugFigH, 'Name');
%   content = ...
%   ['                                                    '
%    ' Animation of the ball juggling system. The small   '
%    ' triangle indicates the desired ball position.      '
%    ' You can choose either human or fuzzy control to    '
%    ' control this system. If it is controlled by human, '
%    ' click the steering arrow at the upper right corner '
%    ' to change the tilted angle of the hitting board.   ' 
%    ' If it is controlled by fuzzy controller, use mouse '
%    ' to change the location of the triangle. (If fuzzy  '
%    ' controller is selected, the position of the small  '
%    ' triangle will also be updated randomly every       '
%    ' 200 step counts.)                                  '
%    '                                                    '
%    ' File: juggler.m                                    '];
%   fhelpfun(title, content);
elseif strcmp(action, 'close'),
    if JugAnimRunning == 1,
        JugAnimClose = 1;   % close via main_loop
    else    % close when animation is stopped or paused
        ud = get(JugFigH, 'userdata');
        delete(JugFigH);
    end
% ###### additional UI controls
elseif strcmp(action, 'show_trail'),
    ud = get(JugFigH, 'userdata');
    showTrailH = ud(2, 2);
    objectH = ud(3, 1:4);
    dispmode = get(showTrailH, 'value');
    if dispmode == 0,   % xor
        set(objectH, 'erasemode', 'xor');
       % set(JugFigH, 'color', get(JugFigH, 'color'));
	refresh(JugFigH);
    else
        set(objectH, 'erasemode', 'none');
    end
elseif strcmp(action, 'clear_trail'),
   refresh(JugFigH);
   % set(JugFigH, 'color', get(JugFigH, 'color'));

else
    fprintf('Action string = %s\n', action);
    error('Unknown action string!');
end
