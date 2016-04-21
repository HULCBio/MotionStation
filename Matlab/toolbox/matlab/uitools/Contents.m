% Graphical user interface tools.
%
% GUI functions.
%   uicontrol  - Create user interface control.
%   uimenu     - Create user interface menu.
%   ginput     - Graphical input from mouse.
%   dragrect   - Drag XOR rectangles with mouse.
%   rbbox      - Rubberband box.
%   selectmoveresize   - Interactively select, move, resize, or copy objects.
%   waitforbuttonpress - Wait for key/buttonpress over figure.
%   waitfor    - Block execution and wait for event.
%   uiwait     - Block execution and wait for resume.
%   uiresume   - Resume execution of blocked M-file.
%   uistack    - Control stacking order of objects.
%   uisuspend  - Suspend the interactive state of a figure.
%   uirestore  - Restore the interactive state of a figure.
%
% GUI design tools.
%   guide       - Design GUI.
%   inspect     - Inspect object properties.
%   align       - Align uicontrols and axes.
%   propedit    - Edit property.
%  
% Dialog boxes.
%   axlimdlg     - Axes limits dialog box.
%   dialog       - Create dialog figure.
%   errordlg     - Error dialog box.
%   helpdlg      - Help dialog box.
%   imageview    - Show an image preview in a figure window.
%   inputdlg     - Input dialog box.
%   listdlg      - List selection dialog box.
%   menu         - Generate menu of choices for user input.
%   movieview    - Show movie in figure with replay button.
%   msgbox       - Message box.
%   pagedlg      - Page position dialog box.
%   pagesetupdlg - Page setup dialog.
%   printdlg     - Print dialog box.
%   printpreview - Display preview of figure to be printed.
%   questdlg     - Question dialog box.
%   soundview    - Show sound in figure and play.
%   uigetpref    - Question dialog box with preference support.
%   uigetfile    - Standard open file dialog box.
%   uiputfile    - Standard save file dialog box.
%   uigetdir     - Standard open directory dialog box.
%   uisetcolor   - Color selection dialog box.
%   uisetfont    - Font selection dialog box.
%   uiopen       - Show open file dialog and call OPEN on result.
%   uisave       - Show open file dialog and call SAVE on result.
%   uiload       - Show open file dialog and call LOAD on result.
%   waitbar      - Display wait bar.
%   warndlg      - Warning dialog box.
%
% Menu utilities.
%   makemenu   - Create menu structure.
%   menubar    - Computer dependent default setting for MenuBar property.
%   umtoggle   - Toggle "checked" status of uimenu object.
%   winmenu    - Create submenu for "Window" menu item.
%
% Toolbar button group utilities.
%   btngroup   - Create toolbar button group.
%   btnresize  - Resize button group.
%   btnstate   - Query state of toolbar button group.
%   btnpress   - Button press manager for toolbar button group.
%   btndown    - Depress button in toolbar button group.
%   btnup      - Raise button in toolbar button group.
%
% Preferences.
%   addpref    - Add preference.
%   getpref    - Get preference.
%   rmpref     - Remove preference.
%   setpref    - Set preference.
%   ispref     - Test for existence of preference.
%
% Miscellaneous utilities.
%   allchild   - Get all object children.
%   clipboard  - Copy and Paste strings to and from system clipboard.
%   edtext     - Interactive editing of axes text objects.
%   findall    - Find all objects.
%   findfigs   - Find figures positioned off screen.
%   getptr     - Get figure pointer.
%   getstatus  - Get status text string in figure.
%   hidegui    - Hide/unhide GUI.
%   listfonts  - Get list of available system fonts in cell array. 
%   movegui    - Move GUI to specified part of screen.
%   guihandles - Return a structure of handles.
%   guidata    - Store or retrieve application data.
%   overobj    - Get handle of object the pointer is over.
%   popupstr   - Get popup menu selection string.
%   remapfig   - Transform figure objects' positions.
%   setptr     - Set figure pointer.
%   setstatus  - Set status text string in figure.
%   uiclearmode - Clears the currently active interactive mode.

% Utilities.
%   btnicon    - Icon library for BTNGROUP.
%   fignamer   - Chooses next available figure name.
%   icondisp   - Display icons in BTNICON.
%   tabdlg     - Create and manage tabbed dialog box.
%   textwrap   - Return wrapped string matrix for given UI Control.
%
% Helper functions.
%   editmenufcn   - Figure edit menu.
%   filemenufcn   - Figure file menu.
%   guidefunc     - Guide.
%   menueditfunc  - Guide.
%   uisetpref     - Manages preferences used in UIGETPREF.
%   
% Grandfathered functions.
%   clruprop   - Remove user-defined property.
%   extent     - Obtains platform independent text extent property.
%   figflag    - True if figure is currently displayed on screen.
%   getuprop   - Get value of user-defined property.
%   layout     - Script which defines dialog box layout parameters.
%   menulabel  - Parse menu label for keyboard equivalent and accelerator keys.
%   setuprop   - Set user-defined property.

% Obsolete functions.
%   cbedit     - Edit callback.
%   ctlpanel   - Initialization of GUIDE.
%   hthelp     - Hypertext help utility.
%   htpp       - Hypertext help preprocessor.
%   loadhtml   - Load HTML for HTHELP.
%   matq2ws    - Helper script for matqdlg.
%   matqdlg    - Workspace transfer dialog box.
%   matqparse  - Dialog entry parser for matqdlg.
%   matqueue   - Creates and manipulates a figure-based matrix queue.
%   menuedit   - Edit menu.
%   printmenu  - Print pull-down menu structure to the command window.
%   ws2matq    - Helper script for matqdlg.

%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.77.4.3 $  $Date: 2003/04/07 04:16:13 $ 
