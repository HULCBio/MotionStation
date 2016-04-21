function Main = tvec_gui(h)
%TVEC_GUI  GUI for editing time vector properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:16:08 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
GL_12 = java.awt.GridLayout(1,2,0,0);
GRP = com.mathworks.mwt.MWExclusiveGroup;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Time Vector'));
Main.setLayout(java.awt.GridLayout(3,1,0,4));
Main.setFont(Prefs.JavaFontB);

%---Row 1 ('Generate automatically')
s.R1 = com.mathworks.mwt.MWPanel(java.awt.GridLayout(1,1,0,0)); Main.add(s.R1);
s.Auto = com.mathworks.mwt.MWCheckbox(sprintf('Generate automatically'),GRP,1); s.R1.add(s.Auto);
s.Auto.setFont(Prefs.JavaFontP);

%---Row 2 ('Define stop time')
s.R2 = com.mathworks.mwt.MWPanel(GL_12); Main.add(s.R2);
s.Manual1 = com.mathworks.mwt.MWCheckbox(sprintf('Define stop time'),GRP,0); s.R2.add(s.Manual1);
s.Manual1.setFont(Prefs.JavaFontP);
 %---Stop
  s.Stop = com.mathworks.mwt.MWTextField(sprintf('1'),8); s.R2.add(s.Stop);
  set(s.Stop,'Tag','1','UserData',1);  %---Tag/UserData contains last valid string/number
  s.Stop.setFont(Prefs.JavaFontP);
  s.Stop.setEnabled(0);

%---Row 3 ('Define vector')
s.R3 = com.mathworks.mwt.MWPanel(GL_12); Main.add(s.R3);
s.Manual2 = com.mathworks.mwt.MWCheckbox(sprintf('Define vector'),GRP,0); s.R3.add(s.Manual2);
s.Manual2.setFont(Prefs.JavaFontP);
 %---Vector
  s.Vector = com.mathworks.mwt.MWTextField(sprintf('[0:0.01:1]'),8); s.R3.add(s.Vector);
  set(s.Vector,'Tag','[0:0.01:1]','UserData',[0:0.01:1]); %---Tag/UserData contains last valid string/number
  s.Vector.setFont(Prefs.JavaFontP);
  s.Vector.setEnabled(0);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'viewprefs');
EventSrc = CLS.findprop('TimeVector');
s.TimeVectorListener = handle.listener(h,EventSrc,'PropertyPostSet',{@localReadProp,s});
GUICallback = {@localWriteProp,h,s};
%---Mode
set(s.Auto,   'Name','Auto',   'ItemStateChangedCallback',GUICallback);
set(s.Manual1,'Name','Manual1','ItemStateChangedCallback',GUICallback);
set(s.Manual2,'Name','Manual2','ItemStateChangedCallback',GUICallback);
%---Value
set(s.Stop,  'Name','Stop',  'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback);
set(s.Vector,'Name','Vector','ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback);

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Target -> GUI
h = eventData.AffectedObject;
NewValue = eventData.NewValue;
if isempty(NewValue)
   % Reverting to auto mode
   s.Auto.setState(1);
   s.Stop.setEnabled(0); s.Stop.repaint;
   s.Vector.setEnabled(0); s.Vector.repaint;
elseif length(NewValue)==1
   % Speficied end time
   s.Manual1.setState(1);
   s.Stop.setEnabled(1); s.Stop.repaint;
   s.Vector.setEnabled(0); s.Vector.repaint;
   if ~isequal(NewValue,get(s.Stop,'UserData'))
      str = makestr(NewValue);
      set(s.Stop,'Text',str,'Tag',str,'UserData',NewValue);
   end
else
   % Specified time vector
   s.Manual2.setState(1);
   s.Stop.setEnabled(0); s.Stop.repaint;
   s.Vector.setEnabled(1); s.Vector.repaint;
   if ~isequal(NewValue,get(s.Vector,'UserData'))
      str = makestr(NewValue);
      set(s.Vector,'Text',str,'Tag',str,'UserData',NewValue);
   end
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,s)
% GUI -> Target
Name = get(eventSrc,'Name');
switch Name
case 'Auto'
   h.TimeVector = [];
case 'Manual1'
   h.TimeVector = get(s.Stop,'UserData');
case 'Manual2'
   h.TimeVector = get(s.Vector,'UserData');
case {'Stop','Vector'}
   if strcmpi(get(eventSrc,'Enabled'),'on')
      oldval = get(eventSrc,'UserData');
      oldstr = get(eventSrc,'Tag');
      newstr = get(eventSrc,'Text');
      if strcmpi(Name,'Stop')
         newval = evalnum(newstr,1);
      else
         newval = evalnum(newstr,inf);
      end
      if isempty(newval)
         set(eventSrc,'Text',oldstr);
      elseif ~isequal(oldval,newval)
         newstr = makestr(newval);
         set(eventSrc,'Text',newstr,'Tag',newstr,'UserData',newval);
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
