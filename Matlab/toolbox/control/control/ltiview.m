function [ViewFig,ViewObj] = ltiview(varargin)
%LTIVIEW  Opens the LTI Viewer GUI.
%
%   LTIVIEW opens an empty LTI Viewer.  The LTI Viewer is an interactive
%   graphical user interface (GUI) for analyzing the time and frequency
%   responses of linear systems and comparing such systems.  See LTIMODELS
%   for details on how to model linear systems in the Control System Toolbox.
%
%   LTIVIEW(SYS1,SYS2,...,SYSN) opens an LTI Viewer containing the step
%   response of the LTI models SYS1,SYS2,...,SYSN.  You can specify a
%   distinctive color, line style, and marker for each system, as in
%      sys1 = rss(3,2,2);
%      sys2 = rss(4,2,2);
%      ltiview(sys1,'r-*',sys2,'m--');
%
%   LTIVIEW(PLOTTYPE,SYS1,SYS2,...,SYSN) further specifies which responses
%   to plot in the LTI Viewer.  PLOTTYPE may be any of the following strings
%   (or a combination thereof):
%        1) 'step'           Step response
%        2) 'impulse'        Impulse response
%        3) 'bode'           Bode diagram
%        4) 'bodemag'        Bode Magnitude diagram
%        5) 'nyquist'        Nyquist plot
%        6) 'nichols'        Nichols plot
%        7) 'sigma'          Singular value plot
%        8) 'pzmap'          Pole/Zero map
%        9) 'iopzmap'        I/O Pole/Zero map 
%   For example,
%      ltiview({'step';'bode'},sys1,sys2)
%   opens an LTI Viewer showing the step and Bode responses of the LTI
%   models SYS1 and SYS2.
%
%   LTIVIEW(PLOTTYPE,SYS,EXTRAS) allows you to specify the additional 
%   input arguments supported by the various response types.
%   See the HELP text for each response type for more details on the 
%   format of these extra arguments.  You can also use this syntax 
%   to plot the output of LSIM or INITIAL in the LTI Viewer, as in
%      ltiview('lsim',sys1,sys2,u,t,x0)
%
%   Two additional options are available for manipulating previously
%   opened LTI Viewers:
%
%   LTIVIEW('clear',VIEWERS) clears the plots and data from the LTI
%   Viewers with handles VIEWERS.
%
%   LTIVIEW('current',SYS1,SYS2,...,SYSN,VIEWERS) adds the responses
%   of the systems SYS1,SYS2,... to the LTI Viewers with handles VIEWERS.
%
%   See also STEP, IMPULSE, LSIM, INITIAL, (IO)PZMAP,
%            BODE(MAG), NYQUIST, NICHOLS, SIGMA.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.86.4.9 $  $Date: 2004/04/10 23:13:41 $

ni = nargin;
plottype = {};
currentflag = false;
argoffset = 0;
if ni > 0 & ischar(varargin{1})
    varargin{1} = {varargin{1}};  % convert first char argument to cellstr
end

% Process first string argument
if ni > 0 & iscellstr(varargin{1})
    FirstArg = varargin{1};
    switch FirstArg{1}
        case 'current'
            currentflag = true;
            ViewerHandles = varargin{end};
            varargin = varargin(2:end-1);
            plottype = {};
        case 'clear'
            LocalClearViewer(varargin{2});
            return
        otherwise
            plottype = FirstArg;
            varargin = varargin(2:end);
    end
    argoffset = 1;
end

% Plot Types checking
ValidTypes = ltiplottypes('Alias');
if length(plottype)>1 & ...
      (any(strcmpi('lsim',plottype)) | any(strcmpi('initial',plottype)))
   error('Cannot mix LSIM or INITIAL with other plot types.')
elseif ~isempty(setdiff(plottype,ValidTypes))
    error('PLOTTYPE must be a valid plot type string or plot type list.');
elseif length(plottype)>6
    error('PLOTTYPE may contain no more then six plot types.');
end
%
% Get Systems from Input List
try
    InNames = cell(length(varargin),1);
    for xx=1:length(varargin)
        InNames{xx} = inputname(argoffset + xx);
    end
    if length(plottype)==1
        % Single plot type: treat as call to corresponding command
        [Systems,Names,InputName,OutputName,PlotStyles,ExtraArg] = ...
        rfinputs(plottype{1},InNames,varargin{:});
    else
        [Systems,Names,InputName,OutputName,PlotStyles,ExtraArg] = ...
        rfinputs('unspecified',InNames,varargin{:});
        if ~isempty(ExtraArg) && length(plottype) ~= 1
            error('Extra input arguments are not applicable for this ltiview specification.');
        end
    end
catch
    rethrow(lasterror);
end

% Implements the Current option
if currentflag
    LocalCurrentViewer(Systems,Names,ViewerHandles);
    return
end
%
% Show waitbar
hWaitbar = waitbar(0,xlate('LTI Viewer is being launched. Please wait...'));
%
% Create an instance of the Viewer
ViewObj = viewgui.ltiviewer;

% Remove LSIM and INITIAL from available views
AvailableViews = ViewObj.AvailableViews;
ilsim = find(strcmpi('lsim',   {AvailableViews.Alias}));
iinit = find(strcmpi('initial',{AvailableViews.Alias}));
AvailableViews([ilsim;iinit]) = [];
ViewObj.AvailableViews = AvailableViews;
waitbar(0.25,hWaitbar);

% Process extra argument list
if length(ExtraArg)>0
    LocalCallWithExtras(ViewObj,plottype{1},ExtraArg);
end
%
% Create LTI Sources
src = handle([]);
for ct=1:length(Systems)
    src(ct,1) = resppack.ltisource(Systems{ct},'Name',Names{ct});
end
ViewObj.Systems = src;
waitbar(0.5,hWaitbar);
%
% Set CurrentViews
if isempty(plottype)
    plottype = {'step'};
end

ViewObj.setCurrentViews(plottype);
%
waitbar(0.75,hWaitbar);
% Set Viewer Visibility and store the Object handle
set(ViewObj.Figure,'Visible','on');
%
% To trigger exception for invalid data/plottype
ViewObj.send('ModelImport',ctrluis.dataevent(ViewObj,'ModelImport',src));
%
waitbar(1,hWaitbar);
% Set PlotStyles if any
for ct = find(cellfun('length',PlotStyles))
    ViewObj.setstyle(ViewObj.Systems(ct),PlotStyles{ct});
end
close(hWaitbar);
%
% Call the start-up message box
LocalStartUpMsgBox(ViewObj)
%
% Output args
if nargout
    ViewFig = double(ViewObj.Figure);
end


%--------------- LOCAL FUNCTIONS ----------------------------------
%
%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalStartUpMsgBox %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalStartUpMsgBox(this)
% Reads the cstprefs.mat file and shows start-up message box if required

h = this.Preferences.ToolboxPreferences;
if strcmp(h.StartUpMsgBox.LTIviewer,'on')
    Handles = startupdlg(this.Figure,'LTIviewer', h);
    set(Handles.Figure, 'Name', xlate('Getting Started with the LTI Viewer'));
    set(Handles.HelpBtn,'Callback', 'ctrlguihelp(''viewermainhelp'');');
    set(Handles.TextMsg,'String',{'The LTI Viewer is a graphical user interface that simplifies the analysis of linear, time-invariant systems.' ...
        ' ' ...
        'Click the Help button to find out more about the LTI Viewer.'});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCallWithExtras %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCallWithExtras(this,plottype,ExtraArg);
% Modifies list of Available Views based on the plottypes specified in the
% LTIVIEW calling sequence.

switch plottype
    case {'step','impulse'}
        if ~isempty(ExtraArg)
            this.Preferences.TimeVector = ExtraArg{1};
        end
    case {'bode','bodemag','sigma','nyquist','nichols'}
        if ~isempty(ExtraArg{1})
            f = ExtraArg{1};
            if iscell(f)
                fc = unitconv([f{:}],'rad/s',this.preferences.FrequencyUnits);
                f = {fc(1) fc(end)};
            else
                f = unitconv(f,'rad/s',this.preferences.FrequencyUnits);
            end
            this.Preferences.FrequencyVector = f;
        end
    case {'lsim','initial'}
      Names = ltiplottypes('Name');
      ind = find(strcmpi(plottype,ltiplottypes('Alias')));
      if strcmp(plottype, 'initial') && ~isempty(ExtraArg)
         this.Preferences.TimeVector = ExtraArg{1};
      end

      NewAvailableView = ...
         struct(...
         'Name', xlate(Names{ind}),...
         'Alias',plottype,...
         'CreateFcn',{{@createView this plottype, ExtraArg{:}}});
      this.AvailableViews = [this.AvailableViews;NewAvailableView];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalCurrentViewer %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalCurrentViewer(Systems,Names,Viewers);
% Adds systems in specified viewers
%----Update the specified LTI Viewers with the new systems

for ctViewer=1:length(Viewers)
    %---Is the argument a valid handle and does the userdata have the
    % viewgui object
    if ~ishandle(Viewers(ctViewer)) | ...
        ~isa(get(Viewers(ctViewer),'UserData'),'viewgui.ltiviewer')
        error('The CURRENT option requires valid LTI Viewer handles.')
    else
        %---Add the systems to the Viewer
        ViewerHandles = get(Viewers(ctViewer),'UserData');
        importsys(ViewerHandles,Names,Systems);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% LocalClearViewer %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalClearViewer(varargin);
% Clears systems in specified viewers

Viewers = varargin{end};
for ctViewer=1:length(Viewers)
    %---Is the argument a valid handle and does the userdata have the
    % viewgui object
    if ~ishandle(Viewers(ctViewer)) | ...
        ~isa(get(Viewers(ctViewer),'UserData'),'viewgui.ltiviewer')
        error('The CURRENT option requires valid LTI Viewer handles.')
    else
        %---Add the systems to the Viewer
        ViewerHandles = get(Viewers(ctViewer),'UserData');
        ViewerHandles.Systems = [];
    end
end

