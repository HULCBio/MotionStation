function h = ltiplot(ax,PlotType,InputNames,OutputNames,Prefs,varargin)
%LTIPLOT  Construct LTI plot using @resppack.
%
%   H = LTIPLOT(AX,PlotType,InputNames,OutputNames,Preferences) where
%     * AX is an HG axes handle
%     * PlotType is the response type
%     * InputNames and OutputNames are the I/O names (specify axes grid size)
%     * Preferences is a preference object for initializing the axes style.

%   Author(s): Adam DiVergilio, P. Gahinet, B. Eryilmaz
%   Revised  : Kamesh Subbarao, 10-15-2001
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.53.4.4 $ $Date: 2004/04/10 23:14:46 $

h = gcr(ax);  % is AX already associated with a response plot?
NewPlot = strcmp(get(ax,'NextPlot'),'replace');

if NewPlot
  % Clear any existing response plot upfront (otherwise style
  % settings below get erased by CLA in respplot/check_hold)
  if ~isempty(h)
    cla(h.AxesGrid,handle(ax))  % speed optimization
  end
  
  % Release manual limits and hide axis for optimal performance
  % RE: Manual negative Xlim can cause warning for BODE (not reset by clear)
  set(ax,'Visible','off','XlimMode','auto','YlimMode','auto')
end

% Style settings specific to LTI plots
newRespPlot = NewPlot || isempty(h);
if newRespPlot
  % Apply preferences to AX
  set(ax,...
      'XGrid',      Prefs.Grid,...
      'YGrid',      Prefs.Grid,...
      'XColor',     Prefs.AxesForegroundColor,...
      'YColor',     Prefs.AxesForegroundColor,...
      'FontSize',   Prefs.AxesFontSize,...
      'FontWeight', Prefs.AxesFontWeight,...
      'FontAngle',  Prefs.AxesFontAngle,...
      'Selected',   'off')
  set(get(ax,'Title'),...
      'FontSize',  Prefs.TitleFontSize,...
      'FontWeight',Prefs.TitleFontWeight,...
      'FontAngle', Prefs.TitleFontAngle)
  set([get(ax,'XLabel'),get(ax,'YLabel')],...
      'Color',[0 0 0],...
      'FontSize',  Prefs.XYLabelsFontSize,...
      'FontWeight',Prefs.XYLabelsFontWeight,...
      'FontAngle', Prefs.XYLabelsFontAngle)
end

% Create plot
GridSize = [length(OutputNames) , length(InputNames)];  % generic case
Settings = {'InputName',  InputNames, ...
      'OutputName', OutputNames,...
      'Tag', PlotType};
Preferences = [];
switch PlotType
   case 'bode'
      h = resppack.bodeplot(ax, GridSize, Settings{:}, varargin{:});
      localSetBodePrefs(h,Prefs)
      Preferences = struct('UnwrapPhase', Prefs.UnwrapPhase);
   case 'impulse'
      h = resppack.timeplot(ax, GridSize, Settings{:}, varargin{:});
      h.AxesGrid.Title = 'Impulse Response';
      Preferences = struct('RiseTimeLimits', Prefs.RiseTimeLimits, ...
         'SettlingTimeThreshold', Prefs.SettlingTimeThreshold);
   case 'initial'
      h = resppack.simplot(ax,GridSize(1),...
         'OutputName', OutputNames, 'Tag', PlotType, varargin{:});
      h.AxesGrid.Title = 'Response to Initial Conditions';
   case 'iopzmap'
      h = resppack.pzplot(ax, GridSize,...
         Settings{:}, 'FrequencyUnits', Prefs.FrequencyUnits, varargin{:});  
   case 'lsim'
      h = resppack.simplot(ax, GridSize(1),...
         'OutputName', OutputNames, 'Tag', PlotType, varargin{:});
      h.AxesGrid.Title = 'Linear Simulation Results';
      h.setInputWidth(length(InputNames));
      h.Input.ChannelName = InputNames;
   case 'nichols'
      h = resppack.nicholsplot(ax, GridSize, Settings{:}, varargin{:});
      localSetNicholsPrefs(h,Prefs)
      Preferences = struct('UnwrapPhase', Prefs.UnwrapPhase);
   case 'nyquist'
      h = resppack.nyquistplot(ax, GridSize, Settings{:},...
         'FrequencyUnits', Prefs.FrequencyUnits);
   case 'pzmap'
      h = resppack.mpzplot(ax,'Tag', PlotType,...
         'FrequencyUnits', Prefs.FrequencyUnits, varargin{:});  
   case 'rlocus'
      h = resppack.rlplot(ax,'Tag', PlotType,...
         'FrequencyUnits', Prefs.FrequencyUnits, varargin{:});  
   case 'sigma'
      h = resppack.sigmaplot(ax, 'Tag', PlotType, varargin{:});  
      localSetSigmaPrefs(h,Prefs)
   case 'step'
      h = resppack.timeplot(ax, GridSize, Settings{:}, varargin{:});
      h.AxesGrid.Title = 'Step Response';
      Preferences = struct('RiseTimeLimits', Prefs.RiseTimeLimits, ...
         'SettlingTimeThreshold', Prefs.SettlingTimeThreshold);
end

% Initialize characteristics preferences only for new plots
if newRespPlot && ~isempty(Preferences)
   h.Preferences = Preferences;
end

% Delete datatips when the axis is clicked
set(allaxes(h),'ButtonDownFcn',{@LocalAxesButtonDownFcn h}) %Temporary workaround
%set(allaxes(h),'ButtonDownFcn',@(eventsrc,y) defaultButtonDownFcn(h,eventsrc))

% Control cursor and datatip popups over characteristic markers
% REVISIT: remove this code whem MouseEntered/Exited event available
fig = h.AxesGrid.Parent;
if isempty(get(fig,'WindowButtonMotionFcn'))
   set(fig,'WindowButtonMotionFcn',@hoverfig)
   % Customize datacursor to use datatip style and not
   % cursor window
   hTool = datacursormode(fig);
   %% Set default Z-Stacking and datatip styles
   set(hTool,'EnableZStacking',true);
   set(hTool,'ZStackMinimum',10);
   set(hTool,'DisplayStyle','datatip');
end

% Limit management
if any(strcmp(PlotType, {'step','impulse','initial'}))
   L = handle.listener(h.AxesGrid, 'PreLimitChanged', @LocalAdjustSimHorizon);
   set(L, 'CallbackTarget', h);
   h.addlisteners(L);
end

%------------------------------------------------------------------------%
% Purpose: Setting the IONames properties to the Plot
%------------------------------------------------------------------------%
set([h.AxesGrid.RowLabelStyle; h.AxesGrid.ColumnLabelStyle],...
   'FontSize',  Prefs.IOLabelsFontSize,...
   'FontWeight',Prefs.IOLabelsFontWeight,...
   'FontAngle', Prefs.IOLabelsFontAngle);
%------------------------------------------------------------------------%
% Purpose: Recompute responses to span the x-axis limits
%------------------------------------------------------------------------%
function LocalAdjustSimHorizon(this, eventdata)
Responses = this.Responses;
Tfinal = max(getfocus(this));
for ct = 1:length(Responses)
   DataSrc = Responses(ct).DataSrc;
   if ~isempty(DataSrc)
      try
         % Read plot type (step, impulse, or initial) from Tag 
         % (needed for step+hold+impulse)
         UpdateFlag = DataSrc.fillresp(Responses(ct),Tfinal);
         if UpdateFlag
            draw(Responses(ct))
         end
      end
   end
end


function localSetBodePrefs(h,Prefs)
% Initializes Bode plot units and scales from CST Prefs
h.AxesGrid.XUnits =  Prefs.FrequencyUnits;
h.AxesGrid.XScale =  Prefs.FrequencyScale;
h.AxesGrid.YUnits = {Prefs.MagnitudeUnits ; Prefs.PhaseUnits};
h.AxesGrid.YScale = {Prefs.MagnitudeScale;h.AxesGrid.YScale{2}};


function localSetNicholsPrefs(h,Prefs)
% Initializes Nichols plot units from CST Prefs
h.FrequencyUnits  = Prefs.FrequencyUnits;
h.AxesGrid.XUnits = Prefs.PhaseUnits;


function localSetSigmaPrefs(h,Prefs)
% Initializes SV plot units from CST Prefs
h.AxesGrid.XUnits = Prefs.FrequencyUnits;
h.AxesGrid.XScale = Prefs.FrequencyScale;
h.AxesGrid.YUnits = Prefs.MagnitudeUnits;
h.AxesGrid.YScale = Prefs.MagnitudeScale;

% Temporary workaround
% ----------------------------------------------------------------------------% 
% Purpose: Axes callback to delete datatips when clicked 
% ----------------------------------------------------------------------------% 
function LocalAxesButtonDownFcn(EventSrc,EventData,RespPlot)
% Axes ButtonDown function
% Process event
switch get(get(EventSrc,'Parent'),'SelectionType')
    case 'normal'
        PropEdit = PropEditor(RespPlot,'current');  % handle of (unique) property editor
        if ~isempty(PropEdit) & PropEdit.isVisible
            % Left-click & property editor open: quick target change
            PropEdit.setTarget(RespPlot);
        end
        % Get the cursor mode object
        hTool = datacursormode(ancestor(EventSrc,'figure'));
        % Clear all data tips
        target = handle(EventSrc);
        if isa(target,'axes')
            removeAllDataCursors(hTool,target);
        end
    case 'open'
        % Double-click: open editor
        if usejava('MWT')
            PropEdit = PropEditor(RespPlot);
            PropEdit.setTarget(RespPlot);
        end
end