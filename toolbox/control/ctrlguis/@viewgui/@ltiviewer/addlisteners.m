function addlisteners(this,L)
%  ADDLISTENERS  Installs listeners for @ltiviewer class.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.17.4.2 $  $Date: 2003/01/07 19:34:13 $

if nargin==1
    % Initialization
    generic_listeners(this)
    
    % Add @ltiviewer specific listeners
    % PreSet listener for changes in system list (this.Systems)
    L = handle.listener(this,findprop(this,'Systems'),'PropertyPreSet',{@LocalSystemPreSet this});
    
    % PostSet listeners for time/frequency unit or focus changes 
    % RE: 1) When a time/frequency vector or range is specified, its value is  
    %     relative to the current frequency units and is therefore affected
    %     by a unit change (reason for bundling FrequencyUnits and FrequencyVector)
    %     2) Focus is different from limits because it directly affects the
    %     computed response data 
    Prefs = this.Preferences;
    TimeProps = [Prefs.findprop('TimeVector')];
    FreqProps = [Prefs.findprop('FrequencyVector');Prefs.findprop('FrequencyUnits')];
    L = [L;...
          handle.listener(Prefs, TimeProps, 'PropertyPostSet', {@LocalApplyTime this});...
          handle.listener(Prefs, FreqProps, 'PropertyPostSet', {@LocalApplyFrequency this})];
    
    % PostSet listeners for unit and characteristic preferences
    UnitProps = [Prefs.findprop('MagnitudeUnits');...
          Prefs.findprop('FrequencyScale');...
          Prefs.findprop('MagnitudeScale');...
          Prefs.findprop('PhaseUnits')];
    CharProps = [Prefs.findprop('SettlingTimeThreshold');...
          Prefs.findprop('RiseTimeLimits');...
          Prefs.findprop('UnwrapPhase')];
    L = [L;...
          handle.listener(Prefs, UnitProps, 'PropertyPostSet', {@LocalApplyUnits this});...
          handle.listener(Prefs, CharProps, 'PropertyPostSet', {@LocalApplyChars this})];
end
this.Listeners = [this.Listeners;L];

% ---------------------------------------------------------------------------% 
% Purpose: Action when the Systems change (PreSet listener)
% ---------------------------------------------------------------------------% 
function LocalSystemPreSet(eventsrc, eventdata, this)
% Update responses when sources are added or removed from this.Systems
updatesys(this,this.Systems,eventdata.NewValue)

%%%%%%%%%%%%%%%%%%
% LOCALAPPLYUNITS%
%%%%%%%%%%%%%%%%%%
function LocalApplyUnits(eventsrc,eventdata,this)
% PostSet listener for unit change (generic, causes redraw)
for v=this.Views(ishandle(this.Views))'
   v.setunits(eventsrc.Name,eventdata.NewValue)
end

%%%%%%%%%%%%%%%%%
%LOCALSAPPLYCHARS%
%%%%%%%%%%%%%%%%%
function LocalApplyChars(eventsrc,eventdata,this)
% PostSet listener for characteristic change (generic)
for v=this.Views(ishandle(this.Views))'
   v.setcharprefs(eventsrc.Name,eventdata.NewValue)
end

%%%%%%%%%%%%%%%%%%
% LOCALAPPLYTIME%
%%%%%%%%%%%%%%%%%%
function LocalApplyTime(eventsrc,eventdata,this)
% PostSet listener for time unit or focus change. 
Prefs = this.Preferences;
FocusChange = strcmp(eventsrc.Name,'TimeVector');
ActiveViews = this.Views(ishandle(this.Views))';

% Format time focus
f = Prefs.TimeVector;
if length(f)==1
   f = [0 f];
elseif length(f)>1
   f = [f(1) f(end)];
end

% Clear time data cached in lti sources and in data objects of 
% affected views (need to recompute response data so that the 
% time grid in data objects agrees with the specified focus)
if FocusChange || ~isempty(f)
   cleardata(this,'Time')
end

% Update plot settings
for v=ActiveViews
   % Apply new focus or reapply focus in new units
   v.setfocus(f,'sec','Time')
   % Apply unit change
end

% Redraw (triggers full update for relevant time response plots 
% since all data has been cleared)
if FocusChange || ~isempty(f)
   draw(this)
end
         
%%%%%%%%%%%%%%%%%%
% LOCALAPPLYFREQ%
%%%%%%%%%%%%%%%%%%
function LocalApplyFrequency(eventsrc,eventdata,this)
% PostSet listener for frequency unit or focus change. 
Prefs = this.Preferences;
FocusChange = strcmp(eventsrc.Name,'FrequencyVector');
ActiveViews = this.Views(ishandle(this.Views))';

% Format frequency focus
f = Prefs.FrequencyVector;
if iscell(f)
   f = [f{1} f{2}];
elseif length(f)>1
   f = [f(1) f(end)];
end

% Clear frequency data cached in lti sources and in data objects of 
% affected views (need to recompute response data so that the 
% frequency grid in data objects agrees with the specified focus)
if FocusChange || ~isempty(f)
   cleardata(this,'Frequency')
end

% Update plot settings
for v=ActiveViews
   % Apply new focus or reapply focus in new units
   v.setfocus(f,Prefs.FrequencyUnits,'Frequency')
   % Apply unit change (causes redraw if units are different from local plot units)
   if ~FocusChange
      v.setunits('FrequencyUnits',Prefs.FrequencyUnits)
   end
end

% Redraw (triggers full update for relevant frequency response plots 
% since all data has been cleared)
% RE: Force redraw when a frequency vector is specified (SETUNITS can
%     skip redraw when global units are changed and new units match 
%     local units, see geck 149489 for example)
if FocusChange || ~isempty(f)
   draw(this)
end