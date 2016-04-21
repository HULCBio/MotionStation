function cshelp(FigHandle,ParentHandle)
%CSHELP  Installs GUI-wide context sensitive help.
%
%   CSHELP(FIGHANDLE) installs context-sensitive (CS) help for the 
%   figure with handle FIGHANDLE.  To active CS help, type
%      set(handle(FIGHANDLE),'cshelpmode','on')
%   To turn it off, type
%      set(handle(FIGHANDLE),'cshelpmode','off')
%   When CS help is turned on, clicking on any object in the figure 
%   executes the figure's HelpFcn callback.  This callback function
%   can implement any desired context-sensitive help format.
%
%   CSHELP(FIGHANDLE,PARENTFIG) links the CS help for FIGHANDLE and
%   for the parent figure PARENTFIG so that enabling CS help in one
%   figure automatically enables it in the other.  By default, 
%   FIGHANDLE inherits the HELPFCN and HELPTOPICMAP values from 
%   PARENTFIG.  This is useful to create a GUI-wide CS help system.
%
%   See also HELPVIEW.

%   RE: CSHELP is an undocumented utility function.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $ $Date: 2002/04/15 03:27:09 $

% Parse input list
ni = nargin;
if ni<2 | ~ishandle(ParentHandle)
    ParentHandle = -1;  
end
    
% Add instance properties to support CS help
FigHandle = handle(FigHandle);
p = findprop(FigHandle,'CSHelpMode');
if isempty(p)
    p = schema.prop(FigHandle,'CSHelpMode','String');   % Mode (on/off)
    schema.prop(FigHandle,'CSHelpData','mxArray');      % Data container
end

% Initialize CS Help mode
FigHandle.CSHelpMode = 'off';

% Add listener to figure's CSHelpMode
lsnr = handle.listener(FigHandle,p,'PropertyPostSet',@LocalSwitchMode);

% Initialize data container
FigHandle.CSHelpData = struct(...
    'ButtonFunctions',[],...
    'EnabledControls',[],...
    'HitTestOff',[],...
    'HandleVisibleOff',[],...
    'Listener',lsnr);

% Link up with parent's CSHelpMode if parent supports CS help
if ishandle(ParentHandle)
    ParentHandle = handle(ParentHandle);
    pp = findprop(ParentHandle,'CSHelpMode');
    if ~isempty(pp)
        % Create two-way link with Parent's context-sensitive help
        lsnr(1,1) = handle.listener(ParentHandle,pp,...
            'PropertyPostSet',{@LocalSyncMode FigHandle});
        lsnr(1,2) = handle.listener(FigHandle,p,...
            'PropertyPostSet',{@LocalSyncMode ParentHandle});

	helpData = FigHandle.CSHelpData;
        helpData.Listener = [FigHandle.CSHelpData.Listener , lsnr];
	FigHandle.CSHelpData = helpData;
	
        % Inherit parent's HelpFcn, HelpTopicMap, and current CSHelpMode
        % RE: Beware that the parent may be in CS help mode when opening the child figure
        FigHandle.HelpFcn = ParentHandle.HelpFcn;
        FigHandle.HelpTopicMap = ParentHandle.HelpTopicMap;
        FigHandle.CSHelpMode = ParentHandle.CSHelpMode;
    end
end



%---------------------Local Functions----------------------


%%%%%%%%%%%%%%%%%%%%%
%%% LocalSyncMode %%%
%%%%%%%%%%%%%%%%%%%%%
function LocalSyncMode(hProp,event,FigHandle)
% Synchronizes Help mode with parent (affected object)

if isa(FigHandle,'hg.figure')  % Protect against deleted figures
    FigHandle.CSHelpMode = event.NewValue;
end


%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalSwitchMode %%%
%%%%%%%%%%%%%%%%%%%%%%%
function LocalSwitchMode(hProp,event)
% Switch CS help mode
FigHandle = event.AffectedObject;
hFig = double(FigHandle);  % HG handle
CSHelpData = FigHandle.CSHelpData;

switch event.NewValue  % new mode
case 'on'
    % Engaging CS help
    % Find all UI controls with Enable=on and make them inactive
    CSHelpData.EnabledControls = findall(hFig,'Type','uicontrol','Enable','on');
    set(CSHelpData.EnabledControls,'Enable','inactive');
    
    % Find all objects with HitTest='off' and make them selectable
    CSHelpData.HitTestOff = findall(hFig,'HitTest','off');
    set(CSHelpData.HitTestOff,'HitTest','on');    
    
    % Find all objects with HandleVisibility='off' and make them selectable
    CSHelpData.HandleVisibleOff = findall(hFig,'HandleVisibility','off');
    set(CSHelpData.HandleVisibleOff,'HandleVisibility','on');    
    
    % Save current ButtonDown and WindowButton functions
    CSHelpData.ButtonFunctions = get(FigHandle,...
        {'ButtonDownFcn','WindowButtonDownFcn','WindowButtonMotionFcn','WindowButtonUpFcn'});

    % Install CS Help callbacks 
    FigHandle.ButtonDownFcn = '';
    FigHandle.WindowButtonMotionFcn = '';
    FigHandle.WindowButtonUpFcn = '';
    FigHandle.WindowButtonDownFcn = {@LocalTopicHelp FigHandle};
    FigHandle.CSHelpData = CSHelpData;
    
    % Set the pointer
    setptr(hFig,'help');
    
case 'off'
    % Aborting CS help
    % Reenable UI controls and restore HitTest=off
    set(CSHelpData.EnabledControls,'Enable','on');
    set(CSHelpData.HitTestOff(ishandle(CSHelpData.HitTestOff)),'HitTest','off');    
    set(CSHelpData.HandleVisibleOff(ishandle(CSHelpData.HandleVisibleOff)),...
        'HandleVisibility','off');
    
    % Restore BDF and WBDF
    set(FigHandle,...
        {'ButtonDownFcn','WindowButtonDownFcn','WindowButtonMotionFcn','WindowButtonUpFcn'},...
        CSHelpData.ButtonFunctions);
    
    % Reset pointer
    set(hFig,'Pointer','arrow');
    
end


%%%%%%%%%%%%%%%%%%%%%%
%%% LocalTopicHelp %%%
%%%%%%%%%%%%%%%%%%%%%%
function LocalTopicHelp(hSrc,event,FigHandle)
% Shows help topic for selected object

% Evaluate HelpFcn
HelpFcn = get(FigHandle,'HelpFcn');
if length(HelpFcn)
    try
        if isa(HelpFcn,'char')
            % Callback string
            eval(HelpFcn);
        elseif isa(HelpFcn,'cell')
            % Function handle with arguments
            feval(HelpFcn{1},FigHandle,[],HelpFcn{2:end});
        else
            % Function handle or unknown
            feval(HelpFcn,FigHandle,[]);
        end
    end
end

% Short-circuit all buttondown callbacks
set(FigHandle,'CurrentObject',FigHandle);




    