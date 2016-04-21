function Main = fvec_hg(h,Frame,pos)
%FVEC_HG  GUI for editing frequency vector properties of h (HG)

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:04 $

%---Pseudo groupbox
Main    = uicontrol('Parent',Frame,'Style','frame','Visible','off',...
          'Position',[pos(1) pos(2) pos(3) pos(4)]);
s.Title = uicontrol('Parent',Frame,'Style','text','String','Frequency Vector','Visible','off',...
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

w1 = 140; w2 = pos(3)-2*inset-w1-rb-2*cs;  w3 = 20; w2x = (w2-w3-2*cs)/2;
s.Manual1  = uicontrol('Parent',Frame,'Style','radio','String','','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-2*rh-rs rb rh]);
s.Manual1L = uicontrol('Parent',Frame,'Style','text','String','Define range','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset+rb+cs top-tedge-2*rh-rs+dt w1 th]);
s.Start    = uicontrol('Parent',Frame,'Style','edit','String','1','Visible','off',...
             'Tag','1','UserData',1,...
             'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+pos(3)-inset-w2 top-tedge-2*rh-rs w2x rh]);
s.To       = uicontrol('Parent',Frame,'Style','text','String','to','Visible','off',...
             'HorizontalAlignment','center','Position',[pos(1)+pos(3)-inset-w2x-w3-cs top-tedge-2*rh-rs+dt w3 th]);
s.Stop     = uicontrol('Parent',Frame,'Style','edit','String','1000','Visible','off',...
             'Tag','1000','UserData',1000,...
             'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+pos(3)-inset-w2x top-tedge-2*rh-rs w2x rh]);

s.Manual2  = uicontrol('Parent',Frame,'Style','radio','String','','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset top-tedge-3*rh-2*rs rb rh]);
s.Manual2L = uicontrol('Parent',Frame,'Style','text','String','Define vector','Visible','off',...
             'HorizontalAlignment','left','Position',[pos(1)+inset+rb+cs top-tedge-3*rh-2*rs+dt w1 th]);
s.Vector   = uicontrol('Parent',Frame,'Style','edit','String','logspace(0,3,50)','Visible','off',...
             'Tag','logspace(0,3,50)','UserData',logspace(0,3,50),...
             'BackgroundColor','w','HorizontalAlignment','left','Position',[pos(1)+pos(3)-inset-w2 top-tedge-3*rh-2*rs w2 rh]);

%---Re-adjust groupbox position (lower edge) to match GUIs
del = top-tedge-3*rh-2*rs-bedge-pos(2);
set(Main,'Position',[pos(1) pos(2)+del pos(3) pos(4)-gap-del]);

%---Store all handles in a single vector for quick access
s.Handles = [Main s.Title s.Auto s.AutoL s.Manual1 s.Manual1L s.Start s.To s.Stop s.Manual2 s.Manual2L s.Vector];

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h,s};
   %---Mode
    s.FrequencyVectorModeListener = handle.listener(h,findprop(h,'FrequencyVectorMode'),'PropertyPostSet',Callback);
    set(s.Auto,   'Callback',GUICallback);
    set(s.Manual1,'Callback',GUICallback);
    set(s.Manual2,'Callback',GUICallback);
   %---Value
    s.FrequencyVectorListener = handle.listener(h,findprop(h,'FrequencyVector'),'PropertyPostSet',Callback);
    set(s.Start, 'Callback',GUICallback);
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
case 'FrequencyVectorMode'
   switch NewValue
   case 'auto'
      set(s.Auto,'Value',1);
      set(s.Manual1,'Value',0);
      set(s.Manual2,'Value',0);
      set([s.Start s.To s.Stop s.Vector],'Enable','off');
   case 'manualfocus'
      set(s.Manual1,'Value',1);
      set(s.Auto,'Value',0);
      set(s.Manual2,'Value',0);
      set(s.Start,'Enable','on');
      set(s.To,'Enable','on');
      set(s.Stop,'Enable','on');
      set(s.Vector,'Enable','off');
   case 'manualgrid'      
      set(s.Manual2,'Value',1);
      set(s.Auto,'Value',0);
      set(s.Manual1,'Value',0);
      set(s.Vector,'Enable','on');
      set(s.Start,'Enable','off');
      set(s.To,'Enable','off');
      set(s.Stop,'Enable','off');
   end
case 'FrequencyVector'
   if iscell(NewValue)
      %---If viewer was initialized with a manual value, show it in GUI
      if ~isequal(NewValue,{get(s.Start,'UserData') get(s.Stop,'UserData')})
         str1 = makestr(NewValue{1});
         str2 = makestr(NewValue{2});
         set(s.Start,'String',str1,'Tag',str1,'UserData',NewValue{1});
         set(s.Stop, 'String',str2,'Tag',str2,'UserData',NewValue{2});
      end
   else
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
   h.FrequencyVectorMode = 'auto';
case s.Manual1
   set(eventSrc,'Value',1);
   h.FrequencyVectorMode = 'manualfocus';
   h.FrequencyVector = {get(s.Start,'UserData') get(s.Stop,'UserData')};
case s.Manual2
   set(eventSrc,'Value',1);
   h.FrequencyVectorMode = 'manualgrid';
   h.FrequencyVector = get(s.Vector,'UserData');
case s.Start
   if strcmpi(get(eventSrc,'Enable'),'on')
      oldval = get(eventSrc,'UserData');
      oldvec = [oldval get(s.Stop,'UserData')];
      oldstr = get(eventSrc,'Tag');
      newstr = get(eventSrc,'String');
      newval = evalnum(newstr,1);
      if isempty(newval) | newval>=oldvec(2)
         set(eventSrc,'String',oldstr);
      elseif ~isequal(oldval,newval)
         set(eventSrc,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = {newval oldvec(2)};
      end
   end
case s.Stop
   if strcmpi(get(eventSrc,'Enable'),'on')
      oldval = get(eventSrc,'UserData');
      oldvec = [get(s.Start,'UserData') oldval];
      oldstr = get(eventSrc,'Tag');
      newstr = get(eventSrc,'String');
      newval = evalnum(newstr,1);
      if isempty(newval) | newval<=oldvec(1)
         set(eventSrc,'String',oldstr);
      elseif ~isequal(oldval,newval)
         set(eventSrc,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = {oldvec(1) newval};
      end
   end
case s.Vector
   if strcmpi(get(eventSrc,'Enable'),'on')
      oldval = get(eventSrc,'UserData');
      oldstr = get(eventSrc,'Tag');
      newstr = get(eventSrc,'String');
      newval = evalnum(newstr,inf);
      if isempty(newval)
         set(eventSrc,'String',oldstr);
      elseif ~isequal(oldval,newval)
         set(eventSrc,'Tag',newstr,'UserData',newval);
         h.FrequencyVector = newval;
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
      %---Case: val is vector (length>2)
      elseif n==inf & length(val)>2
         %---Make sure all of val is >0
         if ~all(val>0)
            val = [];
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
elseif lval==2
   str = sprintf('[%0.3g %0.3g]',val(1),val(end));
else
   dval   = diff(val);
   val10  = log10(val);
   dval10 = diff(val10);
   tol    = 100*eps*max(val);
   tol10  = 100*eps*max(val10);
   if all(abs(dval-dval(1))<tol)
      %---Build compact vector (even step size)
      str = sprintf('[%s:%s:%s]',num2str(val(1)),num2str(dval(1)),num2str(val(end)));
   elseif all(abs(dval10-dval10(1))<tol10)
      %---Build logspace string
      str = sprintf('logspace(%s,%s,%d)',num2str(val10(1)),num2str(val10(end)),lval);
   elseif lval<=20
      %---Generic case (show all values, as long as the vector isn't too long!)
      str = sprintf('%g ',val);
      str = sprintf('[%s]',str(1:end-1));
   else
      %---Default string
      str = 'logspace(0,3,50)';
   end
end
