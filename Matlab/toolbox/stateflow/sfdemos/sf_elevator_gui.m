function sf_elevator_gui(method, varargin)
% SF_ELEVATOR_GUI  Interface module to Stateflow Elevator Control Logic demo (sf_elevator.mdl)
%   Yao Ren October 2002
%
%   Copyright 1995-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 00:53:02 $

persistent fig hallBtns carABtns carBBtns inactiveColor activeColor carWidth carHeight floorHeight;
persistent carAX carBX carAPos carBPos carA carAdoor carB carBdoor carAaxes carBaxes;
persistent fireBtnA fireBtnB activeFireColor inactiveFireColor fireStatus;

if isempty(fig) || ~ishandle(fig)
    switch method
    case 'init'
        % go through
    case 'close'
        % Already closed. Do nothing.
        return;
    otherwise
        % Figure closed. Stop simulation
        set_param('sf_elevator', 'SimulationCommand', 'Stop');
        return;
    end
end

switch method
case 'init'
    % Initialize the elevator demo GUI figure
    fig = figure('Name','Statelfow Elevators', 'DoubleBuffer', 'on'); 
    oldUnits = get(fig,'Units');
    set(fig,'Units','normalized');
    ratioXY = 200/700;
    height = 0.80;
    width = ratioXY * height;
    left = (1 - width) / 2;
    top = (1 - height)/ 2;
    set(fig,'Position',[left top width height]);
    set(fig,'Units',oldUnits);
    
    % The axes to layout floor levels
    axeFloor = axes('Color','w', ...
                    'XLim',[1 200], ...
                    'YLim',[1 700], ...
                    'DataAspectRatio',[1 1 1], ...
                    'XTick',[], ...
                    'YTick',[], ...
                    'Position',[0 1/8 1 7/8]);
                
    % The axes to layout elevator internal view
    axeCars = axes('Color','k', ...
                   'XLim',[1 200], ...
                   'YLim',[1 100], ...
                   'DataAspectRatio',[1 1 1], ...
                   'XTick',[], ...
                   'YTick',[], ...
                   'Position',[0 0 1 1/8]);
    
    numFloor = 9;
    hallBtns = zeros(numFloor, 1);
    carABtns = zeros(numFloor, 1);
    carBBtns = zeros(numFloor, 1);
    inactiveColor = 'w';
    activeColor = 'c';
    activeFireColor = [1 0.3 0];
    inactiveFireColor = [0.6 0 0];
    fireStatus = 0;
    floorHeight = 700/numFloor;
    btnSize = 8;
    signSize = 10;
    
    % Draw each floor level, the floor number sign, and the elevator request button
    for f = 1:numFloor
        floorBaseY = floorHeight*(f-1);
        btnPosX = 200/2-btnSize/2;
        btnPosY = floorBaseY + floorHeight/4;
        signPosX = btnPosX;
        signPosY = floorBaseY + 5*floorHeight/8;
        
        % Elevator request buttons
        hallBtns(f) = rectangle('Parent',axeFloor, ...
                                'Position',[btnPosX btnPosY btnSize btnSize], ...
                                'FaceColor','w', ...
                                'ButtonDownFcn',['sf_elevator_gui(''activate'', ''hall'', ' num2str(f) ');']);
                            
        % Floor number signs
        text('Parent',axeFloor, ...
             'Position',[signPosX signPosY], ...
             'String',num2str(f), ...
             'BackgroundColor','k', ...
             'Color','w', ...
             'FontName','FixedWidth', ...
             'FontSize',signSize, ...
             'FontWeight','bold');
         
        % Floor levels
        line([1 200],[floorBaseY floorBaseY],'Parent',axeFloor);
    end

    % Draw elevator A and B and their doors
    carWidth = 60;
    carHeight = floorHeight*3/4;
    carAaxes = 200/4;
    carBaxes = 200*3/4;
    carAX = carAaxes-carWidth/2;
    carBX = carBaxes-carWidth/2;
    carAPos = 0;
    carBPos = 0;
    
    carA = rectangle('Parent',axeFloor, ...
                     'Position',[carAaxes-carWidth/2 carAPos carWidth carHeight], ...
                     'FaceColor','g', ...
                     'LineWidth',1, ...
                     'EdgeColor','k');
                 
    carAdoor = rectangle('parent',axeFloor, ...
                         'Position',[carAaxes carAPos 1 carHeight], ...
                         'FaceColor','y', ...
                         'LineWidth',1, ...
                         'EdgeColor','k');
                     
    carB = rectangle('Parent',axeFloor, ...
                     'Position',[carBaxes-carWidth/2 carBPos carWidth carHeight], ...
                     'FaceColor','g', ...
                     'LineWidth',1, ...
                     'EdgeColor','k');
                 
    carBdoor = rectangle('parent',axeFloor, ...
                         'Position',[carBaxes carBPos 1 carHeight], ...
                         'FaceColor','y', ...
                         'LineWidth',1, ...
                         'EdgeColor','k');

    % Draw elevator internal views
    carInternalViewWidth = 80;
    carInternalViewHeight = 90;
    
    rectangle('Parent',axeCars, ...
              'Position',[carAaxes-carInternalViewWidth/2 5 carInternalViewWidth carInternalViewHeight], ...
              'FaceColor','y', ...
              'LineWidth',1);
          
    rectangle('Parent',axeCars, ...
              'Position',[carBaxes-carInternalViewWidth/2 5 carInternalViewWidth carInternalViewHeight], ...
              'FaceColor','y', ...
              'LineWidth',1);
    
    % Draw floor request buttons and fire alarm buttons inside elevator internal views
    btnSize = 14;
    baseX = carAaxes-carInternalViewWidth/2;
    baseY = 5;
    
    for f = 1:9
        btnX = mod(f-1,3)*btnSize+baseX+5;
        btnY = floor((9-f)/3)*btnSize+baseY+5;
        
        % Floor request buttons for elevator A
        carABtns(f) = text('Parent',axeCars, ...
                           'Position',[btnX btnY], ...
                           'String',num2str(f), ...
                           'BackgroundColor','w', ...
                           'Color','k', ...
                           'FontName','FixedWidth', ...
                           'FontSize',btnSize-4, ...
                           'FontWeight','bold', ...
                           'VerticalAlignment','bottom', ...
                           'EdgeColor','k', ...
                           'ButtonDownFcn',['sf_elevator_gui(''activate'', ''carA'', ' num2str(f) ');']);
    end
    
    % Fire alarm button for elevator A
    fireBtnA = text('Parent',axeCars, ...
                    'Position',[carAaxes+carInternalViewWidth/2-5 30], ...
                    'String','FIRE', ...
                    'BackgroundColor',inactiveFireColor, ...
                    'Color','w', ...
                    'FontSize',8, ...
                    'VerticalAlignment','bottom', ...
                    'HorizontalAlignment','right', ...
                    'EdgeColor','k', ...
                    'ButtonDownFcn','sf_elevator_gui activate fire;');
                
    text('Parent',axeCars, ...
         'Position',[carAaxes 88], ...
         'String','Car A', ...
         'BackgroundColor','y', ...
         'Color','k', ...
         'FontSize',10, ...
         'VerticalAlignment','top', ...
         'HorizontalAlignment','center', ...
         'FontWeight','bold');
    
    baseX = carBaxes-carInternalViewWidth/2;
    for f = 1:9
        btnX = mod(f-1,3)*btnSize+baseX+5;
        btnY = floor((9-f)/3)*btnSize+baseY+5;
        
        % Floor request buttons for elevator B
        carBBtns(f) = text('Parent',axeCars, ...
                           'Position',[btnX btnY], ...
                           'String',num2str(f), ...
                           'BackgroundColor','w', ...
                           'Color','k', ...
                           'FontName','FixedWidth', ...
                           'FontSize',btnSize-4, ...
                           'FontWeight','bold', ...
                           'VerticalAlignment','bottom', ...
                           'EdgeColor','k', ...
                           'ButtonDownFcn',['sf_elevator_gui(''activate'', ''carB'', ' num2str(f) ');']);
    end
    
    % Fire alarm button for elevator B
    fireBtnB = text('Parent',axeCars, ...
                    'Position',[carBaxes+carInternalViewWidth/2-5 30], ...
                    'String','FIRE', ...
                    'BackgroundColor',inactiveFireColor, ...
                    'Color','w', ...
                    'FontSize',8, ...
                    'VerticalAlignment','bottom', ...
                    'HorizontalAlignment','right', ...
                    'EdgeColor','k', ...
                    'ButtonDownFcn','sf_elevator_gui activate fire;');
                
    text('Parent',axeCars, ...
         'Position',[carBaxes 88], ...
         'String','Car B', ...
         'BackgroundColor','y', ...
         'Color','k', ...
         'FontSize',10, ...
         'VerticalAlignment','top', ...
         'HorizontalAlignment','center', ...
         'FontWeight','bold');
     
case 'deactivate'
    % Deactivate a button by set its color to inactive color
    switch varargin{1}
    case 'hall'
        btn = hallBtns(varargin{2});
        set(btn, 'FaceColor', inactiveColor);
    case 'carA'
        btn = carABtns(varargin{2});
        set(btn, 'BackgroundColor', inactiveColor);
    case 'carB'
        btn = carBBtns(varargin{2});
        set(btn, 'BackgroundColor', inactiveColor);
    case 'fire'
        set(fireBtnA, 'BackgroundColor', inactiveFireColor);
        set(fireBtnB, 'BackgroundColor', inactiveFireColor);
        fireStatus = 0;
        
        % Turn off fire alarm in simulink model
        set_param('sf_elevator/Fire Alarm', 'value', '0');
    end
    
case 'activate'
    % When button get pressed, set its color to active color,
    % and send the signal to simulink model.
    switch varargin{1}
    case 'hall'
        btn = hallBtns(varargin{2});
        set(btn, 'FaceColor', activeColor);
        set_param('sf_elevator/Hall Call Floor', 'value', num2str(varargin{2}));
        triggerMode = get_param('sf_elevator/Hall Call', 'value');
        set_param('sf_elevator/Hall Call', 'value', num2str(~str2num(triggerMode)));
    case 'carA'
        btn = carABtns(varargin{2});
        set(btn, 'BackgroundColor', activeColor);
        set_param('sf_elevator/Car Call A Floor', 'value', num2str(varargin{2}));
        triggerMode = get_param('sf_elevator/Car Call A', 'value');
        set_param('sf_elevator/Car Call A', 'value', num2str(~str2num(triggerMode)));
    case 'carB'
        btn = carBBtns(varargin{2});
        set(btn, 'BackgroundColor', activeColor);
        set_param('sf_elevator/Car Call B Floor', 'value', num2str(varargin{2}));
        triggerMode = get_param('sf_elevator/Car Call B', 'value');
        set_param('sf_elevator/Car Call B', 'value', num2str(~str2num(triggerMode)));
    case 'fire'
        % 'FIRE' alarm buttons are toggle buttons.
        if ~fireStatus
            set(fireBtnA, 'BackgroundColor', activeFireColor);
            set(fireBtnB, 'BackgroundColor', activeFireColor);
            fireStatus = 1;
            set_param('sf_elevator/Fire Alarm', 'value', '1');
        else
            sf_elevator_gui('deactivate', 'fire');
        end
    end
    
case 'move_car'
    % Animation is realized by painting the elevators at new position when
    % they are moving.
    newPos = ceil((varargin{2}-1) * floorHeight);
    switch varargin{1}
    case 'carA'
        if newPos ~= carAPos
            carAPos = newPos;
            set(carA, 'Position', [carAX carAPos carWidth carHeight]);
            set(carAdoor, 'Position', [carAaxes carAPos 1 carHeight]);
        end
    case 'carB'
        if newPos ~= carBPos
            carBPos = newPos;
            set(carB, 'Position', [carBX carBPos carWidth carHeight]);
            set(carBdoor, 'Position', [carBaxes carBPos 1 carHeight]);
        end
    end
    
case 'open_door'
    % Animate opening elevator doors
    doorWidth = carWidth/2-10;
    switch varargin{1}
    case 'carA'
        set(carAdoor, 'Position', [carAaxes-doorWidth carAPos doorWidth*2 carHeight]);
    case 'carB'
        set(carBdoor, 'Position', [carBaxes-doorWidth carBPos doorWidth*2 carHeight]);
    end
    
 case 'close_door'
     % Animate closing elevator doors
    switch varargin{1}
    case 'carA'
        set(carAdoor, 'Position', [carAaxes carAPos 1 carHeight]);
    case 'carB'
        set(carBdoor, 'Position', [carBaxes carBPos 1 carHeight]);
    end
    
case 'close'
    % Close UI figure when simulation is stopped
    if(~isempty(fig) & ishandle(fig))
        close(fig);
    end
end
