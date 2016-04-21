function Main = char_hg(h,Frame,pos)
%CHAR_HG  GUI for editing characteristic properties of h (HG)

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:59 $

%---Pseudo groupbox
Main    = uicontrol('Parent',Frame,'Style','frame','Visible','off',...
          'Position',[pos(1) pos(2) pos(3) pos(4)]);
s.Title = uicontrol('Parent',Frame,'Style','text','String','Response Characteristics','Visible','off',...
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
w1 = 147; w2 = 45; w3 = 20;
s.ST_L1 = uicontrol('Parent',Frame,'Style','text','String','Show settling time within','Visible','off',...
         'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-rh+dt w1 th]);  
s.SettlingTimeThreshold = uicontrol('Parent',Frame,'Style','edit','String','','Visible','off',...  
         'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+8+w1+cs top-tedge-rh w2 rh]);
s.ST_L2 = uicontrol('Parent',Frame,'Style','text','String','%','Visible','off',...
         'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs+w2+cs top-tedge-rh+dt w3 th]);

w1 = 120; w2 = 45; w3 = 20; w4 = 45; w5 = 20;
s.RT_L1 = uicontrol('Parent',Frame,'Style','text','String','Show rise time from','Visible','off',...
         'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-2*rh-rs+dt w1 th]);
s.RiseTimeLimits1 = uicontrol('Parent',Frame,'Style','edit','String','','Visible','off',...
         'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs top-tedge-2*rh-rs w2 rh]);
s.RT_L2 = uicontrol('Parent',Frame,'Style','text','String','to','Visible','off',...
         'HorizontalAlignment','center','Position',[pos(1)+inset+w1+cs+w2+cs top-tedge-2*rh-rs+dt w3 th]);
s.RiseTimeLimits2 = uicontrol('Parent',Frame,'Style','edit','String','','Visible','off',...
         'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs+w2+cs+w3+cs top-tedge-2*rh-rs w4 rh]);
s.RT_L3 = uicontrol('Parent',Frame,'Style','text','String','%','Visible','off',...
         'HorizontalAlignment','left','Position',[pos(1)+inset+w1+cs+w2+cs+w3+cs+w4+cs top-tedge-2*rh-rs+dt w5 th]);

%---Re-adjust groupbox position (lower edge) to match GUIs
del = top-tedge-2*rh-1*rs-bedge-pos(2);
set(Main,'Position',[pos(1) pos(2)+del pos(3) pos(4)-gap-del]);

%---Store all handles in a single vector for quick access
s.Handles = [Main s.Title s.ST_L1 s.SettlingTimeThreshold s.ST_L2 s.RT_L1 s.RiseTimeLimits1 s.RT_L2 s.RiseTimeLimits2 s.RT_L3];


%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---SettlingTimeThreshold
    s.SettlingTimeThresholdListener = handle.listener(h,findprop(h,'SettlingTimeThreshold'),'PropertyPostSet',Callback);
    set(s.SettlingTimeThreshold,'Tag','SettlingTimeThreshold','Callback',GUICallback);
   %---RiseTimeLimits
    s.RiseTimeLimitsListener = handle.listener(h,findprop(h,'RiseTimeLimits'),'PropertyPostSet',Callback);
    set(s.RiseTimeLimits1,'Tag','RiseTimeLimits1','Callback',GUICallback);
    set(s.RiseTimeLimits2,'Tag','RiseTimeLimits2','Callback',GUICallback);
   %---Visibility Listener
    s.VisibleListener = handle.listener(Main,findprop(handle(Main),'Visible'),'PropertyPostSet',@localVisible);

%---Store java handles
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
%---Set GUI state/text
switch Name
case 'SettlingTimeThreshold'
   set(s.SettlingTimeThreshold,'String',num2str(NewValue*100));
case 'RiseTimeLimits'
   set(s.RiseTimeLimits1,'String',num2str(NewValue(1)*100));
   set(s.RiseTimeLimits2,'String',num2str(NewValue(2)*100));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% GUI -> Target
Name = get(eventSrc,'Tag');
switch Name
case {'SettlingTimeThreshold'}
   oldval = h.SettlingTimeThreshold;
   val = evalnum(get(eventSrc,'String'))/100;
   if isequal(h,val)
      %---No change: return
      return;
   elseif isempty(val)
      %---Invalid number: revert to original value
      set(eventSrc,'String',num2str(oldval*100));
      return;
   else
      val = max(min(val,1),0);
      set(eventSrc,'String',num2str(val*100));
      h.SettlingTimeThreshold = val;
   end
case {'RiseTimeLimits1','RiseTimeLimits2'}
   oldvec = h.RiseTimeLimits;
   if strcmpi(Name,'RiseTimeLimits1')
      oldval = oldvec(1);
   else
      oldval = oldvec(2);
   end
   val = evalnum(get(eventSrc,'String'))/100;
   if isequal(oldval,val)
      %---No change: return
      return;
   elseif isempty(val)
      %---Invalid number: revert to original value
      set(eventSrc,'String',num2str(oldval*100));
      return;
   else
      %---Limit to (0,1)
      val = max(min(val,1),0);
      if strcmpi(Name,'RiseTimeLimits1')
         if val<oldvec(2)
            h.RiseTimeLimits = [val oldvec(2)];
         elseif val<1
            h.RiseTimeLimits = [val 1];
         else
            %---Invalid number, revert to original value
            set(eventSrc,'String',num2str(oldval*100));
         end
      else
         if val>oldvec(1)
            h.RiseTimeLimits = [oldvec(1) val];
         elseif val>0
            h.RiseTimeLimits = [0 val];
         else
            %---Invalid number, revert to original value
            set(eventSrc,'String',num2str(oldval*100));
         end
      end
   end
end


%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val)
% Evaluate string val, returning valid real scalar only, empty otherwise
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val) & isequal(size(val),[1 1]))
      val = [];
   end
end
