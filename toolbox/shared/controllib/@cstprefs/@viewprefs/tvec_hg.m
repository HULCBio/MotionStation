function Main = tvec_hg(h,Frame,pos)
%TVEC_HG  GUI for editing time vector properties of h (HG)

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:09 $

%---Pseudo groupbox
Main    = uicontrol('Parent',Frame,'Style','frame','Visible','off',...
          'Position',[pos(1) pos(2) pos(3) pos(4)]);
s.Title = uicontrol('Parent',Frame,'Style','text','String','Time Vector','Visible','off',...
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
w1 = 180;
s.Auto    = uicontrol('Parent',Frame,'Style','radio','String','','Visible','off',...
            'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-rh rb rh]);
s.AutoL   = uicontrol('Parent',Frame,'Style','text','String','Generate automatically','Visible','off',...
            'HorizontalAlignment','left','Position',[pos(1)+inset+rb+cs top-tedge-rh+dt w1 th]);

w1 = 140; w2 = pos(3)-2*inset-w1-rb-2*cs;
s.Manual1  = uicontrol('Parent',Frame,'Style','radio','String','','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-2*rh-rs rb rh]);
s.Manual1L = uicontrol('Parent',Frame,'Style','text','String','Define stop time','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset+rb+cs top-tedge-2*rh-rs+dt w1 th]);
s.Stop     = uicontrol('Parent',Frame,'Style','edit','String','1','Visible','off',...
             'Tag','1','UserData',1,...
             'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+pos(3)-inset-w2 top-tedge-2*rh-rs w2 rh]);

s.Manual2  = uicontrol('Parent',Frame,'Style','radio','String','','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-3*rh-2*rs rb rh]);
s.Manual2L = uicontrol('Parent',Frame,'Style','text','String','Define vector','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset+rb+cs top-tedge-3*rh-2*rs+dt w1 th]);
s.Vector   = uicontrol('Parent',Frame,'Style','edit','String','[0:0.01:1]','Visible','off',...
             'Tag','[0:0.01:1]','UserData',[0:0.01:1],...
             'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+pos(3)-inset-w2 top-tedge-3*rh-2*rs w2 rh]);

%---Re-adjust groupbox position (lower edge) to match GUIs
del = top-tedge-3*rh-2*rs-bedge-pos(2);
set(Main,'Position',[pos(1) pos(2)+del pos(3) pos(4)-gap-del]);

%---Store all handles in a single vector for quick access
s.Handles = [Main s.Title s.Auto s.AutoL s.Manual1 s.Manual1L s.Stop s.Manual2 s.Manual2L s.Vector];

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h,s};
   %---Mode
    s.TimeVectorModeListener = handle.listener(h,findprop(h,'TimeVectorMode'),'PropertyPostSet',Callback);
    set(s.Auto,   'Callback',GUICallback);
    set(s.Manual1,'Callback',GUICallback);
    set(s.Manual2,'Callback',GUICallback);
   %---Value
    s.TimeVectorListener = handle.listener(h,findprop(h,'TimeVector'),'PropertyPostSet',Callback);
    set(s.Stop,  'Callback',GUICallback);
    set(s.Vector,'Callback',GUICallback);
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
h = eventData.AffectedObject;
NewValue = eventData.NewValue;
switch eventSrc.Name
case 'TimeVectorMode'
   switch NewValue
   case 'auto'
      set(s.Auto,'Value',1);
      set(s.Manual1,'Value',0);
      set(s.Manual2,'Value',0);
      set([s.Stop s.Vector],'Enable','off');
   case 'manualfocus'
      set(s.Manual1,'Value',1);
      set(s.Auto,'Value',0);
      set(s.Manual2,'Value',0);
      set(s.Stop,'Enable','on');
      set(s.Vector,'Enable','off');
   case 'manualgrid'      
      set(s.Manual2,'Value',1);
      set(s.Auto,'Value',0);
      set(s.Manual1,'Value',0);
      set(s.Vector,'Enable','on');
      set(s.Stop,'Enable','off');
   end
case 'TimeVector'
   if length(NewValue)==1
      %---If viewer was initialized with a manual value, show it in GUI
      if ~isequal(NewValue,get(s.Stop,'UserData'))
         str = makestr(NewValue);
         set(s.Stop,'String',str,'Tag',str,'UserData',NewValue);
      end
   elseif ~isempty(NewValue)
      %---If viewer was initialized with a manual value, show it in GUI
      if ~isequal(NewValue,get(s.Vector,'UserData'))
         str = makestr(NewValue);
         set(s.Vector,'String',str,'Tag',str,'UserData',NewValue);
      end
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,s)
% GUI -> Target
switch eventSrc
case s.Auto
   set(eventSrc,'Value',1);
   h.TimeVectorMode = 'auto';
case s.Manual1
   set(eventSrc,'Value',1);
   h.TimeVectorMode = 'manualfocus';
   h.TimeVector = get(s.Stop,'UserData');
case s.Manual2
   set(eventSrc,'Value',1);
   h.TimeVectorMode = 'manualgrid';
   h.TimeVector = get(s.Vector,'UserData');
case {s.Stop,s.Vector}
   if strcmpi(get(eventSrc,'Enable'),'on')
      oldval = get(eventSrc,'UserData');
      oldstr = get(eventSrc,'Tag');
      newstr = get(eventSrc,'String');
      if eventSrc==s.Stop
         newval = evalnum(newstr,1);
      else
         newval = evalnum(newstr,inf);
      end
      if isempty(newval)
         set(eventSrc,'String',oldstr);
      elseif ~isequal(oldval,newval)
         newstr = makestr(newval);
         set(eventSrc,'String',newstr,'Tag',newstr,'UserData',newval);
         h.TimeVector = newval;
      end
   end
end


%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val,n)
% Evaluate string val
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val))
      val = [];
   else
      val = val(:);
      %---Case: val must be same length as n
      if n<inf & length(val)==n
         %---Make sure val is >0
         if val<=0
            val = [];
         end
      %---Case: val is vector (length>1)
      elseif n==inf & length(val)>1
         %---Make sure all of val is >=0 and monotonically increasing
         if val(1)<0 | (val(2)-val(1))<=0
            val = [];
         else
            val = fixval(val);
         end
      else
         val = [];
      end
   end
end


%%%%%%%%%%%
% makestr %
%%%%%%%%%%%
function str = makestr(val)
% Build a nice display string for val
lval = length(val);
if lval==0
   str = '';
elseif lval==1
   str = num2str(val);
else
   val = fixval(val);
   str = sprintf('[%s:%s:%s]',num2str(val(1)),num2str(val(2)-val(1)),num2str(val(end)));
end


%%%%%%%%%%
% fixval %
%%%%%%%%%%
function val = fixval(val)
%---Fix vector if not evenly spaced
 t0 = val(1);
 dt = val(2)-val(1);
 nt0 = round(t0/dt);
 t0 = nt0*dt;
 val = dt*(0:1:nt0+length(val)-1);
 if t0>0
    val = val(find(val>=t0));
 end
