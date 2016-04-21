function res = sf_edit_icon (varargin)
% SF_EDIT_ICON  Interface module to Stateflow Icon Editor  (sfediticon.mdl)
%


%
%   Tom Walsh August 2000
%
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.8.2.1 $  $Date: 2004/04/15 00:53:01 $



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  EVENT HANDLING
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%----------------------------------------------------------------------------------------
% This public function is for handling events broadcast by
% or into Stateflow.
%
% There are three ways of calling this function
% 
% sf_edit_icon(commmand)
%  Acts on specified command
%  See notes under broadcast_l for possible commands
%
% sf_edit_icon ('status', message)
%  Puts the message string in the status bar
% 
% sf_edit_icon ('press', shouldPress, tool)
%  if shouldPress is true, depresses the given tool
%  otherwise, the tool is undepressed
%  tool can be 'pencil', 'line', 'open', etc.

switch nargin,
    case 0,
        %error
        bad_args_l;
    
    case 1,
        cmd = varargin{1};
        res = broadcast_l(cmd);
    case 2,
        cmd = varargin{1};
        mod = varargin{2};
        switch (cmd)
            case 'status',
                status_l(mod);
            otherwise,
                bad_args_l;
        end
    case 3,
        cmd = varargin{1};
        shouldPress = varargin{2};
        tool = varargin{3};
        
        switch (cmd),    
            case 'press',
                if (shouldPress)
                    depress_button_l(tool);
                else
                    undepress_button_l(tool);
                end
            
            otherwise,
                bad_args_l;
        end
    
    
    
    otherwise,
        bad_args_l;
          
end;



%----------------------------------------------------------------------------------------
function res = broadcast_l (cmd)
% This function handles any events received from outside
% (also from inside in the case of "button down" events)
% This is just a big switch statement that decides what to
% do for each event
    res = '';
    switch cmd,


        % Commands to check mouse focus    
        case 'over_icon',
            res = mouse_in_region_l ('icon');
        case 'over_palette',
            res = mouse_in_region_l ('palette');
        case 'over_canvas', 
            res = mouse_in_region_l ('canvas');
        case 'over_color_swatch'
            res = mouse_in_region_l ('swatches');            
        case 'over_toolbar', 
            res = mouse_in_region_l('toolbar');
        case 'over_pencil_tool',
            res = mouse_in_region_l('pencil');
        case 'over_line_tool',
            res = mouse_in_region_l('line');
        case 'over_undo_tool',
            res = mouse_in_region_l('undo');
        case 'over_open_tool',
            res = mouse_in_region_l('open');
        case 'over_save_tool',
            res = mouse_in_region_l('save');
        case 'over_saveas_tool',
            res = mouse_in_region_l('save_as');
        case 'over_openmap_tool',
            res = mouse_in_region_l('open_map');
        case 'over_savemap_tool',
            res = mouse_in_region_l('save_map');
        case 'over_addcolor_tool',
            res = mouse_in_region_l('add_color');
                        

        % Initialization             
        case 'create',
            is_mex_l( logical(0));
            res = create_gui_l;
        case 'create_mex',
            is_mex_l( logical(1));
            res = create_gui_l;            
        case 'kill',
            kill_l;
            res = logical(1);
            
                        
        % If we get a "button down" event,
        % We throw another event that is more specific
        % (left button, right button, etc.)
        % and let Simulink/Stateflow take care of them
        case 'BD',
            gs = gs_get_l;
            bType = get (gs.figureHandle, 'SelectionType');
            switch (lower(bType))
                case 'normal',
                    sf_inject_event ('NBD');
                case 'alt',  %right
                    sf_inject_event ('ABD');

                % ignore (but don't fail) on other click events
                case 'extend', %shift
                case 'open',	 %double
                otherwise,
            end


        % Other mouse events are also sent to Simulink/Stateflow
        case 'BM',
            sf_inject_event ('BM');
        case 'BU',
            sf_inject_event ('BU');
            
            

        % Window-manager commands            
        case 'resize',
            locate_all_l;


        % Color related commands
        case 'fgcolor',
            new_color_l;
            res = logical(1);
        case 'cache_color',
            save_color_l;
            res = logical(1);
        case 'add_color',
            add_color_l;
        case 'show_color_menu',
            show_color_menu_l;
        case 'edit_color',
            edit_color_l;
        case 'delete_color',
            delete_color_l;
            

        % Toolbar control commands
        case 'press_line',
            depress_button_l('line');
        case 'unpress_line',
            undepress_button_l('line');
        case 'press_pencil',
            depress_button_l('pencil');
        case 'unpress_pencil',
            undepress_button_l('pencil');
        case 'press_undo',
            depress_button_l('undo');
        case 'unpress_undo',
            undepress_button_l('undo');
        case 'press_open',
            depress_button_l('open');
        case 'unpress_open',
            undepress_button_l('open');
        case 'press_save',
            depress_button_l('save');
        case 'unpress_save',
            undepress_button_l('save');
        case 'press_save_as',
            depress_button_l('save_as');
        case 'unpress_save_as',
            undepress_button_l('save_as');
        case 'press_open_map',
            depress_button_l('open_map');
        case 'unpress_open_map',
            undepress_button_l('open_map');
        case 'press_save_map',
            depress_button_l('save_map');
        case 'unpress_save_map',
            undepress_button_l('save_map');
        case 'press_addcolor',
            depress_button_l('add_color');
        case 'unpress_addcolor',
            undepress_button_l('add_color');
        
        
            
        % Editing commands
        case 'anchor_line',
            anchor_line_l;
        case 'render_line',
            render_line_l;
        case 'draw_point',
            draw_point_l;
        case 'undo',
            undo_l;
        case 'commit',
            commit_l;
            
        % File commands
        case 'open',
            open_file_l;
        case 'save_as',
            save_as_l;
        case 'open_map',
            open_map_l;
        case 'save_map',
            save_map_l;
            
            
        case 'normal_cursor',
            cursor_l('arrow');
         case 'line_cursor',
            cursor_l('crosshair');
         case 'pencil_cursor',
            cursor_l('custom');
   	
                        

        % Barf if we get a bad command            
        otherwise,
            res = '';
            bad_args_l (cmd);
            
    end


    
    


%----------------------------------------------------------------------------------------
function bad_args_l(varargin)
% Throws an error if we didn't get a recgnizable set of arguments


    if (nargin > 0)
        str = sprintf('Incorrect arguments passed to sf_edit_icon module: %s', varargin{1});
    else
        str = sprintf('Incorrect arguments passed to sf_edit_icon module');
    end
    
    error(str);     
    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF EVENT HANDLING
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    














%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Initialization is done with the following functions
%
% create_gui_l
%   Sets up any global info needed for the GUI
%
% create_top_frame_l
% create_bottom_frame_l
% create_middle_frame_l
%   There are two tasks to be done for each of the "frames"
%   1) Allocate resources (done by allocate_xxx_frame_l)
%   2) Position on screen (done by locate_xxx_frame_l)





%-------------------------------------------------------------------------------------------
%
% This function is like the constructor for this module.  It will
% create the figure and also the icon, canvas, toolbar, palette,
% etc.  It uses some helper functions
%
% We're using a big ol' data structure to hold info on graphics stuff
% It looks like this
%
% gs
% +- figureHandle               handle to entire window
% +- statusHandle
% |
% +- file
% |  +- name
% |  +- saveType
% |  +- mode                    is 'r'(rgb), 'g'(gray), or 'i' (indexed)
% |
% +- rect
% |  +- entire                  bounding box of window
% |  +- icon                    bounding box of actual-size icon display
% |  +- canvas                  bounding box of zoomed "canvas"
% |
% +- handle
% |  +- icon                    hg handle to actual-size icon display
% |  +- canvas                  hg handle to zoomed "canvas"
% |
% +- img
% |  +- base                    matrix holding digital image data
% |  +- modstack(0..n)          array of matrices holding modifications to image data
% |  +- scratch                 current working matrix of image data
% |
% +- toolBar
% |  +- handle
% |  |  +- pencil
% |  |  +- dline
% |  |  +- undo
% |  |  +- open
% |  |  +- saveas
% |  |  +- openMap
% |  |  +- saveMap
% |  |  +- blank
% |  |
% |  +- rect
% |  |  +- entire
% |  |  +- pencil
% |  |  +- line
% |  |  +- undo
% |  |  +- open
% |  |  +- saveas
% |  |  +- openMap
% |  |  +- saveMap
% |  |
% |  +- icon
% |     +- pencil
% |     +- undo
% |     +- undoGray
% |     +- undoNormal
% |     +- line
% |     +- save
% |     +- saveas
% |     +- blank
% |
% +- palette
%    +- handle
%    |  +- region
%    |  +- boxes
%    |  +- fgBox
%    |
%    +- rect
%    |  +- entire
%    |  +- swatches
%    |  +- swatch(1..numColors)
%    |
%    +- color
%    |  +- numColors
%    |  +- map
%    |  +- count        count(i) tells how many times map(i) is used in the image
%    |  +- fg

%-------------------------------------------------------------------------------------------
function fh = create_gui_l
% This function creates the GUI for the icon editor
% We cache anything interesting (handles, screen sizes, etc.)
%
% This function only sets the stuff that applies to the entire window
% Helper functions take care of each sub-part of the window
    
    % Use this hack to make sure we only have one Icon Editor 
    % available at a time.  That is, kill anything with our
    % "magic cookie"
    theTag = 'TOMS_ICON_EDITOR';
    foundVal = findall (0, 'type', 'figure', 'Tag', theTag);
    delete (foundVal);
    
    % Make our new figure and save some info about it
    gs.figureHandle = figure('Name', 'Stateflow Icon Editor' ...
            ,'MenuBar', 'none' ...
            ,'NumberTitle', 'off' ...
            ,'Color', 'blue' ...
            ,'Tag',  theTag ...
            ,'WindowButtonMotion', 'sf_edit_icon(''BM'');' ...
            ,'WindowButtonDown', 'sf_edit_icon(''BD'');' ...
            ,'WindowButtonUp', 'sf_edit_icon(''BU'');' ...            
            ,'ResizeFcn', 'sf_edit_icon(''resize'');' ...
            ,'Units', 'pixel' ...            
            ,'DoubleBuffer', 'on' ...
            ,'BusyAction', 'queue' ...
            ,'Visible', 'off' ...
            );
    gs.rect.entire = get(gs.figureHandle, 'Position');

    gs.statusHandle = uicontrol('Style', 'text', 'String', '', 'HorizontalAlignment', 'left');
    
    set(gs.figureHandle, 'PointerShapeCData', PENCIL_CURSOR_L, 'PointerShapeHotSpot', [16 5]);
	 set(gs.figureHandle, 'Pointer', 'custom');    
    % Save our stuff
    gs_set_l(gs);
    
    
    % load in a default image
    load_fake_image_l;


    % Let helper functions take over    
    create_top_frame_l;
    create_bottom_frame_l;
    create_middle_frame_l;

    set(gs.figureHandle, 'Visible', 'on');
    % Tell that everything went okay
    fh = logical(1);




%-------------------------------------------------------------------------------------------
function create_top_frame_l
% This function will set up the toolbar in the top frame

    allocate_top_frame_l;
    locate_top_frame_l;

%-------------------------------------------------------------------------------------------
function allocate_top_frame_l
% Called once at startup  (helper function for constructor)
    gs = gs_get_l;

    
    iconDir = which('sfediticon');
    if isempty(iconDir)
        error ('Can''t find icon directory');
    end 
    iconDir = [iconDir(1:(end-14)) 'icons' filesep];
    

    % Now, load in all the icons for the toolbar one-by-one
    gs.toolBar.icon.pencil = imread([iconDir 'pencil.bmp']);
    gs.toolBar.handle.pencil = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.dline = imread([iconDir 'line.bmp']);
    gs.toolBar.handle.dline = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.undoNormal = imread([iconDir 'undo.bmp']);
    gs.toolBar.icon.undoGray = imread([iconDir 'undogray.bmp']);
    gs.toolBar.icon.undo = gs.toolBar.icon.undoGray;
    gs.toolBar.handle.undo = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.open = imread([iconDir 'open.bmp']);
    gs.toolBar.handle.open = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.saveas = imread([iconDir 'save.bmp']);
    gs.toolBar.handle.saveas = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.openMap = imread([iconDir 'cmapin.bmp']);
    gs.toolBar.handle.openMap = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.saveMap = imread([iconDir 'cmapout.bmp']);
    gs.toolBar.handle.saveMap = axes('Units', 'Pixels', 'Visible', 'off');

    gs.toolBar.icon.blank = imread([iconDir 'blank.bmp']);
    gs.toolBar.handle.blank = axes('Units', 'Pixels', 'Visible', 'off');

    
    gs_set_l(gs);













%-------------------------------------------------------------------------------------------
function create_bottom_frame_l
% Sets up icon and palette.  Helper for constructor

    allocate_bottom_frame_l;
    locate_bottom_frame_l;
    
    
    
    
%-------------------------------------------------------------------------------------------
function allocate_bottom_frame_l
% Handles resource allocation for stuff along bottom of screen
    gs = gs_get_l;    

    gs.handle.icon = axes('Visible', 'off', 'DrawMode', 'fast');


    % Use "pl" as shorthand for "gs.palette"
    pl.color.numColors = 32;
    
    if (gs.file.mode == 'r')
        pl.color.map = colorcube(pl.color.numColors);      % could use another color map like autumn or flag
    else %if(gs.file.mode == 'g')
        pl.color.map = gray(pl.color.numColors);
    end

    % default foreground and background colors
    pl.color.fg = pl.color.map(pl.color.numColors - 2,:);


    % Show the boxes that show fg/bg color
    % We need at least 50x50 square, 
    % We can accept more height, but we'll just
    % center our 50x50 square with respect to it
    pl.handle.boxes = axes('Visible', 'off');
    pl.handle.fgBox = rectangle('Visible', 'off');    
    
    % Draw all of the boxes and color them as in the color map
    pl.handle.region = axes('Visible', 'off');

    gs.palette = pl;
    gs_set_l(gs);







%----------------------------------------------------------------------------------------
function create_middle_frame_l
% Helper for constructor.  Middle frame consists of the canvas

    allocate_middle_frame_l;
    locate_middle_frame_l;




%----------------------------------------------------------------------------------------
function allocate_middle_frame_l
% Resource allocation for canvas

    gs = gs_get_l;
    gs.handle.canvas = axes('Visible', 'off', 'DrawMode', 'fast');
    gs_set_l(gs);
    




%----------------------------------------------------------------------------------------
function load_fake_image_l
% This sets up a 16x16 plain white image

    gs = gs_get_l;

    gs.img.base = [];    
    gs.img.base(1:16,1:16,1:3) = uint8(255);
    gs.img.scratch = NaN * double(gs.img.base);
    gs.img.modstack = [{gs.img.scratch}];
    gs.file.name = 'untitled.bmp';
    gs.file.saveType = 'bmp';
    gs.file.mode = 'r';

    gs_set_l(gs);

function kill_l
    theTag = 'TOMS_ICON_EDITOR';
    foundVal = findall (0, 'type', 'figure', 'Tag', theTag);
    delete (foundVal);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF INITIALIZATION
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  SCREEN LAYOUT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%-------------------------------------------------------------------------------------------
% Change cursor appearance
function cursor_l(pointer)

	gs = gs_get_l;

   
   if (isequal(pointer, 'custom'))
      hs = [16,5];
   else
      hs = [8,8];
   end 
   
   set(gs.figureHandle, 'Pointer', pointer, 'PointerShapeHotSpot', hs);
      
      
function pc = PENCIL_CURSOR_L

r01 = [NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
r02 = [NaN NaN NaN NaN NaN NaN NaN NaN  1   1   1  NaN NaN NaN NaN NaN];
r03 = [NaN NaN NaN NaN NaN NaN NaN NaN  1   2   2   1  NaN NaN NaN NaN];
r04 = [NaN NaN NaN NaN NaN NaN NaN NaN  1   2   2   1  NaN NaN NaN NaN];
r05 = [NaN NaN NaN NaN NaN NaN NaN  1   1   1   1  NaN NaN NaN NaN NaN];
r06 = [NaN NaN NaN NaN NaN NaN NaN  1   2   1   1  NaN NaN NaN NaN NaN];
r07 = [NaN NaN NaN NaN NaN NaN  1   2   2   1  NaN NaN NaN NaN NaN NaN];
r08 = [NaN NaN NaN NaN NaN  1   1   2   2   1  NaN NaN NaN NaN NaN NaN];
r09 = [NaN NaN NaN NaN NaN  1   2   2   2   1  NaN NaN NaN NaN NaN NaN];
r10 = [NaN NaN NaN NaN  1   1   2   2   1  NaN NaN NaN NaN NaN NaN NaN];
r11 = [NaN NaN NaN NaN  1   2   2   2   1  NaN NaN NaN NaN NaN NaN NaN];
r12 = [NaN NaN NaN NaN  1   1   2   1  NaN NaN NaN NaN NaN NaN NaN NaN];
r13 = [NaN NaN NaN NaN  1   1   1   1  NaN NaN NaN NaN NaN NaN NaN NaN];
r14 = [NaN NaN NaN NaN  1   1   1  NaN NaN NaN NaN NaN NaN NaN NaN NaN];
r15 = [NaN NaN NaN NaN  1   1  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];
r16 = [NaN NaN NaN NaN  1  NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];

pc = [r01;r02;r03;r04;r05;r06;r07;r08;r09;r10;r11;r12;r13;r14;r15;r16];


%-------------------------------------------------------------------------------------------
% Echo a message to the status bar
function status_l(msg)

    gs = gs_get_l;
    
    set(gs.statusHandle, 'String', msg);
    

%-------------------------------------------------------------------------------------------
% Do a fresh layout of everything on the screen
function locate_all_l;
    gs = gs_get_l;
    gs.rect.entire = get(gs.figureHandle, 'Position');
    gs_set_l(gs);
    
    locate_top_frame_l;
    locate_bottom_frame_l;
    locate_middle_frame_l;
    update_display_l;    




%-------------------------------------------------------------------------------------------
function locate_top_frame_l
% Call this to have the top frame intelligently position itself on top of the screen


    gs = gs_get_l;

    % Our "top" is the same as the figure's height    
    f = get(gs.figureHandle, 'Position');
    top = f(4);



    % Now, size all of the icons for the toolbar one-by-one
    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.pencil);
    pi = image(gs.toolBar.icon.pencil);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [1 top-y(2)+1 x(2) y(2)];
    set(gs.toolBar.handle.pencil, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.pencil = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.dline);
    pi = image(gs.toolBar.icon.dline);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.dline, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.dline = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.undo);
    pi = image(gs.toolBar.icon.undo);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.undo, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.undo = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.open);
    pi = image(gs.toolBar.icon.open);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.open, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.open = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.saveas);
    pi = image(gs.toolBar.icon.saveas);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.saveas, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.saveas = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.openMap);
    pi = image(gs.toolBar.icon.openMap);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.openMap, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.openMap = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.saveMap);
    pi = image(gs.toolBar.icon.saveMap);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) x(2) y(2)];
    set(gs.toolBar.handle.saveMap, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.toolBar.rect.saveMap = prect;

    set(gs.figureHandle, 'CurrentAxes', gs.toolBar.handle.blank);
    pi = image(gs.toolBar.icon.blank);
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    prect = [prect(1)+prect(3) prect(2) f(3)-prect(1)-prect(3)+1 y(2)];
    set(gs.toolBar.handle.blank, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    % No need to save a rect (for now)


    % set toolbar to top of screen, as many pixels high as the tool icons are
    % I'm assuming all icons are the same height
    gs.toolBar.rect.entire = [1 top-y(2) f(3) y(2)];   
    gs_set_l(gs);



%-------------------------------------------------------------------------------------------
function locate_bottom_frame_l
% Call this to resize/reposition the bottom frame

    gs = gs_get_l;

    % Status bar is 15 pixels high
    statusheight = 15;
    prect = [1 1 gs.rect.entire(3), 15];
    set(gs.statusHandle, 'Position', prect);


    % ------ ICON -----------

    % Some of the icon stuff
    set(gs.figureHandle, 'CurrentAxes', gs.handle.icon);
    pi = image(uint8(gs.img.base), 'EraseMode', 'XOR');
    x = get(pi, 'XData');
    y = get(pi, 'YData');
    gs.handle.iconImg = pi;
    
    % If the icon take up more than 50% of the width or the height of the window, then
    % it's not much of an icon!  Don't bother to resize the "icon view"
    if  (x(2) > gs.rect.entire(3)/2) | (y(2) > gs.rect.entire(4)/2)
        set(gs.handle.icon, 'Visible', 'off');
        height = 60;
        
    else
        set(gs.handle.icon, 'Visible', 'off');
    
    % We will take at least 60 pixels for the bottom frame, but maybe more (if the "icon" is taller than that)
    height = max(60, y(2));
     
    % real size, lower-left-hand vcentered in bottom frame
    start = statusheight + 1 + (height - y(2)) / 2;
    prect = [3 start  x(2) y(2)];    
    set(gs.handle.icon, 'Units', 'pixels', 'Visible', 'off', 'Position', prect);
    gs.rect.icon = prect;
    end        
    % ------ END OF ICON ------




    % ------- PALETTE -------
    pl = gs.palette;
    xstart = gs.rect.icon(1) + gs.rect.icon(3) + 1;
    width = gs.rect.entire(3) - xstart;
    pl.rect.entire = [xstart, statusheight+1, width, height];

    
    % It would be nice to have an intelligent "arranger" for all the palette colors
    % For now, be satisfied with always having 4 rows of colors
    rows = 4;



    % Show the boxes that show fg/bg color
    % We need at least 50x50 square, 
    % We can accept more height, but we'll just
    % center our 50x50 square with respect to it
    bxs = [pl.rect.entire(1) statusheight+1+(pl.rect.entire(4)-50)/2 50 50];

    set(pl.handle.boxes, 'Units', 'pixels', 'Visible', 'off', 'Position', bxs, 'XLim', [0 bxs(3)] ...
        , 'YLim', [0 bxs(4)]);
    
    fgRect = [10 10 30 30];
    
    % Now, draw 'em, and save the handles for later
    set (pl.handle.fgBox, 'EdgeColor', 'black', 'FaceColor', pl.color.fg, 'Position', fgRect, 'Visible', 'on');


    pl.rect.swatches = pl.rect.entire;
    pl.rect.swatches(1) = bxs(1) + bxs(3) + 1;
    pl.rect.swatches(3) = pl.rect.swatches(3) - bxs(3);

    
    
    % For now, we will force 4 rows of swatches.
    % There must be a better way to try to maximize the "beauty" by adjusting the number
    % of rows and columns to match the total number of colors with the y/x ratio, but I'll
    % leave that for later.
    sz = size(pl.color.map);
    colors = sz(1);
    cols = ceil ( colors / rows);
    
   

    boxWidth = pl.rect.swatches(3) / cols;
    boxHeight = pl.rect.swatches(4) / rows;
    
    % Draw all of the boxes and color them as in the color map
    set(gs.figureHandle, 'CurrentAxes', pl.handle.region);
    set (pl.handle.region, 'Units', 'pixels', 'Position', pl.rect.swatches, 'XLim', [0 pl.rect.swatches(3)] ...
        ,'YLim', [0 pl.rect.swatches(4)], 'Visible', 'off');
     
     
    % draw a highlighted box around the swatches
    rh = rectangle('Position', [0 0 pl.rect.swatches(3) pl.rect.swatches(4)], 'EdgeColor', 'black' );
     
    colorCount = count_colors_l(gs.img.base, pl.color.map);

    for r = 1:rows
        for c = 1:cols
            x = (c - 1) * boxWidth;
            y = (r - 1) * boxHeight;
            index = (c - 1) * (rows) + (r - 1) + 1;
            if (index <= colors)
                rct = [x, y, boxWidth-1, boxHeight-1];
                
                % Make a big box if this is the last one
                if (index == colors)
                    rct(4) = pl.rect.entire(4) - y;
                end
                pl.rect.swatch(index,:) = rct;
                rh = rectangle('Position', rct);
                index = min( [index, colors] );
                clr = pl.color.map(index,:);
                if (colorCount(index) == 0)
                    set(rh, 'EdgeColor', 'black');
                else
                    set(rh, 'EdgeColor', 'white');
                end
                set(rh, 'FaceColor', clr);
            end
        end
    end

    pl.color.count = colorCount;

    gs.palette = pl;
    gs_set_l(gs);



%-------------------------------------------------------------------------------------------
% Size the canvas intelligently 
% Call this affter the top and bottom frames are already in place!
function locate_middle_frame_l

    gs = gs_get_l;

    avail = [  0    ...                                                              % left edge    
               gs.palette.rect.entire(2) + gs.palette.rect.entire(4) + 1 ...         % right above the palette
               gs.rect.entire(3)...                                                  % use entire width
               gs.rect.entire(4) - gs.toolBar.rect.entire(4) - gs.palette.rect.entire(2) - gs.palette.rect.entire(4)
    ];

    
    set(gs.figureHandle, 'CurrentAxes', gs.handle.canvas);
    pi = image(uint8(gs.img.base), 'EraseMode', 'XOR');
    
    
    % we want to make sure each pixel is mapped to an NxN square. (1:1 aspect ratio)
    X = get(pi, 'XData');
    Y = get(pi, 'YData');
    gs.handle.canvasImg = pi;

    % These numbers tell the maximum "zoom" factor in each dimension
    xfactor = floor(avail(3) / X(2));
    yfactor = floor(avail(4) / Y(2));
    
    % The minimum of these will give us the zoom factor to actually use
    zoom = min(xfactor, yfactor);
    width = zoom * X(2);
    height = zoom * Y(2);

    % Force picture to fill the screen if we are "zooming out" instead of zooming in.
    if (width < 1)
        width = avail(3);
    end
    if (height < 1)
        height = avail(4);
    end

    gs.rect.canvas = [   (avail(3) - width) /2  ...
                        ,avail(2) + (avail(4) - height)/2  ...
                        , width ...
                        , height...
                     ];

    
    set(gs.handle.canvas, 'Units', 'pixels', 'Position', gs.rect.canvas, 'Visible', 'off');
    
    
    gs_set_l(gs);    




%----------------------------------------------------------------------------------------
function update_display_l
% Update the screen displays
%

    gs = gs_get_l;

    % This is our "bottom layer"
    im = gs.img.base;

    % Now, we have a stack of undo-able modifications to base image    
    sz = size(gs.img.modstack);
    for (ind=1:sz(2))
        modmap = gs.img.modstack{ind};
        repl = ~isnan(modmap);
        im(repl) = uint8(modmap(repl));   
    end
    
    
    % And, finally the scratch pad on the very top
    repl = ~isnan(gs.img.scratch);
    im(repl) = uint8(gs.img.scratch(repl));


    % Now, show the whole image
    set(gs.figureHandle, 'CurrentAxes', gs.handle.icon);
    set (gs.handle.iconImg, 'CData', uint8(im));
    set(gs.handle.icon, 'Visible', 'off');
    set(gs.figureHandle, 'CurrentAxes', gs.handle.canvas);
    set (gs.handle.canvasImg, 'CData', uint8(im));
    set(gs.handle.canvas, 'Visible', 'off');

    drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF SCREEN LAYOUT
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

























%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  COLORS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%----------------------------------------------------------------------------------------
function save_color_l
% If the mouse is over one of the color swatches, 
% this function will cache the index of the colormap corresponding to this color
% for use later on
    gs = gs_get_l;

    % Find mouse position relative to palette axes
    mx = get(gs.palette.handle.region, 'CurrentPoint');
    pt = [mx(1) mx(3)];
    
    % Now, see if which color swatch we're over
    for c = 1:gs.palette.color.numColors
        checkRect = gs.palette.rect.swatch(c,:);
        if (is_in_rect_l (pt, checkRect))
            clr_set_l(c);
            break;
        end
    end


       
%----------------------------------------------------------------------------------------
function new_color_l
% This function will take the previously cached color and set 
% either the foregorund color to it
    gs = gs_get_l;
    c = clr_get_l;
        
    % only change the color if our index isn't a NaN
    if (~isnan(c))
        newcolor = gs.palette.color.map(c,:);
        set(gs.palette.handle.fgBox, 'FaceColor', newcolor);
        gs.palette.color.fg = newcolor;
        gs_set_l (gs);	% Don't forget to store these values
    end


%----------------------------------------------------------------------------------------
function add_color_l
% Add a color to the current palette/colormap

    clr = uisetcolor;
    sz = size(clr);
    if (sz(2) == 3)
    
        gs = gs_get_l;
        
        gs.palette.color.map = [gs.palette.color.map;clr];
        gs.palette.color.numColors = gs.palette.color.numColors + 1;
        
        gs_set_l(gs);
        
        locate_all_l;
    end
    
    


%----------------------------------------------------------------------------------------
function show_color_menu_l
% Brings up a right-click menu.  Contents dependent on which color mouse is over

    % Find mouse position relative to palette axes
    save_color_l;

    gs = gs_get_l;
    
    cmenu = uicontextmenu('Parent', gs.figureHandle);
    
    % Menu entry for adding colors
    m1 = uimenu('Label', 'Add new color...', 'Parent', cmenu, 'Callback', 'sf_edit_icon(''add_color'');' );

    % Menu entry for editing colors
    m2 = uimenu('Label', 'Edit this color...', 'Parent', cmenu, 'Callback', 'sf_edit_icon(''edit_color'');' );
        
    % Only show delete color menu entry if this color is unused
    c = clr_get_l;
    if (gs.palette.color.count(c) == 0)
        m3 = uimenu('Label', 'Delete this Color', 'Parent', cmenu, 'Callback', 'sf_edit_icon(''delete_color'');' );
    end
    
    % Locate the context menu
    pos = get(cmenu, 'Position');
    pt = get(gs.figureHandle, 'CurrentPoint');
    pos(1) = pt(1);
    pos(2) = pt(2);
    
    % And show it
    set(cmenu, 'Position', pos, 'Visible', 'on');
    


%----------------------------------------------------------------------------------------
function edit_color_l
% Change a colormap/palette entry
% This will also change any instances of this color in the image being edited

    c = clr_get_l;
        
    % only change the color if our index isn't a NaN
    if (~isnan(c))

        % This is an "undoable" action
        collapse_layers_l;
        
        gs = gs_get_l;
        
        % Change the color in the palette
        oclr = gs.palette.color.map(c,:);
        nclr = uisetcolor(oclr);
        gs.palette.color.map(c,:) = nclr;
        
        % Change this color in the image, too!
        gs.img.base = replace_color_l (gs.img.base, oclr, nclr); 
        
        gs_set_l (gs);	% Don't forget to store these values
        
        update_display_l;
        locate_bottom_frame_l;
    end

    

%----------------------------------------------------------------------------------------
function delete_color_l
% Remove a color from the colormap

    gs = gs_get_l;
    c = clr_get_l;
        
    % only delete the color if our index isn't a NaN
    if (~isnan(c))
        gs.palette.color.map(c,:) = [];
        gs.palette.color.count(c) = [];
        gs.palette.color.numColors = gs.palette.color.numColors - 1;
        gs_set_l (gs);	% Don't forget to store these values
        locate_bottom_frame_l;
    end




%----------------------------------------------------------------------------------------
function outimg = replace_color_l (img8, oldclr, newclr)
% Changes all instances of olddclr to newclr in img8


    % convert 3x8 bit image to 1x24 bit image    
    img24 = img_24_bit_l(img8);

    % convert colors to 24 bit
    oc8 = uint8(oldclr * 256 - 1);
    nc8 = uint8(newclr * 256 - 1);
    m = [1 256 65536];
    oldcolor = sum(double(oc8) .* m);
    newcolor = sum(double(nc8) .* m);
    

    % Find the colors to replace, and replace them 
    rep = (img24 == oldcolor);
    new24 = (newcolor * rep) + (~rep .* img24);
    
    % Convert our image back to 3x8 bit
    outimg = img_8_bit_l(new24);



%----------------------------------------------------------------------------------------
function count = count_colors_l (im, map)
% Looks in image im for colors in colormap map.
% Returns vector with numeric count for each colormap entry
% Each entry is the number of pixels with that color

    % Convert to flat 24-bit arrays for easy matrix ops
    im24  = img_24_bit_l(im);
    map24 = map_24_bit_l(map);
    
    sz = size(map24);
    for j=1:sz(1)
        count(j) = sum(sum(ismember(im24, map24(j))));
    end
    




%----------------------------------------------------------------------------------------
function closest = match_color_l (clr, map)
% Finds the "closest match" to color clr in colormap map
% It treats colorspace as Euclidean, and returns the map color that has the 
% smallest distance from the desired color


    % Construct a vector of Euclidean distances from the color to each of the map's colors
    dist = (map(:,1) - clr(1,1)).^2 + (map(:,2) - clr(1,2)).^2 + (map(:,3) - clr(1,3)).^2;
    
    % Which one is closest?
    closest = find(dist == min(dist));
    
    
    


%----------------------------------------------------------------------------------------
function opt = optimize_map_l (oldmap, newmap)
% Make a colormap "opt" such that
%  1) Only colors from "newmap" are used
%  2) "opt" is the same size as "oldmap"
%  3) The value in opt(n) is the closest match to oldmap(n)
%     that could be found in the newmap

    sz = size(oldmap);
    for j=1:sz(1)
    
        clr = oldmap(j, :);
        match = match_color_l(clr, newmap);
        opt(j,:) = newmap(min(match),:);
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF COLORS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    

    
    




















%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  FOCUS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%------------------------------------------------------------------------
function in = mouse_in_region_l (reg)
% Gives boolean answer to question "Is the mouse in this region?"
% It expects a string argument: 'icon', 'canvas', 'palette', etc.
%
    % Get the persistent gui data
    gs = gs_get_l;
    
    % Find mouse position and normalize it to our coordinate space
    xy = get(gs.figureHandle, 'CurrentPoint');
     
    % Find the correct bounding rectangle for this region
    switch (reg)
    
        case 'icon',
            rect = gs.rect.icon;
        case 'canvas',
            rect = gs.rect.canvas;
        case 'palette',
            rect = gs.palette.rect.entire;            
        case 'swatches',
            rect = gs.palette.rect.swatches;
        case 'toolbar',
            rect = gs.toolBar.rect.entire;
        case 'pencil',
            rect = gs.toolBar.rect.pencil;
        case 'line',
            rect = gs.toolBar.rect.dline;
        case 'undo',
            rect = gs.toolBar.rect.undo;
        case 'open',
            rect = gs.toolBar.rect.open;
        case 'save_as',
            rect = gs.toolBar.rect.saveas;
        case 'open_map',
            rect = gs.toolBar.rect.openMap;
        case 'save_map',
            rect = gs.toolBar.rect.saveMap;
        
        otherwise,
            % don't say "yes" if we don't know what they're talking about
            rect = [0,0,0,0];
    end
    
    % If we're in that rectangle, we're in the region
    in = is_in_rect_l (xy, rect);
    
            




%-------------------------------------------------------------------------
function in = is_in_rect_l (pt, rect)
% Tells whether pt [x,y] is in rectangle [left,top,width,height]
%
    ltrb = [rect(1:2) rect(3)+rect(1)-1 rect(4)+rect(2)-1];
    
    xb = [rect(1) rect(3)+rect(1)-1];
    yb = [rect(2) rect(4)+rect(2)-1];
    
    xs = sort( [xb pt(1)]);
    ys = sort( [yb pt(2)]);

    if ( [xs(2) ys(2)] == pt)
        in = logical(1);
    else
        in = logical(0);
    end




%----------------------------------------------------------------------------------------
function p1 = clip_to_rect_l (p1, rect)
% "Saturates" p1 so that it doesn't go outside of length and width of rect

    % Neat trick to avoid many if statements
    xs = sort ([1 p1(1) rect(3)]);
    ys = sort ([1 p1(2) rect(4)]);    
    p1 = [xs(2) ys(2)];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF FOCUS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    
    

    
       
        
    
    













    




    

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  IMAGE EDITING
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%----------------------------------------------------------------------------------------
function img = line_l(img, a, b, clr)
% Draw a line 
% This draws a line on img from p0 to p1 using clr for a color
% The modified image is returned from the function

    sz = size(size(img));
    if (sz(2) == 3)
        type = 'r';
    else
        type = '8bit';
    end
    
    % To siplify algortihm, put points in order of increasing x
    if (b(1) >= a(1))
        p0 = a;
        p1 = b;
    else
        p0 = b;
        p1 = a;
    end
    

    % get the size of the image and make sure we don't draw outside of it!
    sz = size(img);
    rect = [1 1 sz(1) sz(2)];
    p0 = clip_to_rect_l(p0, rect);
    p1 = clip_to_rect_l(p1, rect);
    
    
    rise = p1(2) - p0(2);
    run = p1(1) - p0(1);
    
    % Three types of line
    if (rise == 0)
    
        % Horizontal line
        xr = sort( [p0(1) p1(1)] );
        y = p1(2);
        
        if (type == 'r')    
            for x = [xr(1):xr(2)]        
                img( y, x, :) = clr;
            end
        else
            for x = [xr(1):xr(2)]        
                img( y, x) = clr;
            end
        end        
    elseif (run == 0)
    
        % Vertical line
        yr = sort([p1(2) p0(2)]);
        x = p1(1);
        
        if (type == 'r')
            for y = [yr(1):yr(2)]
                img( y, x, :) = clr;
            end
        else
            for y = [yr(1):yr(2)]
                img( y, x) = clr;
            end
        end            
        
    else
    
        % Sloped line
        
        
        % Here is the equation of the line in
        % Point-slope form:
        % y - y0 = m(x-x0), or
        % y = m(x-x0) + y0
        st = p0;
        slope = rise / run;
        
    
        % The first column is treated specially since we start in the middle
        % Example:  p0 is (1,3) and p1 is (10, 22) in pixel coordinates
        % So, we need to color in all the pixels in the first column that this line
        % will touch.
        % The first point is (1,3), as established
        % The last point will occur right on the pixel border, that is at 
        % (1.5, f(1.5)) in real coordinates
        % (1, round(f(1.5)) in pixel coordinates
        x = p0(1);
        y = round (slope *(x + 0.5 - st(1)) + st(2));
        yr = sort([p0(2) y]);
        
        
        if (type == 'r')
            for y = [yr(1):yr(2)]
                img( y, x, :) = clr;
            end
        else
            for y = [yr(1):yr(2)]
                img( y, x) = clr;
            end
        end            
        
        
        % Okay, now all the middle columns are treated the same
        % In the example, these are pixel columns 2 through 9
        for (x=[ p0(1)+1 : p1(1)-1 ] )
        
        
            % In each column, we want to draw the line segment:
            % From (x-.5,f(x-.5)) to (x+.5,f(x+.5)) in real coordinates
            % Or ( x, round(f(x-.5))) to (x, round(f(x+.5))) in pixel coords
            y0 = round (slope *(x - 0.5 - st(1)) + st(2));
            y1 = round (slope *(x + 0.5 - st(1)) + st(2));
            yr = sort([y0 y1]);
            if (type == 'r')
                for y = [yr(1):yr(2)]
                    img( y, x, :) = clr;
                end
            else
                for y = [yr(1):yr(2)]
                    img( y, x) = clr;
                end
            end            
    
        end
    
        
        % And now, treat the last column similarly to the first
        % In the example, the last point is (10, 22), as above
        % The first point is (9.5, f(9.5)) in real coordinates
        % Or (9, round (f(9.5))) in pixel coords
        x = p1(1);
        y = round (slope *(x -0.5 - st(1)) + st(2));
        yr = sort([p1(2) y]);


        if (type == 'r')
            for y = [yr(1):yr(2)]
                img( y, x, :) = clr;
            end
        else
            for y = [yr(1):yr(2)]
                img( y, x) = clr;
            end
        end            
        
    end
    




%----------------------------------------------------------------------------------------
function anchor_line_l
% Sets the "starting point" of current line (when user clicks on canvas)
% As the user drags, a line is drawn from this point to the current mouse location
% When the user releases the button, the line is "snapped" in place

    gs = gs_get_l;

    % Find mouse position relative to canvas axes
    mx = get(gs.handle.canvas, 'CurrentPoint');
    pt = [mx(1) mx(3)];
    pt = round(pt);
    
    % Clip this point such that it is really in the canvas!
    bound = [1 1 gs.rect.canvas(3) gs.rect.canvas(4)];
    pt = [ max([bound(1) pt(1)])   max([bound(2) pt(2)]  )];
    pt = [ min([bound(3) pt(1)])   min([bound(4) pt(2)]  )];


    
    % Land Ho!
    anchor_set_l(pt);
    



%----------------------------------------------------------------------------------------
function render_line_l
% Draw a line from the anchor to the current mouse position

    clear_scratch_l;
    gs = gs_get_l;
    
    % Find mouse position relative to canvas axes
    mx = get(gs.handle.canvas, 'CurrentPoint');
    pt = [mx(1) mx(3)];
    pt = round(pt);
    rct = get(gs.handle.canvas, 'Position');
    pt = clip_to_rect_l(pt, rct);

    % connect the dots
    cind = uint8(255*gs.palette.color.fg);
    gs.img.scratch = line_l(gs.img.scratch, anchor_get_l, pt, cind); 
    gs_set_l (gs);
    
    update_display_l;                



%----------------------------------------------------------------------------------------
function draw_point_l
% Colors in a pixel at the current mouse position

    gs = gs_get_l;
    
    % Find mouse position relative to canvas axes
    mx = get(gs.handle.canvas, 'CurrentPoint');
    pt = [mx(1) mx(3)];
    pt = round(pt);
    sz = size(gs.img.scratch);
    rct = [1 1 sz(1) sz(2)];
    pt2 = clip_to_rect_l(pt, rct);
    
    if (pt2 == pt)
       gs.img.scratch(pt(2), pt(1), :) = uint8(255*gs.palette.color.fg); 
    end

    gs_set_l (gs);

    update_display_l;    
    
    
    
    
%----------------------------------------------------------------------------------------
function undo_l
% Discards the top entry on the "modstack"

    clear_scratch_l;

    gs = gs_get_l;
    gs.img.modstack = pop_l(gs.img.modstack);
    gs_set_l(gs);

    update_display_l;
		



%----------------------------------------------------------------------------------------
function clear_scratch_l
% Clears the temporary "scratch canvas"

    gs = gs_get_l;
    gs.img.scratch = NaN * (gs.img.scratch);    
    gs_set_l(gs);    
    
    

    
%----------------------------------------------------------------------------------------
function commit_l
% Saves the scratch canvas
    gs = gs_get_l;
    
    if (size(gs.img.base) == size(gs.img.scratch) )
        gs.img.modstack = push_l (gs.img.modstack, gs.img.scratch);
    end
    gs.img.scratch = NaN * double(gs.img.base);    

    gs_set_l(gs);
    
    check_modstack_l;
    show_undo_status(logical(1));    
    
    
%----------------------------------------------------------------------------------------
function check_modstack_l;
% If modstack is too deep, then shrink it
% Bottom entries are merged into the base image
    
    gs = gs_get_l;
    
    MAX_STACK = 15;
    sz = size(gs.img.modstack);
    if (sz(2) > MAX_STACK)
        im = gs.img.base;
        modmap = gs.img.modstack{1};
        repl = ~isnan(modmap);
        im(repl) = uint8(modmap(repl));   
        gs.img.base = im;
        gs.img.modstack(1) = [];        
        gs_set_l(gs);
    end



%----------------------------------------------------------------------------------------
function im = get_visible_image_l
% Returns the image that the user should see
% That is, a combination of the base image, all the modifications, and the scratch pad

    gs = gs_get_l;
    

    % bottom layer
    im = gs.img.base;

    % modifications    
    sz = size(gs.img.modstack);
    for (ind=1:sz(2))
        modmap = gs.img.modstack{ind};
        repl = ~isnan(modmap);
        im(repl) = uint8(modmap(repl));   
    end
    
    
    % scratch pad
    repl = ~isnan(gs.img.scratch);
    im(repl) = uint8(gs.img.scratch(repl));




%----------------------------------------------------------------------------------------
function collapse_layers_l
% Merges all changes directly into the base image (can't undo this)


    gs = gs_get_l;
    % bottom layer
    im = gs.img.base;

    % modifications    
    sz = size(gs.img.modstack);
    for (ind=1:sz(2))
        modmap = gs.img.modstack{ind};
        repl = ~isnan(modmap);
        im(repl) = uint8(modmap(repl));   
    end
    
    
    % scratch pad
    repl = ~isnan(gs.img.scratch);
    im(repl) = uint8(gs.img.scratch(repl));

    gs.img.base = im;
    gs.img.scratch = NaN * double(gs.img.base);
    gs.img.modstack = [{gs.img.scratch}];
    
    gs_set_l(gs);

    show_undo_status(logical(0));



%----------------------------------------------------------------------------------------
function imgout = rgb_to_gray_l(imgin)
% Convert an RGB image to grayscale by using intensities
       
    sz = size(imgin);
    
    for x=1:sz(1)
        for y=1:sz(2)
            imgout(x,y) = uint8(sum(double(imgin(x,y,:))) / 3);
        end
    end

    

%----------------------------------------------------------------------------------------
function imgout = gray_to_rgb_l(imgin)
% Convert a grayscale image to RGB
    
    sz = size(imgin);
    
    for x=1:sz(1)
        for y=1:sz(2)
            imgout(x,y,1:3) = imgin(x,y);
        end
    end



%----------------------------------------------------------------------------------------
function imgout = map_to_rgb_l(imgin, map)
% Convert an indexed image to RGB

    sz = size(imgin);
    
    for x=1:sz(1)
        for y=1:sz(2)
            switch (class(imgin))
                case 'uint8',
                    cindex = uint8(double(imgin(x,y)) + 1);
                otherwise,
                    cindex = imgin(x,y);
            end
            clr = uint8(255*map(cindex, :));
            imgout(x, y, :) = clr;
        end
    end





%----------------------------------------------------------------------------------------
function [imgout, map] = rgb_to_map_l(actimgin)
% Convert an RGB image to indexed (and associated colormap)

    sz = size(actimgin);
    % The image can come in as double or uint8
    % Make sure we use uint8 for calcs
    switch (class(actimgin))
        case 'double',
            imgin = uint8(256 * actimgin - 1);
        otherwise,
            imgin = actimgin;
    end

    % Collapse this image into a sorted, unique 24-bit vector 
    iout = img_24_bit_l(imgin);
    [uvector junk ind] = unique(iout);
    clear iout;
 
    % Construct a new image, This one uses 8-bit indices for its values
    % That is, it's a mapped image. (a value of 13 means "color #13 from the colormap")
    imgout = reshape(ind, sz(1), sz(2));
 
    % Now, convert our vector into a MATLAB RGB colormap
    for x=1:length(uvector)
        c = uint8(floor(uvector(x) / 65536));
        left = mod (uvector(x), 65536);
        b = uint8(floor(left / 256));
        a = uint8(mod (left, 256));
        map(x, 1:3) = (double( [a b c]) + 1) / 256;
    end





%----------------------------------------------------------------------------------------
function map8 = map_8_bit_l(uvector)
% Change a 24-bit color vector to an 8-bit color map

    sz = size(uvector);

    % Now, convert our vector into a MATLAB RGB colormap
    for x=1:length(uvector)
        c = uint8(floor(uvector(x) / 65536));
        left = mod (uvector(x), 65536);
        b = uint8(floor(left / 256));
        a = uint8(mod (left, 256));
        map8(x, 1:3) = (double( [a b c]) + 1) / 256;
    end




%----------------------------------------------------------------------------------------
function map24 = map_24_bit_l (map)    
% Change an 8-bit color map to a 24-bit color vector


    sz = (size(map));
    % Construct a multiplier matrix.
    % This will, in effect, bit-shift elements of the original image
    m = ones(sz);
    m(:,2) = 256;
    m(:,3) = 65536;
    
    % Use the multiplier to construct a flat, 24-bit image
    % instead of the 3-byte depth image we had originally
    bigmap = uint8((256*map) - 1);
    ni = double(bigmap).*m;
    map24 = ni(:,1) + ni(:,2) + ni(:,3);






%----------------------------------------------------------------------------------------
function img8 = img_8_bit_l(img24)
% Change a 24-bit color image to an 8-bit (x3) image
    
    hibyte = floor(img24 / 65536);
    leftover = mod (img24, 65536);
    midbyte = floor(leftover / 256);
    lobyte = mod(leftover, 256);
    
    img8(:,:,1) = uint8(lobyte);
    img8(:,:,2) = uint8(midbyte);
    img8(:,:,3) = uint8(hibyte);
    
    





%----------------------------------------------------------------------------------------
function img24 = img_24_bit_l (img)
% Change an 8bit (x3) color image to 24bit

    sz = (size(img));
    % Construct a multiplier matrix.
    % This will, in effect, bit-shift elements of the original image
    m = ones(sz);
    m(:,:,2) = 256;
    m(:,:,3) = 65536;
    
    % Use the multiplier to construct a flat, 24-bit image
    % instead of the 3-byte depth image we had originally
    if (max(max(max(img))) <= 1)
        ni = (double(img)*256).* m;
    else
        ni = double(img).* m;
    end
    img24 = ni(:,:,1) + ni(:,:,2) + ni(:,:,3);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF IMAGE EDITING
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    
    
    
    
    
    
    
    


        


    









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  DATA STRUCTURES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The same strategy is used in different functions for saving screen positions, icons, colors,
% and the big GUI structure.
%
% There is one function that declares nad handles the persistent storage of the object,
% And, two wrapper fucntions, one to set and one to get.

%---------------------------------------------------------------------------
% Persistent data storage for line anchor
% Don't call this directly, use wrapper functions below
function ra = anchor_l(ta)
    
    persistent anchor;
    if (nargin == 1)
        anchor = ta;
        ra = anchor;
    else
        if (isempty(anchor))
            anchor = [1 1];
            ra = anchor;
        else
            ra = anchor;
        end
    end
    
%---------------------------------------------------------------------------
function anchor_set_l(ta)
    anchor_l(ta);
    
%---------------------------------------------------------------------------
function ra = anchor_get_l    
       	ra = anchor_l;


    
    

%---------------------------------------------------------------------------
function icn = icon_get_l
    icn = icon_cache_l;
    
%---------------------------------------------------------------------------
function icon_set_l(ni)
    icon_cache_l(ni);
    
%---------------------------------------------------------------------------
function io = icon_cache_l (ni)
    persistent icn;
    
    if (nargin == 1)
        icn = ni;
        io = icn;
    else
        if (isempty(icn))
            error('Icon not initialized');
        else
            io = icn;
        end
    end
    
    
%-------------------------------------------------------------------------    
function rgs = gs_l (tgs)
% Handles the persistent data storage of "gs" (gui struct)
% Don't call this directly.
% There are wrapper functions gs_get_l and gs_set_l.  Use these instead
    
    persistent gs;
    
    % If we got an argument, then we must be setting the value
    if (nargin == 1)
        gs = tgs;
        rgs = gs;
    % Otherwise, we are getting the value
    else
       
        % Flag an error when getting an unset value
        if (isempty(gs))
            error('GS not initialized');
        else
            rgs = gs;       
        end
    end
    
%---------------------------------------------------------------------------
function gs = gs_get_l
% Looks up the persistent data structure for this module
    gs = gs_l;
    
%---------------------------------------------------------------------------
function gs_set_l (tgs)
% Sets the persistent data structure for this module
    gs_l(tgs);
    

%---------------------------------------------------------------------------
% Persistent data storage for cached colors
% Don't call this directly, use wrapper functions below
function rclr = color_cache_l(tclr)
    
    persistent cindex;
    if (nargin == 1)
        cindex = tclr;
        rclr = cindex;
    else
        if (isempty(cindex))
            cindex = 1;
            rclr = cindex;
        else
            rclr = cindex;
        end
    end
    
%---------------------------------------------------------------------------
function clr_set_l(tclr)
    color_cache_l(tclr);
    
%---------------------------------------------------------------------------
function clr = clr_get_l    
       	clr = color_cache_l;
       	



% Are we being called from a mex file?
function im = is_mex_l (isMex)

    persistent pIsMex;
    if (nargin == 1)
        pIsMex = isMex;
    else
        if (isempty(pIsMex))
            pIsMex = logical(0);    % default to non-Mex
        end
    end
    im = pIsMex;





%---------------------------------------------------------------------------
% These two implement a simple stack.  This is used for the list of 
% modifications to the base image
function stack = push_l (stack, value)


    sz = size(stack);
    if (sz(2) <= 0)
        stack = {value};
    else
        stack = [stack {value}];
    end


function stack = pop_l (stack)

    sz = size(stack);
    
    if (sz(2) <= 0)
        stack = [];
    else
        stack(sz(2)) = [];
    end
       	
       	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF DATA STRUCTURES
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




    


    
    




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  TOOLBAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---------------------------------------------------------------------------
function show_undo_status(newstat)
gs = gs_get_l;
if (newstat)
   gs.toolBar.icon.undo = gs.toolBar.icon.undoNormal;
else
   gs.toolBar.icon.undo = gs.toolBar.icon.undoGray;
end
gs_set_l(gs);
locate_top_frame_l;


%---------------------------------------------------------------------------
function undepress_button_l (tool)
% Make toolbar button look normal

    gs = gs_get_l;
    
    switch(tool)
        case 'line',
            axhdl = gs.toolBar.handle.dline;
        case 'undo'
            axhdl = gs.toolBar.handle.undo;
        case 'pencil'
            axhdl = gs.toolBar.handle.pencil;
        case 'open'
            axhdl = gs.toolBar.handle.open;
        case 'save_as',
            axhdl = gs.toolBar.handle.saveas;
        case 'open_map',
            axhdl = gs.toolBar.handle.openMap;
        case 'save_map',
            axhdl = gs.toolBar.handle.saveMap;
        otherwise
            error ('Can''t depress button');
    end

    img = icon_get_l;
    
    set(gcf, 'CurrentAxes', axhdl);
    image(img);
    set(axhdl, 'Visible', 'off');
    
    
    
%---------------------------------------------------------------------------
function depress_button_l (tool)
% Make tool bar button look pressed-in


    gs = gs_get_l;
    
    switch(tool)
        case 'line',
            axhdl = gs.toolBar.handle.dline;
        case 'undo',
            axhdl = gs.toolBar.handle.undo;
        case 'pencil',
            axhdl = gs.toolBar.handle.pencil;
        case 'open',
            axhdl = gs.toolBar.handle.open;
        case 'save_as',
            axhdl = gs.toolBar.handle.saveas;
        case 'open_map',
            axhdl = gs.toolBar.handle.openMap;
        case 'save_map',
            axhdl = gs.toolBar.handle.saveMap;
        otherwise
            error ('Can''t depress button');
    end

    

    % Cache old button display for use later
    imh = get(axhdl, 'Children');
    dh = get(imh, 'CData');
    sz = size(dh);
    icon_set_l(dh);
    
    
    m = sz(1);
    n = sz(2);
    
    % copy the original, but push it down and to the right
    ni = uint8(ones(m+1,n+1,3));
    ni(2:end,2:end,:) = dh;
    
    % Fill in top and left border with black
    for ind=[1:m+1]
        ni(ind,1,:) = [0 0 0];
    end
    for ind=[1:n+1]
        ni(ind,1,:) = [0 0 0];
    end
    
    % trim excess off bottom and right
    ni(m+1,:,:) = [];
    ni(:,n,:) = [];
    
    set(gcf, 'CurrentAxes', axhdl);
    image(ni);
    set(axhdl, 'Visible', 'off');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF TOOLBAR
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    

    
           
        

    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  FILE ACCESS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%---------------------------------------------------------------------------
function open_file_l
% Open a file from disk (ask user for filename)

    [file, path] = uigetfile ('*jpg;*bmp;*png;*tif;*pcx;*xwd');
    
    if (file ~= 0)
    
        filename = [path, file];
        

        gs = gs_get_l;
    
        try,
            info = imfinfo(filename);
        catch,
            msgbox(lasterr, 'Read Error');
            return;
        end


        gs.file.saveType = info.Format;
        gs.file.name = filename;

        % load in the image from disk    
        switch (info.ColorType)
            case 'truecolor',
                imgData = imread(filename, info.Format);
                if (~strcmp(info.Format, 'jpg'))
                    [indimg, imdmap] = rgb_to_map_l(imgData);
                    gs.palette.color.map = imdmap;
                end
                gs.file.mode = 'r';
            case 'grayscale',
                imgData = imread(filename, info.Format);
                imgData = gray_to_rgb_l(imgData);
                gs.palette.color.map = gray(gs.palette.color.numColors);
                gs.file.mode = 'g';
            case 'indexed',
                [imgData, bigmap] = imread(filename, info.Format);                
                imgData = map_to_rgb_l(imgData, bigmap);
                bm24 = map_24_bit_l(bigmap);
                lm24 = unique(bm24);
                lm8 = map_8_bit_l(lm24);
                gs.file.mode = 'i';
                gs.palette.color.map = lm8;
            otherwise,
                msgbox('This is not a valid image file', 'Read Error');
                return;
        end
    
    
        % store it in the data structure
        gs.img.base = imgData;
        
        % set up the scratch pad to be transparent
        gs.img.scratch = NaN * double(gs.img.base);
        gs.img.modstack = [{gs.img.scratch}];
    
        % Save the data structure
        gs_set_l (gs);
    
        % Do a complete re-layout of the screen
        locate_all_l;
    end  



    
  
 


%---------------------------------------------------------------------------
function save_file_l
% Save a file to disk
 
    im = get_visible_image_l;
    gs = gs_get_l;
    
    if (gs.file.mode == 'r')
        imwrite(im, gs.file.name, gs.file.saveType);
    elseif (gs.file.mode == 'g')
        im = rgb_to_gray_l(im);
        imwrite(im, gs.file.name, gs.file.saveType);        
    else  % map
        [im, map] = rgb_to_map_l(im);
        imwrite(im, map, gs.file.name, gs.file.saveType);
    end
    
    
    
    
%---------------------------------------------------------------------------
function save_as_l
% Ask user for filename, then save to disk

    [file, path] = uiputfile('*.*');
    
    if (file ~= 0)
        filename = [path, file];
        
        gs = gs_get_l;
        gs.file.name = filename;
        gs_set_l(gs);
   
        save_file_l;
    end
         
   



    
    




    

    

%---------------------------------------------------------------------------
function open_map_l
% Get a colormap from disk


% Okay, here's the scoop
% We start out with an RGB image, which gets converted to 
% An indexed image and the "oldmap"
% Then, we load in the "newmap", and construct a "tempmap"
% This tempmap is the same size as the oldmap, using best-match
% colors from the newmap.  The tempmap and the indexed image 
% are combined to make a new RGB image, used from now on
% and the palette is set to use the newmap
    [file, path] = uigetfile ('*.*');
    
    if (file ~= 0)
    
        filename = [path, file];

        collapse_layers_l;
        
        gs = gs_get_l;
        oldRGB = gs.img.base;
        [indimg, oldmap] = rgb_to_map_l(oldRGB);

        try,
            load (filename,  '-MAT');
        catch,
            msgbox('This is not a valid colormap file', 'Read Error');
            return;
        end
        
        newmap = DISK_MAP;
        tempmap = optimize_map_l(oldmap, newmap);
        
        newRGB = map_to_rgb_l(indimg, tempmap);
        
        
        gs.palette.color.map = newmap;
        gs.img.base = newRGB;
                        
        gs_set_l(gs);
            
    
        % Do a complete re-layout of the screen
        locate_all_l;
    end  




%---------------------------------------------------------------------------
function save_map_l
% Save a colormap to disk


    [file, path] = uiputfile('*.*');
    
    if (file ~= 0)
        filename = [path, file];
        
        gs = gs_get_l;
        
        DISK_MAP = gs.palette.color.map;
        save filename DISK_MAP;
        
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  END OF FILE ACCESS
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

