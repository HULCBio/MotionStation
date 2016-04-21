function [sys, x0] = animtbu(t, x, u, flag, action)
%ANIMTBU Animation of TBU (truck backer-upper) system.
%   This is animation of the truck backer-upper (TBU) system. By clicking 
%   at the "Controller:" pop-up menu, you can choose to control this
%   system by yourself or by a fuzzy controller. If it is controlled by
%   human, click at the steering handle at the lower right corner to
%   change the steering angle of the truck's front wheels.
%
%   The controller used here actually contains two state feedback
%   controllers (implemented as MATLAB function blocks); these two state
%   feedback controllers operate on two different sets of state variables.
%   The fuzzy controller is then used as a blender to combined these two
%   controllers smoothly based on the distance between the truck and the
%   loading duck.
%
%   The simulation stops whenever the truck hits the back wall. Move the
%   truck by clicking inside the truck, or rotate it by  clicking at one
%   of its corners.
%
%   Animation S-function: animtbu.m
%   SIMULINK file: sltbu.m

%   Roger Jang, 10-21-93, 1-16-94, 11-13-94
%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.13.2.3 $  $Date: 2004/04/10 23:15:16 $

%   User data convention:
%   userdata = get(AnimTbuFigH, 'userdata');
%   userdata(1, :) --> handles for standard SL gui control 
%   userdata(2, :) --> handles for additional gui control 
%   userdata(3, :) --> handles for animation objects

global TbuInitCond TbuSlStatus TbuSteerAngle
global TbuTruck truck_l TbuSteerCenter
global TbuOriDispMode TbuCurrPt
global AnimTbuFigH AnimTbuFigTitle AnimTbuAxisH
global AnimTbuTranslate AnimTbuRotate

if ~isempty(flag) & flag == 3, % return the output value
   sys = TbuSteerAngle;
   x0=[];
elseif ~isempty(flag) & flag == 2,
   if any(get(0, 'children') == AnimTbuFigH),
      if strcmp(get(AnimTbuFigH, 'Name'), AnimTbuFigTitle),
         xPos = u(1); yPos = u(2); phi = u(3);
         if length(u)==4, theta = u(4); else theta = 0; end
         curr_pos = xPos + j*yPos;
         tmp = get(AnimTbuFigH, 'UserData');
         objectH = tmp(3, :);
         % ====== update ball
         truckH = objectH(1);
         %TbuTruck = get(truckH, 'userdata');
         truck_l = 2*abs(real(TbuTruck(1)));
         truck_w = 2*abs(imag(TbuTruck(1)));
         new_truck = (TbuTruck + truck_l/2)*exp(j*phi) + curr_pos;
         set(truckH, 'XData', real(new_truck), 'YData', imag(new_truck));
         % ====== front wheels
         wheelH = objectH(4);
         wheel = get(wheelH, 'userdata');
         wheel_l = 2*abs(real(wheel(1)));
         wheel_w = 2*abs(imag(wheel(1)));
         f_wheelsH = objectH(2);
         displace = (truck_l - wheel_l)/2 + j*truck_w/2;
         seperator = nan + j*nan; 
         rotated_wheel = wheel*exp(j*theta); 
         wheel1 = displace + rotated_wheel;
         wheel2 = conj(displace) + rotated_wheel;
         f_wheels = [wheel1; seperator; wheel2]; % rotated front wheels 
         new_f_wheels = (f_wheels + truck_l/2)*exp(j*phi) + curr_pos;
         set(f_wheelsH, 'XData', real(new_f_wheels), 'YData',imag(new_f_wheels));
         % ====== rear wheels
         r_wheelsH = objectH(3);
         wheel3 = -conj(displace) + wheel;
         wheel4 = -displace + wheel;
         r_wheels = [wheel3; seperator; wheel4]; % rear wheels 
         new_r_wheels = (r_wheels + truck_l/2)*exp(j*phi) + curr_pos;
         set(r_wheelsH, 'XData', real(new_r_wheels), 'YData',imag(new_r_wheels));
         % ====== update handle
         stickH = objectH(5);
         stick = get(stickH, 'userdata');
         who_drive = get_param('sltbu/Constant', 'value');
         if str2double(who_drive) > 0, % not human controller
            new_stick = stick*exp(j*theta) + TbuSteerCenter;
            set(stickH, 'xdata', real(new_stick), 'ydata', imag(new_stick));
         end
         % ====== update time 
         tmp = get(AnimTbuFigH, 'userdata');
         timeH = tmp(1, 6);
         set(timeH, 'String', ['Time: ', sprintf('%.2f', t)]);
         % ====== update headlight
         %displace = truck_l + j*truck_w/4;
         %new_headlight1 = (headlight + displace)*exp(j*phi) + curr_pos;
         %new_headlight2 = (headlight + conj(displace))*exp(j*phi) + curr_pos;
         %set(headlight1H, 'xdata', real(new_headlight1), ...
         %   'ydata', imag(new_headlight1));
         %set(headlight2H, 'xdata', real(new_headlight2), ...
         %   'ydata', imag(new_headlight2));
      end
   end
   % ====== return nothing
   sys = [];
   x0=[];
elseif ~isempty(flag) & flag == 9,   % When simulation stops ...
   % ====== change labels of standard UI controls
   if any(get(0, 'children') == AnimTbuFigH),
      if strcmp(get(AnimTbuFigH, 'Name'), AnimTbuFigTitle),
         tmp = get(AnimTbuFigH, 'userdata');
         set(tmp(1, 1), 'visible', 'on');    % start
         set(tmp(1, 2:5), 'visible', 'off');
         TbuInitCond = u(1:3);
         disp('Use mouse to move the truck to a new position.');
      end
   end
elseif ~isempty(flag) & flag == 0,
   % ====== find animation block & figure
   [winName] = bdroot(gcs);
   AnimTbuFigTitle = [winName, ': Truck Backer-Upper Animation'];
   AnimTbuFigH = findobj(0,'Name',AnimTbuFigTitle);
   % ====== % No figure, initialize everything
   if isempty(AnimTbuFigH),
      % ====== set some initial values
      TbuSteerAngle = 0;
      % ====== No. of UI rows
      ui_row_n = 2;
      % ###### default UI settings for SIMUINK ######
      AnimTbuFigH = figure( ...
         'Name', AnimTbuFigTitle, ...
         'NumberTitle', 'off', ...
         'DockControls', 'off');
      figPos = get(AnimTbuFigH, 'position');
      % ====== proportion of UI frame and axes
      ui_area = 0.2;
      axis_area = 1-ui_area;
      % ====== animation area 
      axisPos = [0 figPos(4)*ui_area figPos(3) figPos(4)*axis_area];
      % weird thing: if you don't use normalized unit for
      % axes, patch for ground doesn't appear
      axisPos = axisPos./[figPos(3) figPos(4) figPos(3) figPos(4)];
      
      AnimTbuAxisH = ...
         axes('unit', 'normal', 'pos', axisPos-[0 .5 0 -.5], 'visible', 'on');
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
      set(AnimTbuFigH, 'userdata', tmp);
      
      % ###### additional UI settings ######
      % ====== The upper UI controls (Specific to each animation)
      cb1 = [mfilename '([], [], [], [], ''show_trail'')'];
      cb2 = [mfilename '([], [], [], [], ''clear_trail'')'];
      cb3 = '';
      cb4 = [mfilename '([], [], [], [], ''controller'')'];
      
      string1 = 'Show Trails';
      string2 = 'Clear Trails';
      string3 = 'Controller:';
      string4 = 'Human|Fuzzy';
      
      [upH, upPos] = uiarray(Pos(1,:), 1, 4, spacing, 2*spacing, ...
         str2mat('check', 'push', 'text', 'popup'), ...
         str2mat(cb1, cb2, cb3, cb4), ...
         str2mat(string1, string2, string3, string4));
      set(upH(3), 'HorizontalAlignment', 'right');
      dispmodeH = upH(1);
      controllerH = upH(4);
      % ====== Appending handles as the second row of userdata
      tmp = [dispmodeH controllerH -1 -1 -1 -1 -1 -1 -1 -1];
      set(AnimTbuFigH, 'userdata', [get(AnimTbuFigH, 'userdata'); tmp]);
      
      % ###### animation objects ######
      % ====== truck body
      truck_l = 4;    % This is defined in tbuinit.m
      truck_w = 2;
      TbuTruck = truck_l/2*[-1 1 1 -1 -1]' + ...
         sqrt(-1)*truck_w/2*[-1 -1 1 1 -1]';
      truckH = line(real(TbuTruck), imag(TbuTruck));
      set(truckH, 'erase', 'xor', 'userdata', TbuTruck);
      % ====== wheel
      wheel_l = 1.2; wheel_w = 0.2;
      wheel = wheel_l/2*[-1 1 1 -1 -1]' + ...
         sqrt(-1)*wheel_w/2*[-1 -1 1 1 -1]';
      wheelH = line(real(wheel), imag(wheel), 'visible', 'off');
      set(wheelH, 'userdata', wheel, 'erase', 'xor');
      % ====== headlights (not display here)
      %M = [linspace(0,1,64)' linspace(0,1,64)' zeros(64,1)];
      %colormap(M);
      %headlight = [0 truck_l/2 truck_l/2 0]' + ...
      %   j*[-truck_w/16 -truck_w/4 truck_w/4 truck_w/16]';
      %headlight1H=patch(real(headlight),imag(headlight),[64 1 1 64]);
      %headlight2H=patch(real(headlight),imag(headlight),[64 1 1 64]);
      %set(headlight1H, 'erasemode', 'xor');
      %set(headlight2H, 'erasemode', 'xor');
      % ====== steering handle
      % Plot steering handle 
      radius = 4;
      TbuSteerCenter = 20 + j*5;
      circle = radius*[exp(j*linspace(0, 2*pi)) 1]+TbuSteerCenter;
      circleH = line(real(circle), imag(circle), ...
         'color', 'red', 'linewidth', 3, 'erase', 'xor');
      
      stick = radius* ...
         [[0 j] nan ...
            [exp(-j*pi/4) 0 exp(-j*pi*3/4)]*0.2+j nan ...
            [0 j]*exp(j*2*pi/3) nan [0 j]*exp(j*4*pi/3)];
      stickH = line(real(stick+TbuSteerCenter), imag(stick+TbuSteerCenter), ...
         'color', 'red', 'linewidth', 2, 'erase', 'xor');
      set(stickH, 'userdata', stick);
      
      delta = ([0 1 -1 0] + j*[0 sqrt(3) sqrt(3) 0])*0.6;
      l_delta = (delta + j*1.1*radius)*exp(j*pi/4) + TbuSteerCenter;
      r_delta = (delta + j*1.1*radius)*exp(-j*pi/4) + TbuSteerCenter;
      delta1H = patch(real(l_delta), imag(l_delta), 'g');
      delta2H = patch(real(r_delta), imag(r_delta), 'g');
      set(delta1H, 'erase', 'xor');
      set(delta2H, 'erase', 'xor');
      % ====== axis settings
      max_x = 25; max_y = 30;
      set(AnimTbuAxisH, 'clim', [1 64], ...
         'xlim', [-max_x max_x], ...
         'ylim', [-1 max_y], ...
         'box', 'on');
      axis equal;
      %       set(AnimTbuAxisH, 'visible', 'off');
      % ====== plot back wall and dock
      x = [-max_x-5 -truck_w*0.8 0 truck_w*0.8 max_x+5];
      y = [0 0 nan 0 0];
      line(x, y, 'linewidth', 2, 'color', 'b');
      line([-truck_w -truck_w truck_w truck_w]*0.8, ...
         [1 -0.5 -0.5 1], 'linewidth', 3, 'color', 'black');
      grid on;
      set(AnimTbuFigH, 'color', get(AnimTbuFigH, 'color'));
      % ====== append the handles as third row of userdata
      f_wheelsH = line(0, 0, 'erase', 'xor', 'color', 'm');
      r_wheelsH = line(0, 0, 'erase', 'xor', 'color', 'c');
      tmp = [truckH f_wheelsH r_wheelsH wheelH stickH ...
            circleH delta1H delta2H -1 -1];
      set(AnimTbuFigH, 'userdata', [get(AnimTbuFigH, 'userdata'); tmp]);
      % ====== set up initial options
      constant_block = [winName, '/Constant'];
      if str2double(get_param(constant_block, 'value')) < 0,
         set(tmp(5:8), 'visible', 'on');
         set(controllerH, 'value', 1);
      else
         set(tmp(5:8), 'visible', 'off');    %fuzzy
         set(controllerH, 'value', 2);
      end
      % ====== change to normalized units
      set(findobj(AnimTbuFigH,'Units','pixels'), 'Units','normalized');
      % ====== mouse actions
      % action when button is first pushed down
      action1 = [mfilename, '([], [], [], [], ''mouse_action1'')'];
      % actions after the mouse is pushed down
      action2 = [mfilename, '([], [], [], [], ''mouse_action2'')'];
      % action when button is released
      action3 = [mfilename, '([], [], [], [], ''mouse_action3'')'];
      
      % temporary storage for the recall in the down_action
      set(AnimTbuAxisH,'UserData',action2);
      
      % set action when the mouse is pushed down
      down_action=[ ...
            'set(AnimTbuFigH,''WindowButtonMotionFcn'',get(AnimTbuAxisH,''UserData''));' ...
            action1];
      set(AnimTbuFigH,'WindowButtonDownFcn',down_action);
      
      % set action when the mouse is released
      up_action=[ ...
            'set(AnimTbuFigH,''WindowButtonMotionFcn'','' '');', action3];
      set(AnimTbuFigH,'WindowButtonUpFcn',up_action);
   end
   % ====== change labels of standard UI controls
   tmp = get(AnimTbuFigH, 'userdata');
   set(tmp(1, 1), 'visible', 'off');
   set(tmp(1, 2:3), 'visible', 'on');
   refresh(AnimTbuFigH);
   sys = [0 0 1 4 0 0];
   x0=[];
   set(AnimTbuFigH, 'HandleVisibility', 'on');
elseif nargin == 5, % for callbacks of GUI
   % ###### standard UI controls
   if strcmp(action, 'start_sl'),
      tmp = get(AnimTbuFigH, 'userdata');
      set(tmp(1, 1), 'visible', 'off');
      set(tmp(1, 2:3), 'visible', 'on');
      [winName] = bdroot(gcs);
      set_param(winName, 'SimulationCommand', 'start');
   elseif strcmp(action, 'stop_sl'),
      tmp = get(AnimTbuFigH, 'userdata');
      set(tmp(1, 1), 'visible', 'on');
      set(tmp(1, 2:5), 'visible', 'off');
      [winName] = bdroot(gcs);
      set_param(winName, 'SimulationCommand', 'stop');
   elseif strcmp(action, 'pause_sl'),
      tmp = get(AnimTbuFigH, 'userdata');
      set(tmp(1, 3), 'visible', 'off');
      set(tmp(1, 4:5), 'visible', 'on');
      [winName] = bdroot(gcs);
      set_param(winName, 'SimulationCommand', 'pause');
   elseif strcmp(action, 'step_sl'),
      [winName] = bdroot(gcs);
      set_param(winName, 'SimulationCommand', 'step');
   elseif strcmp(action, 'continue_sl'),
      tmp = get(AnimTbuFigH, 'userdata');
      set(tmp(1, 3), 'visible', 'on');
      set(tmp(1, 4:5), 'visible', 'off');
      [winName] = bdroot(gcs);
      set_param(winName, 'SimulationCommand', 'continue');
   elseif strcmp(action, 'info'),
      helpwin(mfilename);
      %   title = get(AnimTbuFigH, 'Name');
      %   content = ...
      %   ['                                                    '
      %    ' Animation of the truck backer-upper (TBU)          '
      %    ' system. By clicking at the "Controller:"           '
      %    ' pop-up menu, you can choose to control this        '
      %    ' system by yourself or by a fuzzy controller.       '
      %    ' If it is controlled by human, click at the         '
      %    ' steering handle at the lower right corner          '
      %    ' to change the steering angle of the truck.         '
      %    '                                                    '
      %    ' The simulation stops whenever the truck hits       '
      %    ' the back wall. Move the truck by clicking          '
      %    ' inside the truck, or rotate it by  clicking        '
      %    ' at one of its corners.                             '
      %    '                                                    '
      %    ' Animation S-function: animtbu.m                    '
      %    ' SIMULINK file: sltbu.m                             '];
      %   fhelpfun(title, content);
   elseif strcmp(action, 'close'),
      %       [winName, sysName] = get_param;
      %       set_param(winName, 'Simulation running', 'stop');
      delete(AnimTbuFigH);
      
      % ###### additional UI controls
   elseif strcmp(action, 'controller'),
      tmp = get(AnimTbuFigH, 'userdata');
      controllerH = tmp(2, 2);
      value = get(controllerH, 'value');
      [winName] = bdroot(gcs);
      constant_block = [winName, '/Constant'];
      if value == 1,  % human controller
         set_param(constant_block, 'value', '-1');
         set(tmp(3, 5:8), 'visible', 'on');
      else        % fuzzy controller
         set_param(constant_block, 'value', '1');
         set(tmp(3, 5:8), 'visible', 'off');
      end
   elseif strcmp(action, 'show_trail'),
      tmp = get(AnimTbuFigH, 'userdata');
      dispmodeH = tmp(2, 1);
      objectH = tmp(3, 1:4);
      dispmode = get(dispmodeH, 'value');
      if dispmode == 0,   % xor
         set(objectH, 'erasemode', 'xor');
      else
         set(objectH, 'erasemode', 'none');
      end
   elseif strcmp(action, 'clear_trail'),
      refresh(AnimTbuFigH);
      %        set(AnimTbuFigH, 'color', get(AnimTbuFigH, 'color'));
   elseif strcmp(action, 'mouse_action1')
      TbuSlStatus = get_param('sltbu', 'simulationStatus');
      tmp = get(AnimTbuFigH, 'userdata');
      objectH = tmp(3, 1:4);
      curr_info = get(AnimTbuAxisH, 'CurrentPoint');
      TbuCurrPt = curr_info(1,1) + j*curr_info(1,2);
      if strcmp(TbuSlStatus, 'stopped'),
         now_truck = (TbuTruck+truck_l/2)*exp(j*TbuInitCond(3)) + ...
            TbuInitCond(1) + j*TbuInitCond(2);
         if (inside(TbuCurrPt, now_truck))
            AnimTbuTranslate = 1;
            set(AnimTbuFigH,'pointer', 'crosshair');
         elseif (~isempty(find(objectH == gco)))
            AnimTbuRotate = 1;
            set(AnimTbuFigH,'pointer', 'circle');
         end
         TbuOriDispMode = get(objectH(1), 'erasemode');
         set(objectH, 'erasemode', 'xor');
      else
         stickH = tmp(3, 5); 
         stick = get(stickH, 'userdata');
         theta = angle(-j*(TbuCurrPt - TbuSteerCenter));
         theta = min(max(theta, -pi/4), pi/4);
         new_stick = stick*exp(j*theta) + TbuSteerCenter;
         set(stickH, 'xdata', real(new_stick));
         set(stickH, 'ydata', imag(new_stick));
         TbuSteerAngle = theta;  
      end
   elseif strcmp(action, 'mouse_action2')
      if strcmp(TbuSlStatus, 'stopped'),
         prev_pt = TbuCurrPt;
         curr_info = get(AnimTbuAxisH, 'CurrentPoint');
         TbuCurrPt = curr_info(1,1) + j*curr_info(1,2);
         curr_xy = TbuInitCond(1) + j*TbuInitCond(2);
         phi = TbuInitCond(3);
         if AnimTbuRotate,   % rotation
            truck_center = truck_l/2*exp(j*phi) + curr_xy;
            angle1 = angle(prev_pt - truck_center);
            angle2 = angle(TbuCurrPt - truck_center);
            % rotate truck
            rot_angle = angle2 - angle1;
            next_xy = (curr_xy - truck_center)*exp(j*rot_angle) + truck_center;
            next_phi = phi + rot_angle;
            new_state = [real(next_xy) imag(next_xy) next_phi];
            TbuInitCond = new_state;
            eval([mfilename '(0, [], TbuInitCond, 2);']);
         elseif AnimTbuTranslate,    % translation
            displacement = TbuCurrPt - prev_pt;
            next_xy = curr_xy + displacement;
            new_state = [real(next_xy) imag(next_xy) phi];
            TbuInitCond = new_state;
            eval([mfilename '(0, [], TbuInitCond, 2);']);
         end;
      else
         curr_info = get(AnimTbuAxisH, 'CurrentPoint');
         TbuCurrPt = curr_info(1,1) + j*curr_info(1,2);
         theta = angle(-j*(TbuCurrPt - TbuSteerCenter));
         theta = min(max(theta, -pi/4), pi/4);
         TbuSlStatus = get_param('sltbu', 'simulationStatus');
         tmp = get(AnimTbuFigH, 'userdata');
         stickH = tmp(3, 5); 
         stick = get(stickH, 'userdata');
         new_stick = stick*exp(j*theta) + TbuSteerCenter;
         set(stickH, 'xdata', real(new_stick));
         set(stickH, 'ydata', imag(new_stick));
         TbuSteerAngle = theta;  
      end
   elseif strcmp(action, 'mouse_action3')
      if strcmp(TbuSlStatus, 'stopped'),
         tmp = get(AnimTbuFigH, 'userdata');
         objectH = tmp(3, 1:4);
         set(objectH, 'erasemode', TbuOriDispMode);
         set(AnimTbuFigH, 'pointer', 'arrow');
         AnimTbuTranslate = 0;
         AnimTbuRotate = 0;
      else
         curr_info = get(AnimTbuAxisH, 'CurrentPoint');
         TbuCurrPt = curr_info(1,1) + j*curr_info(1,2);
         theta = angle(-j*(TbuCurrPt - TbuSteerCenter));
         theta = min(max(theta, -pi/4), pi/4);
         tmp = get(AnimTbuFigH, 'userdata');
         stickH = tmp(3, 5); 
         stick = get(stickH, 'userdata');
         new_stick = stick*exp(j*theta) + TbuSteerCenter;
         set(stickH, 'xdata', real(new_stick));
         set(stickH, 'ydata', imag(new_stick));
         TbuSteerAngle = theta;  
      end
   else
      fprintf('Unknown action string: %s.\n', action);
   end
end
