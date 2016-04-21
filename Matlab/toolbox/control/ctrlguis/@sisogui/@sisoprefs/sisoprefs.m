function h = sisoprefs(Target)
%SISOPREFS  SISO Tool preferences object contructor
%
%   TARGET is an instance of the @sisotool root class.

%   Author(s): A. DiVergilio
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.21 $  $Date: 2002/04/10 05:07:32 $

%---Create class instance
h = sisogui.sisoprefs;

%---Get a copy of the toolbox preferences
h.ToolboxPreferences    = cstprefs.tbxprefs;

%---Copy relevent toolbox preferences
h.FrequencyUnits        = h.ToolboxPreferences.FrequencyUnits;
h.FrequencyScale        = h.ToolboxPreferences.FrequencyScale;
h.MagnitudeUnits        = h.ToolboxPreferences.MagnitudeUnits;
h.MagnitudeScale        = h.ToolboxPreferences.MagnitudeScale;
h.PhaseUnits            = h.ToolboxPreferences.PhaseUnits;
h.Grid                  = h.ToolboxPreferences.Grid;
h.TitleFontSize         = h.ToolboxPreferences.TitleFontSize;
h.TitleFontWeight       = h.ToolboxPreferences.TitleFontWeight;
h.TitleFontAngle        = h.ToolboxPreferences.TitleFontAngle;
h.XYLabelsFontSize      = h.ToolboxPreferences.XYLabelsFontSize;
h.XYLabelsFontWeight    = h.ToolboxPreferences.XYLabelsFontWeight;
h.XYLabelsFontAngle     = h.ToolboxPreferences.XYLabelsFontAngle;
h.AxesFontSize          = h.ToolboxPreferences.AxesFontSize;
h.AxesFontWeight        = h.ToolboxPreferences.AxesFontWeight;
h.AxesFontAngle         = h.ToolboxPreferences.AxesFontAngle;
h.AxesForegroundColor   = h.ToolboxPreferences.AxesForegroundColor;
h.CompensatorFormat     = h.ToolboxPreferences.CompensatorFormat;
h.ShowSystemPZ          = h.ToolboxPreferences.ShowSystemPZ;
h.LineStyle             = h.ToolboxPreferences.SISOToolStyle;
h.UnwrapPhase           = h.ToolboxPreferences.UnwrapPhase;
h.Target                = Target;
h.UIFontSize            = h.ToolboxPreferences.UIFontSize;
h.EditorFrame           = [];

%---Install listeners
pu = [findprop(h,'FrequencyUnits');...
      findprop(h,'MagnitudeUnits');...
      findprop(h,'PhaseUnits')];
ps = [findprop(h,'FrequencyScale');...
      findprop(h,'MagnitudeScale')];
psty = [findprop(h,'TitleFontSize');...
      findprop(h,'TitleFontSize');...
      findprop(h,'TitleFontWeight');...
      findprop(h,'TitleFontAngle');...
      findprop(h,'XYLabelsFontSize');...
      findprop(h,'XYLabelsFontWeight');...
      findprop(h,'XYLabelsFontAngle');...
      findprop(h,'AxesFontSize');...
      findprop(h,'AxesFontWeight');...
      findprop(h,'AxesFontAngle')];
h.Listeners = [...
        handle.listener(h,ps,'PropertyPostSet',@localSetScale);...
        handle.listener(h,pu,'PropertyPostSet',@localSetUnits);...
        handle.listener(h,psty,'PropertyPostSet',@localSetStyle);...
        handle.listener(h,findprop(h,'Grid'),'PropertyPostSet',@localSetGrid);...
        handle.listener(h,findprop(h,'AxesForegroundColor'),...
        'PropertyPostSet',{@localSetEditor 'LabelColor'});...
        handle.listener(h,findprop(h,'LineStyle'),...
        'PropertyPostSet',{@localSetEditor 'LineStyle'});...
        handle.listener(h,findprop(h,'CompensatorFormat'),...
        'PropertyPostSet',@localChangeFormat);...
        handle.listener(h,findprop(h,'ShowSystemPZ'),...
        'PropertyPostSet',@localShowSystemPZ);...
        handle.listener(Target.Figure,Target.Figure.findprop('CSHelpMode'),...
        'PropertyPostSet',@LocalSwitchMode)];


%-------------------- Listeners callbacks --------------------------------

% Set units (for all editors)
function localSetUnits(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
switch eventSrc.Name
case 'FrequencyUnits'
    FreqAxes = [sisodb.PlotEditors(2).Axes ; sisodb.PlotEditors(4).Axes];
    set(FreqAxes,'XUnits',eventData.NewValue);
    set(sisodb.PlotEditors([1 3]),'FrequencyUnits',eventData.NewValue);
    set(sisodb.TextEditors(1),'FrequencyUnits',eventData.NewValue);
case 'MagnitudeUnits'
    % RE: Not affecting Nichols editor
    % When going to dB with yscale = log, set Yscale='linear' to prevent 
    % Negative Data Ignored warnings 
    for ct=[2 4]
       % REVISIT: condense lines below
       Axes = sisodb.PlotEditors(ct).Axes;
       YScale = Axes.YScale;
       YUnits = Axes.YUnits;
       if strcmpi(eventData.NewValue, 'dB')
          YScale{1} = 'linear';
          Axes.YScale = YScale;
       end   
       YUnits{1} = eventData.NewValue;
       Axes.YUnits = YUnits;
    end
case 'PhaseUnits'
   for ct=[2 4]
      % REVISIT: condense lines below
      Axes = sisodb.PlotEditors(ct).Axes;
      YUnits = Axes.YUnits;
      YUnits{2} = eventData.NewValue;
      Axes.YUnits = YUnits;
   end
    sisodb.PlotEditors(3).Axes.XUnits = eventData.NewValue; 
end


% Set scales
function localSetScale(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
switch eventSrc.Name
case 'FrequencyScale'
    sisodb.PlotEditors(2).Axes.XScale = eventData.NewValue;
    sisodb.PlotEditors(4).Axes.XScale = eventData.NewValue;
case 'MagnitudeScale'
   for ct=[2 4]
      % REVISIT: condense lines below
      Axes = sisodb.PlotEditors(ct).Axes;
      YScale = Axes.YScale;
      YScale{1} = eventData.NewValue;
      Axes.YScale = YScale;
   end
end
    

% Set editor property (for all editors)
function localSetEditor(eventSrc,eventData,EditorProperty)
sisodb = eventData.AffectedObject.Target;
set(sisodb.PlotEditors,EditorProperty,eventData.NewValue);


% Set grid (for all editors)
function localSetGrid(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
for ct=1:length(sisodb.PlotEditors)
   sisodb.PlotEditors(ct).Axes.Grid = eventData.NewValue;
end


% Set label or axes style
function localSetStyle(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
switch lower(eventSrc.Name([1 2]))
case 'ti'
   % Title related
   Property = strrep(eventSrc.Name,'Title','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.TitleStyle,Property,eventData.NewValue);
   end
case 'xy'
   % XY label related
   Property = strrep(eventSrc.Name,'XYLabels','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.XLabelStyle,Property,eventData.NewValue);
      set(sisodb.PlotEditors(ct).Axes.YLabelStyle,Property,eventData.NewValue);
   end
case 'ax'
   % Axes style
   Property = strrep(eventSrc.Name,'Axes','');
   for ct=1:length(sisodb.PlotEditors)
      set(sisodb.PlotEditors(ct).Axes.AxesStyle,Property,eventData.NewValue);
   end
end    


% Set system pole/zero visibility 
function localShowSystemPZ(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
set(sisodb.PlotEditors([2 3]),'ShowSystemPZ',eventData.NewValue);


% Change compensator format
function localChangeFormat(eventSrc,eventData)
sisodb = eventData.AffectedObject.Target;
set(sisodb.LoopData.Compensator,'Format',eventData.NewValue);


% Enable/disable java GUI based on CSHelpMode
function LocalSwitchMode(eventSrc,eventData)
sisodb = eventData.AffectedObject.UserData;
if ~isempty(sisodb.Preferences.EditorFrame)
   if strcmpi(eventData.NewValue,'on')
      set(sisodb.Preferences.EditorFrame,'Enabled','off')
   else
      set(sisodb.Preferences.EditorFrame,'Enabled','on')
   end
end


