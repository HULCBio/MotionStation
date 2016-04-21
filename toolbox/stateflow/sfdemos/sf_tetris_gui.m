function r = sf_tetris_gui(operation, varargin)

persistent axis fig img data gameoverTxt;

r=[];

switch operation
case 'init',
   
    data = zeros(varargin{1},varargin{2});
    
    if ishandle(img)
        set(img,'CData',data);
    else
        fig = figure('Name','Tetris', ...
            'KeyPressFcn', 'sf_tetris_gui keypress;', ...
            'DoubleBuffer', 'on'); 
        
        oldUnits = get(fig,'Units');
        
        set(fig,'Units','normalized');
        ratioXY = double(varargin{2})/double(varargin{1});
        
        height = 0.75;
        width = ratioXY * height;
        left = (1 - width) / 2;
        top = (1 - height)/ 2;
        set(fig,'Position',[left top width height]);
        set(fig,'Units',oldUnits);
        
        img = image(data);

        axis = get(img,'Parent');
        
        titleText = get(axis,'Title');
        set(titleText,'fontWeight','bold');
        
        set(axis,'DataAspectRatio',[1 1 1],...
            'XTick',[],'YTick',[]);        
    end
    
    if ~isempty(gameoverTxt) && ishandle(gameoverTxt)
        set(gameoverTxt,'Visible','off');
    end
case 'gameover',
    if ishandle(img)
        pos = get(axis,'Position');
        if isempty(gameoverTxt) || ~ishandle(gameoverTxt)
            gameoverTxt = text('Visible','off', ...
                'String','Game Over!',...
                'fontweight','bold',...
                'fontsize',20, ...
                'units','normalized', ...
                'color','red');
        end
        tpos = get(gameoverTxt,'Extent');
        set(gameoverTxt,'Position',[(pos(1) + (pos(3) - tpos(3))/2), ...
                (pos(2) + (pos(4) - tpos(4))/2)]);
            
        set(gameoverTxt,'Visible','on');
    else
       error('Figure closed. Aborting.');
    end
case 'set',
    data(varargin{1},varargin{2}) = varargin{3};
case 'paint',  
    if ishandle(img)
        switch mod(varargin{1},3) 
            case 0, colorMap = jet;
            case 1, colorMap = hot;
            case 2, colorMap = pink;
        end
                
        set(fig,'colormap',colorMap);
        titleText = get(axis,'Title');
        titleString = sprintf('Level %2d Score %10d',double(varargin{1}),double(varargin{2}));
        set(titleText,'String',titleString);
        set(img,'Cdata',data);
    else
        error('Figure has been closed aborting.');
    end
case 'keypress',
    
    if ~ishandle(fig)
        error('Figure closed. Aborting.');
    else
        ch = get(fig,'CurrentChar');
        triggerBlock = '';
        switch ch
            case 'j',
                triggerBlock = 'Left';
            case 'l',
                triggerBlock = 'Right';
            case 'k',
                triggerBlock = 'RotLeft';
            case 'i',
                triggerBlock = 'RotRight';
            case 'p',
                triggerBlock = 'Pause';
            case 'q',
                triggerBlock = 'Quit';
            case 'r',
                triggerBlock = 'Restart';
            case ' ',
                triggerBlock = 'Drop';
        end
        
        if ~isequal(triggerBlock,'')
            nm = ['sf_tetris/' triggerBlock];
            triggerMode = get_param(nm,'value');
            if strcmp(triggerMode,'1')
                triggerMode = '0';
            else
                triggerMode = '1';
            end
            set_param(nm,'value',triggerMode);    
        end
    end
end

% Copyright 2002-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/15 00:53:08 $
