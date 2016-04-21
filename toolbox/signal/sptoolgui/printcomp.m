function printcomp(varargin) 
%PRINTCOMP Create and display a print preview of SPTool GUI components.

% Copyright 1988-2002 The MathWorks, Inc.
% $Date: 2002/04/15 00:03:56 $ $Revision: 1.16 $  

switch varargin{1}
    
case 'ClosePrevFig'
    % Close the invisible print preview figure window
    stale_hFigPrev = findobj('Tag','PrntPrev');
    if ishandle(stale_hFigPrev),
        close(stale_hFigPrev);
    end
    
    % The next 3 cases are selections from component's 'File' menu
case 'prev',       % Preview was selected
    % Handle help mode for uipushtool, TPK 6/26/99
    ud = get(gcbf,'userdata');
    if ud.pointer==2   % help mode
        spthelp('exit','printpreview')
        return
    end
    
    hFigPrev = create_preview(gcbf,'prev');
    set(hFigPrev,'Visible','on');
    
case 'prnt',       % Print was selected; don't show preview
    % Handle help mode for uipushtool, TPK 6/26/99
    ud = get(gcbf,'userdata');
    if ud.pointer==2   % help mode
        spthelp('exit','print')
        return
    end
    
    hFigPrev = create_preview(gcbf,'prnt');
    prnt_prev_fig(hFigPrev,'prnt');
    
case 'pgepos',     % Page Position selected
    hFigPrev = create_preview(gcbf,'pgepos');
    prnt_prev_fig(hFigPrev,'pgepos');
    
case 'prevprnt',   % "Print" ui was selected in preview figure
    % Print preview figure
    prnt_prev_fig(gcbf,'prevprnt');
    
case 'resizemenubar',
    % Resize menubar if preview window is resized
    prevInfoStruct = get(gcbf,'UserData');
    resizemenubar(prevInfoStruct.menubarhndls);
end 

%%%%%%%%%%%%%%%%%%%%%%%%
%   Subfunctions       %
%%%%%%%%%%%%%%%%%%%%%%%%


function hFigPrev = create_preview(gcbf,action)
% CREATE_PREVIEW Create an invisible figure containing the preview
%                of the figure to be printed.
%                
% The following logic is used to determine whether to create a new 
% preview figure or to use the existing preview figure.
%
% 1. If no preview figure exists create one.
% 2. If a preview figure exists and user has selected Page Setup or Print 
%    Preview, create a new preview (NOTE: this will override page setup
%    settings if user previously selected Page Setup.)
% 3. If a preview figure exists and user has selected Print then assume
%    user wants to print the existing preview figure (NOTE: the existing
%    preview figure was created because Page Setup was previously selected.
% 4. If a preview figure exists but it belongs to a different component
%    then the one currently being printed from, delete the existing 
%    print preview and create a new one.

% Cache component's figure handle.
hcomp = gcbf;

% Determine which component is being printed from.
compName = get(hcomp,'Name'); % Can be Signal Browser or Spectrum Viewer

% Add a command to close the preview figure to the SPTool component
% figure property DeleteFcn.  This ensures that any invisible preview
% figure window that is left behind is deleted when the tool is closed.
add_closePrev2delFcn(hcomp)

% Search for preview figure.
hFigPrev = findobj('Tag','PrntPrev');

prevFigName = [];
if ishandle(hFigPrev),
    % Find out from which component is the existing preview figure.
    % Using the Figure name instead of a tag to determine which component
    % is being printed.  Hence figure name of preview figure MUST contain
    % the figure name of the component (e.g., Signal Browser).
    prevFigName = get(hFigPrev,'Name');
    prevFigName = prevFigName(1:length(compName));
end

% Check if a preview figure exists and user selected the PRINT option.
% If so, print the existing preview figure window.
if isempty(hFigPrev) | ~ishandle(hFigPrev) | ~strcmp(action,'prnt') | ...
        ~strcmp(compName,prevFigName),
    
    % If user selected Page Setup or Print Preview OR if printing from a
    % new component then delete existing preview before creating a new one.
    if (~strcmp(action,'prnt') & ~isempty(hFigPrev)) | ...
            (~isempty(prevFigName) & ~strcmp(compName,prevFigName)),
        delete(hFigPrev);
    end
    
    % Get specific information from the given component 
    compInfoStruct = getcompinfo(hcomp);
    
    % Generate preview figure
    [hFigPrev, prevInfoStruct] = preview(compInfoStruct); 
    
    % Store the preview information in UserData of preview figure
    set(hFigPrev,'UserData',prevInfoStruct); 
    
    % Set units to normalized so axes resize correctly
    setaxesnorm(hFigPrev);
end

% end of create_preview
% ---------------------------------------------------------------------------------


function compInfoStruct = getcompinfo(hFig);
%GETCOMPINFO  Build a structure of information for one (at a time) of 
%             sptool's components for printing.  The handle of the 
%             component is the input argument.

showhid = get(0,'ShowHiddenHandles');
set(0,'ShowHiddenHandles','on');

% Get information common to all components
ud = get(hFig,'UserData'); 
compInfoStruct.name = get(hFig,'Name');
compInfoStruct.tag = get(hFig,'Tag');
compInfoStruct.pos = get(hFig,'Position'); 
compInfoStruct.prefs = ud.prefs; 
set(0,'ShowHiddenHandles',showhid); % Turn HiddenHandles back

% For all components but Filter Designer
if ~strcmp(compInfoStruct.tag, 'filtdes'), 
    if ~strcmp(compInfoStruct.tag, 'filtview'),
        compInfoStruct.opts(1).name = 'mainaxes'; % compInfoStruct.opts is an array of structures  
        compInfoStruct.opts(1).value =  ud.mainaxes;
        if ud.prefs.tool.ruler, 
            compInfoStruct.opts(end+1).name = 'ruler';  
            compInfoStruct.opts(end).value = ud.ruler; 
        end  
    else
        % Filter Viewer
        if ud.prefs.tool.ruler, 
            compInfoStruct.opts(1).name = 'ruler';  
            compInfoStruct.opts(1).value = ud.ruler; 
        else
            % Initialize structure field for the no ruler case
            compInfoStruct.opts(1).name = 'noruler';  
            compInfoStruct.opts(1).value = []; 
        end  
    end
end

switch compInfoStruct.tag
    
    % Get information specific to each component
case 'sigbrowse',
    if ud.prefs.tool.panner,
        compInfoStruct.opts(end+1).name = 'panner'; 
        compInfoStruct.opts(end).value = ud.panner; 
    end
    
case 'filtview',
    % Filter Viewer
    compInfoStruct.opts(end+1).name = 'axes';    
    compInfoStruct.opts(end).value = ud.ht.a;
    
case 'filtdes',
    % Filter Designer
    compInfoStruct.opts(1).name = 'axes';    
    compInfoStruct.opts(1).value = ud.Objects.fdax.h;
    compInfoStruct.opts(end+1).name = 'des';    
    compInfoStruct.opts(end).value = ud.ht;
    
case 'spectview',
    compInfoStruct.opts(end+1).name = 'spect';    
    compInfoStruct.opts(end).value = ud.spect;
    compInfoStruct.opts(end+1).name = 'methods';    
    compInfoStruct.opts(end).value = ud.methods;
    compInfoStruct.opts(end+1).name = 'lines';    
    compInfoStruct.opts(end).value = ud.lines; 
end 

% end of getcompinfo
% ---------------------------------------------------------------------------------


function [hFigPrev, prevInfoStruct] = preview(compInfoStruct)
%PREVIEW  Generate a print preview for a component of sptool.

% Create figure for preview
hFigPrev = figure('Position',compInfoStruct.pos, ...
    'Name',[compInfoStruct.name ' Print Preview'],...
    'NumberTitle','off',...
    'ResizeFcn','printcomp(''resizemenubar'')',...
    'Tag','PrntPrev',...
    'PaperPositionMode','auto',... 
    'IntegerHandle','off',...
    'MenuBar','none',...
    'HandleVisibility','on',...
    'Visible','off');

% Axes to place Box around entire preview figure
axes('Units','Norm','Position',[0 0 1 1],...
    'XTick',[],'YTick',[],'Box','on','Color','none');

% Remove the 'noruler' field
if strcmpi(compInfoStruct.opts(1).name, 'noruler'),
    compInfoStruct.opts(1) = [];
end

for i =1:length(compInfoStruct.opts),
    
    switch compInfoStruct.opts(i).name
        
    case 'mainaxes',          
        set(hFigPrev,'Position',compInfoStruct.pos); % Set preview position to component position
        % Copy mainaxes to preview figure
        hmaxes = copyobj(compInfoStruct.opts(i).value, hFigPrev); 
        set(hmaxes,'Units','Pixels','HandleVisibility','on','ButtonDownFcn',''); 
        
        % Clear 'ButtonDownFcn' for children of main axes (ruler lines)
        hchildMax = get(hmaxes,'Children');
        set(hchildMax,'ButtonDownFcn','');
        
        % Build a structure of preview information
        prevInfoStruct.prevItem(i).name = 'mainaxes';
        prevInfoStruct.prevItem(i).axhandle = hmaxes;
        prevInfoStruct.prevItem(i).pos = get(hmaxes,'Position');  
        
    case 'ruler',
        % Get Ruler Values       
        [rulervals, rulerlbls] = getrulervals(compInfoStruct.opts(i).value); 
        
        % Create frame (by making an axes) to display ruler values
        hraxes = axes('Ytick',[],'Xtick',[],'Visible','off',...  
            'Box','on','Color','none','Tag','ruler',...
            'Units','Pixels');
        hrxlabel = xlabel('Marker Values'); 
        
        % Create text to display ruler values and labels.
        hrvalstxt = createrulervalstxt(hraxes, rulervals, rulerlbls);
        
        prevInfoStruct.prevItem(i).name = 'ruler'; 
        prevInfoStruct.prevItem(i).axhandle = hraxes;
        prevInfoStruct.prevItem(i).pos = get(hraxes,'Position'); 
        
        % Ruler specific information
        prevInfoStruct.rulerinfo.rulervals = rulervals;
        prevInfoStruct.rulerinfo.rulerlbls = rulerlbls;
        prevInfoStruct.rulerinfo.hrvalstxt = hrvalstxt;      
        
    case 'panner',
        % Copy panaxes to preview figure
        hpaxes = copyobj(compInfoStruct.opts(i).value.panaxes, hFigPrev); 
        set(hpaxes,'Units','Pixels');
        % Change color of panner xlabel because when copied to preview
        % it becomes white. See private/panner.m  
        hxlbl = get(hpaxes,'Xlabel');
        set(hxlbl,'Color',[0 0 0]);      
        
        prevInfoStruct.prevItem(i).name = 'panaxes';
        prevInfoStruct.prevItem(i).axhandle = hpaxes; 
        prevInfoStruct.prevItem(i).pos = get(hpaxes,'Position');
        
    case 'spect',
        [hspecs, specStrs] = getSpecInfo(compInfoStruct.opts(:));
        
        prevInfoStruct.specinfo.hspecs = hspecs;
        prevInfoStruct.specinfo.specStrs = specStrs;
        
    case 'axes',       
        axhndl = compInfoStruct.opts(i).value;
        allhaxes = [];
        for j=1:length(axhndl)
            % Copy axes to preview figure
            haxes = copyobj(axhndl(j), hFigPrev); 
            % Clear 'ButtonDownFcn' for children of axes (ruler lines)
            hchildMax = get(haxes,'Children');
            set(hchildMax,'ButtonDownFcn','');
            allhaxes = [allhaxes haxes];
        end
        set(allhaxes,'Units','Pixels','HandleVisibility','on','ButtonDownFcn',''); 
        
        % Build a structure of preview information
        prevInfoStruct.prevItem(i).name = 'axes';
        prevInfoStruct.prevItem(i).axhandle = allhaxes;
        prevInfoStruct.prevItem(i).pos = get(allhaxes,'Position'); 
        
    case 'des',
        Fs = get(compInfoStruct.opts(i).value.FsEdit, 'String');
        filtername = get(compInfoStruct.opts(i).value.filtMenu, 'String');
        % Build a structure of preview information
        prevInfoStruct.designinfo.h = findobj(axhndl, 'tag', 'response');
        prevInfoStruct.designinfo.Strs = [char(filtername) ' : Fs = ', Fs];
    end
end

% Set position of preview information being printed
setpos(hFigPrev, prevInfoStruct);

% Turn on the "Print" and "Close" uicontrols in the preview figure
prevInfoStruct.menubarhndls = menubar_on(hFigPrev);

% end of preview
% ---------------------------------------------------------------------------------


function resizemenubar(menubar_hndls)
%RESIZEMENUBAR  Resizes the preview menubar when window is resized. 

% Get specific information from the preview figure
hFigPrev = gcbf;
old_units = get(hFigPrev,'Units');
set(hFigPrev,'Units','pixels');
figpos = get(hFigPrev,'Position');

% Set the new positions of the uicontrols
uibarpos = [2, figpos(4)-20, figpos(3)-3, 20];
set(menubar_hndls.huibar ,'Position',uibarpos);

uiprntpos = [uibarpos(1)+10, figpos(4)-20, 50, 20];
set(menubar_hndls.huiprnt,'Position',uiprntpos);

uiclsepos = [uiprntpos(1)+uiprntpos(3)+10, figpos(4)-20, 50, 20];
set(menubar_hndls.huiclse,'Position',uiclsepos);

set(hFigPrev,'Units', old_units);

% end of resizemenubar
% ---------------------------------------------------------------------------------


function h = menubar_on(hFigPrev)
%MENUBAR_ON  Uicontrols for print and close in the preview figure.


h.huibar = uicontrol(hFigPrev,...
    'Style','text',...
    'Tag','pprevbarui');

h.huiprnt = uicontrol(hFigPrev,...
    'Style','Push',...
    'String','Print...',...
    'Tag','pprevui',...
    'CallBack','printcomp(''prevprnt'')');

h.huiclse = uicontrol(hFigPrev,...
    'Style','Push',...
    'String','Close',...
    'Tag','ppcloseui',...
    'CallBack','closereq;');

resizemenubar(h);

% end of menubar_on
% ---------------------------------------------------------------------------------


function [rulervals, rulerlbls] = getrulervals(rulerstruct)
%GETRULERVALS  Get ruler values to display.

field_name = fieldnames(rulerstruct.value);
rulervals = []; % Initialize ruler value 
rulerlbls = {}; % and label cell arrays

for i = 1:length(field_name),
    if ~isnan(getfield(rulerstruct.value,field_name{i})), % Get all non-NaN values
        rulervals(end+1) = getfield(rulerstruct.value,field_name{i}); 
        rulerlbls{end+1} = field_name{i}; 
    end
end

% Need to check if 'type' is track and not display last value and label.
% There's a bug in Sigbrowse that doesn't set the slope value to NaN when not
% in slope mode.
if strcmp(rulerstruct.type, 'track') & length(field_name)==length(rulervals),
    rulervals = rulervals(1:end-1); % All but the last (for the dydx case)
    rulerlbls = rulerlbls(1:end-1); %  "   "  last label
end

% Need to check if 'type' is slope and display the last label as "m" and not "dydx."
if strcmp(rulerstruct.type, 'slope') 
    rulerlbls{end} = 'm'; 
end


% end of getrulervals
% ---------------------------------------------------------------------------------


function hrvalstxt = createrulervalstxt(hraxes, rulervals, rulerlbls)
%CREATERULERVALSTXT Creates the text objects to display the Ruler values.

for k = 1:length(rulervals),
    hrvalstxt(k) = text(10*k, 20, [rulerlbls{k} ': ' num2str(rulervals(k),4)]);
    set(hrvalstxt(k),'Visible','off','Units','Pixels');
end

% end of createrulervalstxt
% ---------------------------------------------------------------------------------


function prnt_prev_fig(hndl_prev, prnt_option)
%PRNT_PREV_FIG Prints the preview figure.

% Need to turn visiblity off for uicontrols (or else the figure is displayed)
prevInfoStruct = get(hndl_prev,'UserData');
menubar_off(prevInfoStruct.menubarhndls);

if strcmp(prnt_option,'pgepos'),
    dlg = pagesetupdlg(hndl_prev);
    % Leave the invisible preview figure open so that when the user
    % actually selects print the changes made in the page setup dialog 
    % box will take effect (in the printout).
else
    dlg = printdlg(hndl_prev);
    
    % On UNIX platforms this function executes asynchronously, while on PCWIN 
    % it's executed synchronously.  Therefore, for UNIX we must add "close
    % preview figure" to the dialog box DeleteFcn callback so that the 
    % preview figure is closed when the user dismisses the print dialog box.
    % While for PCWIN we can simply issue the command, to close preview figure,
    % right after the call to printdlg because ONLY after the dialog box has 
    % been dismissed by the user will the close command be executed.
    %
    % Also, the following code should be executed if the HG pagesetupdlg 
    % function was called - we want to delete the preview figure ONLY 
    % after the page setup dialog box has been dismissed by the user.
    %
    % As of R12, printdlg and pagesetupdlg will return a:
    % - nonempty value, which means the old HG dialog was launched and 
    % it returns the dialog's handle (which we need to delete).
    % or 
    %  - an empty value, which means the dialog came and went and is no longer
    % available - either because it was a native PC dialog or because it was a
    % Java dialog.
    %
    if ~isempty(dlg), 
        add_closePrev2delFcn(dlg)
    else 
        % Do it this way because printdlg doesn't return a handle on the PC.
        close(hndl_prev);
    end
end

% end of prnt_prev_fig
% ---------------------------------------------------------------------------------


function add_closePrev2delFcn(hFig)
%ADD_CLOSEPREV2DELFCN Prepends a command to close the preview figure to
%                     to the figure's (specified by the input handle h)
%                     DeleteFcn property.

% Cache the preview figure's DeleteFcn string (if one exists)
oldDelFcn = get(hFig,'DeleteFcn');

% Prepend a command (to close the preview figure) to the print or pagesetup 
% dialog figure's DeleteFcn string.
newDelFcn = ['printcomp(''ClosePrevFig''); ',oldDelFcn];
set(hFig,'DeleteFcn',newDelFcn);

% end of add_closePrev2delFcn
% ---------------------------------------------------------------------------------

function menubar_off(menubar_hndls)
%MENUBAR_OFF  Turn off visibility of the "Print" and "Close" uicontrols. 
%            
set(menubar_hndls.huibar,'Visible','off');
set(menubar_hndls.huiprnt,'Visible','off');
set(menubar_hndls.huiclse,'Visible','off');

% end of menubar_off
% ---------------------------------------------------------------------------------


function  setaxesnorm(hndl_prev);
%SETAXESNORM Set units to normalized so axes resize correctly

set(hndl_prev,'Units','Norm');

prevInfoStruct = get(hndl_prev,'UserData');
set([prevInfoStruct.prevItem(:).axhandle], 'Units','Norm'); % Mainaxes, panaxes, and ruler

if isfield(prevInfoStruct,'rulerinfo'),
    set([prevInfoStruct.rulerinfo.hrvalstxt], 'Units','Norm');
end

% end of setaxesnorm
% ---------------------------------------------------------------------------------


function setpos(hFigPrev, previnfo)
%SETPOS  Sets the position of the different information being printed.

% These positions will be set later depending on whether or not these items 
% will be printed; Please do not change these values.
ruler_ax_pos = [0 0 0 0];
panner_ax_pos = [0 0 0 0];
space_between_ax = 20;  % Vertical spacing between axes

% Get component position 
figpos = get(hFigPrev,'Position');

% Set dimensions for items
main_ax_left_edge = 57; 
main_ax_bottom_edge = 28;
main_ax_wdth = figpos(3)-100; 
main_ax_hght = figpos(4)-75;% 325; 
main_ax_pos = [main_ax_left_edge main_ax_bottom_edge main_ax_wdth main_ax_hght]; 

% Determining what items exist and their respective widths and heights
for indx = 1:length(previnfo.prevItem),
    switch previnfo.prevItem(indx).name
        
    case 'mainaxes',
        hmainaxes = (previnfo.prevItem(indx).axhandle);
        
    case 'ruler',
        ruler_ax_pos(4) = 25; % Need height (arbitrary) to determine how much to move up others
        hruleraxes = (previnfo.prevItem(indx).axhandle);
        
    case 'panaxes',
        pos = previnfo.prevItem(indx).pos; 
        panner_ax_pos(4) = pos(4);
        hpanner = (previnfo.prevItem(indx).axhandle);
        
    case 'axes',
        haxes = (previnfo.prevItem(indx).axhandle);
        
    end
end
% Vertical space multiplier
vspace_multi = sum(([main_ax_pos(2) ruler_ax_pos(4) panner_ax_pos(4)]~=0))-1;

% Set the positions of items that exist

% Offset for mainaxes Y position and height relative to the other items
offset = main_ax_pos(2)+ruler_ax_pos(4)+panner_ax_pos(4)+(vspace_multi*space_between_ax);
main_ax_pos = [main_ax_left_edge main_ax_bottom_edge+offset main_ax_wdth main_ax_hght-offset];
if exist('hmainaxes'),
    set(hmainaxes,'Position', main_ax_pos);
end

if exist('hruleraxes'), % If rulers are selected
    set(hruleraxes,'Position',[main_ax_left_edge main_ax_bottom_edge main_ax_wdth ruler_ax_pos(4)],...
        'Visible','on');
    
    % Set the positions for the text of ruler values based on the ruler axes
    ruler_pos = get(hruleraxes,'Position');    
    horzspace = (ruler_pos(3)-20)/length(previnfo.rulerinfo.rulervals); % Subtract 20 from Ruler axes
    ypos = ruler_pos(4)/2;                                              % width to make sure values appear 
    for k = 1:length(previnfo.rulerinfo.rulervals),                     % within axes
        xpos(k) = 7 + (k-1)*horzspace;
        set(previnfo.rulerinfo.hrvalstxt(k),'Position',[xpos(k) ypos],'Visible','on');
    end    
end

if exist('hpanner'), % If panner is selected
    panner_bottom_edge = main_ax_bottom_edge + ruler_ax_pos(4) + (vspace_multi-1)*space_between_ax;
    set(hpanner,'Position',[main_ax_left_edge panner_bottom_edge main_ax_wdth panner_ax_pos(4)]);
end

if exist('haxes'),
    haxes = haxes(strmatch('on',get(haxes, 'Visible')));
    % Number of visible axes
    N = length(haxes);
    for i=1:N,
        % Y rescale
        oldpos = get(haxes(i), 'Position');
        new_ax_hgt = 0.9*oldpos(4);
        new_ax_bottom_edge = oldpos(2);
        if any(N==[2 3] & i<=N-1) | (N==5 & i~=3) | (N==6 & i~=[3 6]),
            new_ax_bottom_edge = 0.95*oldpos(2);
        elseif (N==4 & i~=[2 4]),
            new_ax_bottom_edge = 0.94*oldpos(2);
        end
        % Set position of visible axes
        switch N
        case 1,
            set(haxes(i), 'Position', main_ax_pos);
        case 2,
            set(haxes(i), 'Position', [main_ax_left_edge new_ax_bottom_edge main_ax_wdth new_ax_hgt]);
        case 3,
            set(haxes(i), 'Position', [main_ax_left_edge new_ax_bottom_edge main_ax_wdth new_ax_hgt]);
        case {4,5,6}
            if i<=round(N/2),
                set(haxes(i), 'Position', [main_ax_left_edge new_ax_bottom_edge 0.45*main_ax_wdth new_ax_hgt]);
            else
                set(haxes(i), 'Position', [main_ax_left_edge+0.55*main_ax_wdth new_ax_bottom_edge 0.45*main_ax_wdth new_ax_hgt]);
            end
        end
        % Pole/Zero Axe
        if strcmp(get(haxes(i),'tag'),'pzaxes') | strcmp(get(haxes(i),'tag'),'pzax')
            apos = get(haxes(i),'Position');
            dr = get(get(haxes(i),'xlabel'),'userdata');
            if ~isempty(dr)
                xlim = dr(1:2);
                ylim = dr(3:4);
            else
                xlim = [-1 1];
                ylim = [-1 1];
            end
            [newxlim,newylim] = newlims(apos,xlim,ylim);
            
            set(haxes(i),'xlim',newxlim,'ylim',newylim,...
                'DataAspectRatio',[1 1 1],...
                'PlotBoxAspectRatio',apos([3 4 4]))
        end
    end
end

% Spectrum Viewer: Need to put legend on axes after the main axes position is set
if isfield(previnfo, 'specinfo'),
    prevFont = get(hmainaxes,'FontName'); % Change FontName so that strings in legend
    set(hmainaxes,'FontName','Courier');  % line up properly.   
    
    % Cache state of figure visibility
    visState = get(get(hmainaxes,'parent'),'visible');
    
    % Call legend here instead of in the "preview" so that legend is positioned correctly
    legend(hmainaxes, previnfo.specinfo.hspecs, previnfo.specinfo.specStrs);
    
    % Legend makes an invisible figure visible, so workaround that.
    set(get(hmainaxes,'parent'),'visible',visState);
    set(hmainaxes,'FontName',prevFont);
end

% Filter designer: Need to put legend on axes after the main axes position is set
if isfield(previnfo, 'designinfo'),
    prevFont = get(haxes,'FontName'); % Change FontName so that strings in legend
    set(haxes,'FontName','Courier');  % line up properly.   
    
    % Cache state of figure visibility
    visState = get(get(haxes,'parent'),'visible');
    
    % Call legend here instead of in the "preview" so that legend is positioned correctly
    if ~isempty(previnfo.designinfo.h),
        legend(haxes, previnfo.designinfo.h, previnfo.designinfo.Strs);
    else
        legend(haxes, previnfo.designinfo.Strs);
    end
    
    % Legend makes an invisible figure visible, so workaround that.
    set(get(haxes,'parent'),'visible',visState);
    set(haxes,'FontName',prevFont);
end

% end of setpos
% ---------------------------------------------------------------------------------


function [newxlim,newylim] = newlims(apos,xlim,ylim);
%NEWLIMS New limits for Pole/Zero axes

dx = diff(xlim);
dy = diff(ylim);

if dx * apos(4)/apos(3) >= dy   % Snap to the requested x limits, expand y to fit
    newxlim = xlim;
    newylen = apos(4)/apos(3) * dx;
    newylim = mean(ylim) + [-newylen/2 newylen/2];
else
    newylim = ylim;
    newxlen = apos(3)/apos(4) * dy;
    newxlim = mean(xlim) + [-newxlen/2 newxlen/2];
end

if diff(newxlim) <= 0
    newxlim = xlim;
end
if diff(newylim) <= 0
    newylim = ylim;
end

% end of newlims
% ---------------------------------------------------------------------------------


function [hspecs, specStrs] = getSpecInfo(spectrumStruct)
%GETSPECINFO    Get the spectrum legend information.

% Index for "spect", "lines", and "methods" 
indxs = strmatch('spect',{spectrumStruct(:).name});
indxl = strmatch('lines',{spectrumStruct(:).name});
indxm = strmatch('methods',{spectrumStruct(:).name});

% Get spectra handles, labels(i.e. spect1, spect2, ...) and method name
for h = 1:length(spectrumStruct(indxs).value),
    hspecs(h) = spectrumStruct(indxl).value(h).h;
    Lbl{h} = spectrumStruct(indxs).value(h).label;
    methodName(h) = spectrumStruct(indxs).value(h).specs.methodName(spectrumStruct(indxs).value(h).specs.methodNum);
    
    % Get index for current "Method Name" from ud.methods(:).methodName 
    indxmethNam = strmatch(methodName{h}, {spectrumStruct(indxm).value(:).methodName});
    
    % Find index for "Nfft" label from ud.methods(:).label
    % Check if "methodName" is "Welch" or "MUSIC" and set the Index for the Nfft Label 
    % manually.  There is a bug (geck # 40830) with the ud.methods structure which 
    % doesn't allow strmatch to find "Nfft" for these two cases.
    if strcmp(methodName{h}, 'Welch'),
        indxNfftLbl = 1;                % First parameter down from "Method"
    elseif strcmp(methodName{h}, 'MUSIC')
        indxNfftLbl = 3;                % third   "         "    "    "
    else
        indxNfftLbl = strmatch('Nfft', spectrumStruct(indxm).value(indxmethNam).label);
    end
    
    % Actual Nfft value
    numfft{h} = spectrumStruct(indxs).value(h).specs.valueArrays{spectrumStruct(indxs).value(h).specs.methodNum}{indxNfftLbl};
end

% Pad strings with spaces so they line up correctly in the legend
Lbl = str2mat(Lbl);
methodName = str2mat(methodName);
numfft = str2mat(numfft); 

[M, N] = size(Lbl); % M (number of rows in legend)
for k = 1:M,
    specStrs{k} = [Lbl(k,:) ': ' methodName(k,:) ': Nfft = ' num2str(numfft(k,:))]; 
end

% end of getSpecInfo
% ---------------------------------------------------------------------------------

% [EOF] printcomp.m
