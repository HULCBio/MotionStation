function Main = unit_hg(h,Frame,pos)
%UNIT_HG  GUI for editing unit & scale properties of h (HG)

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:11 $

%---Pseudo groupbox
Main    = uicontrol('Parent',Frame,'Style','frame','Visible','off',...
          'Position',[pos(1) pos(2) pos(3) pos(4)]);
s.Title = uicontrol('Parent',Frame,'Style','text','String','Units','Visible','off',...
          'HorizontalAlignment','center','FontWeight','bold','Position',[0 0 1 1]);
%---Adjust groupbox and title locations
inset = 8;
gap = 8;
ext = get(s.Title,'Extent');
set(Main,'Position',[pos(1) pos(2) pos(3) pos(4)-gap]);
set(s.Title,'Position',[pos(1)+inset pos(2)+pos(4)-ext(4) ext(3) ext(4)+1]);

%---Definitions
top = pos(2)+pos(4)-gap; rh = 22; th = 16; dt = (rh-th)/2; rs = 5; cs = 5; bedge = 8; tedge = 12; rb = 16;

%---Buttons/Popups
w1  = 85; w2 = 80; w3 = 40; w4 = 105;
s.FrequencyUnitsLabel = uicontrol('Parent',Frame,'Style','text','String','Frequency in','Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-rh+dt w1 th]);
s.FrequencyUnits      = uicontrol('Parent',Frame,'Style','popup','String',{'Hz';'rad/sec'},'Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs top-tedge-rh w2 rh]);
s.FrequencyScaleLabel = uicontrol('Parent',Frame,'Style','text','String','using','Visible','off',...
                        'HorizontalAlignment','center','Position',[pos(1)+inset+w1+cs+w2+cs top-tedge-rh+dt w3 th]);
s.FrequencyScale      = uicontrol('Parent',Frame,'Style','popup','String',{'linear scale';'log scale'},'Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs+w2+cs+w3+cs top-tedge-rh w4 rh]);
s.MagnitudeUnitsLabel = uicontrol('Parent',Frame,'Style','text','String','Magnitude in','Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-2*rh-rs+dt w1 th]);
s.MagnitudeUnits      = uicontrol('Parent',Frame,'Style','popup','String',{'dB';'absolute'},'Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs top-tedge-2*rh-rs w2 rh]);
s.MagnitudeScaleLabel = uicontrol('Parent',Frame,'Style','text','String','using','Visible','off',...
                        'HorizontalAlignment','center','Position',[pos(1)+inset+w1+cs+w2+cs top-tedge-2*rh-rs+dt w3 th]);
s.MagnitudeScale      = uicontrol('Parent',Frame,'Style','popup','String',{'linear scale';'log scale'},'Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs+w2+cs+w3+cs top-tedge-2*rh-rs w4 rh]);
s.PhaseUnitsLabel     = uicontrol('Parent',Frame,'Style','text','String','Phase in','Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-3*rh-2*rs+dt w1 th]);
s.PhaseUnits          = uicontrol('Parent',Frame,'Style','popup','String',{'degrees';'radians'},'Visible','off',...
                        'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs top-tedge-3*rh-2*rs w2 rh]);

%---Re-adjust groupbox position (lower edge) to match GUIs
del = top-tedge-3*rh-2*rs-bedge-pos(2);
set(Main,'Position',[pos(1) pos(2)+del pos(3) pos(4)-gap-del]);

%---Store all handles in a single vector for quick access
s.Handles = [Main s.Title s.FrequencyUnitsLabel s.FrequencyUnits s.FrequencyScaleLabel s.FrequencyScale ...
   s.MagnitudeUnitsLabel s.MagnitudeUnits s.MagnitudeScaleLabel s.MagnitudeScale s.PhaseUnitsLabel s.PhaseUnits];

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---Frequency Units
    s.FrequencyUnitsListener = handle.listener(h,findprop(h,'FrequencyUnits'),'PropertyPostSet',Callback);
    set(s.FrequencyUnits,'Tag','FrequencyUnits','Callback',GUICallback);
   %---Magnitude Units
    s.MagnitudeUnitsListener = handle.listener(h,findprop(h,'MagnitudeUnits'),'PropertyPostSet',Callback);
    set(s.MagnitudeUnits,'Tag','MagnitudeUnits','Callback',GUICallback);
   %---Phase Units
    s.PhaseUnitsListener = handle.listener(h,findprop(h,'PhaseUnits'),'PropertyPostSet',Callback);
    set(s.PhaseUnits,'Tag','PhaseUnits','Callback',GUICallback);
   %---Frequency Scale
    s.FrequencyScaleListener = handle.listener(h,findprop(h,'FrequencyScale'),'PropertyPostSet',Callback);
    set(s.FrequencyScale,'Tag','FrequencyScale','Callback',GUICallback);
   %---Magnitude Scale
    s.MagnitudeScaleListener = handle.listener(h,findprop(h,'MagnitudeScale'),'PropertyPostSet',Callback);
    set(s.MagnitudeScale,'Tag','MagnitudeScale','Callback',GUICallback);
   %---Visibility Listener 
    s.VisibleListener = handle.listener(Main,findprop(handle(Main),'Visible'),'PropertyPostSet',@localVisible);

%---Store hg handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%
% localVisible %
%%%%%%%%%%%%%%%%
function localVisible(eventSrc,eventData)
% GUI visibility management
s = get(eventData.AffectedObject,'UserData');
set(s.Handles,'Visible',eventData.NewValue);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Target -> GUI
Name = eventSrc.Name;
NewValue = eventData.NewValue;
%---Set GUI state
switch Name
case 'FrequencyUnits'
   if strcmpi(eventData.NewValue(1),'h')
      set(s.FrequencyUnits,'Value',1);
   else
      set(s.FrequencyUnits,'Value',2);
   end
case 'MagnitudeUnits'
   h = eventData.AffectedObject;
   if strcmpi(eventData.NewValue(1),'d')
      set(s.MagnitudeUnits,'Value',1);
      set([s.MagnitudeScaleLabel s.MagnitudeScale],'Visible','off');
      h.MagnitudeScale = 'linear';
   else
      set(s.MagnitudeUnits,'Value',2);
      h.MagnitudeScale = 'linear';
      set([s.MagnitudeScaleLabel s.MagnitudeScale],'Visible','on');
   end
case 'PhaseUnits'
   if strcmpi(eventData.NewValue(1),'d')
      set(s.PhaseUnits,'Value',1);
   else
      set(s.PhaseUnits,'Value',2);
   end
case 'FrequencyScale'
   if strcmpi(eventData.NewValue,'linear')
      set(s.FrequencyScale,'Value',1);
   else
      set(s.FrequencyScale,'Value',2);
   end
case 'MagnitudeScale'
   if strcmpi(eventData.NewValue,'linear')
      set(s.MagnitudeScale,'Value',1);
   else
      set(s.MagnitudeScale,'Value',2);
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% GUI -> Target
Name = get(eventSrc,'Tag');
switch Name
case {'FrequencyUnits'}
   if get(eventSrc,'Value')==1
      Value = 'Hz';
   else
      Value = 'rad/sec';
   end
case {'MagnitudeUnits'}
   if get(eventSrc,'Value')==1
      Value = 'dB';
   else
      Value = 'abs';
   end
case {'PhaseUnits'}
   if get(eventSrc,'Value')==1
      Value = 'deg';
   else
      Value = 'rad';
   end
case {'FrequencyScale','MagnitudeScale'}
   if get(eventSrc,'Value')==1
      Value = 'linear';
   else
      Value = 'log';
   end
end
set(h,Name,Value);
