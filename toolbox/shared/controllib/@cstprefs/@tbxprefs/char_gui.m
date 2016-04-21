function Main = char_gui(h)
%CHAR_GUI  GUI for editing characteristic properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:15:46 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
FL_L50 = java.awt.FlowLayout(java.awt.FlowLayout.LEFT,5,0);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Response Characteristics'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

%---Response Characteristics panel
s.RC = com.mathworks.mwt.MWPanel(java.awt.GridLayout(2,1,0,4));
Main.add(s.RC,com.mathworks.mwt.MWBorderLayout.WEST);

%---SettlingTime
s.R2 = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0)); s.RC.add(s.R2);
s.SettlingTime = com.mathworks.mwt.MWLabel(sprintf('Show settling time within')); s.R2.add(s.SettlingTime,WEST);
s.SettlingTime.setFont(Prefs.JavaFontP);
   %---SettlingTimeThreshold
   s.R2E = com.mathworks.mwt.MWPanel(FL_L50); s.R2.add(s.R2E,CENTER);
   s.SettlingTimeThreshold = com.mathworks.mwt.MWTextField(3); s.R2E.add(s.SettlingTimeThreshold);
   s.SettlingTimeThreshold.setFont(Prefs.JavaFontP);
   s.R2EL1 = com.mathworks.mwt.MWLabel(sprintf('%%')); s.R2E.add(s.R2EL1);
   s.R2EL1.setFont(Prefs.JavaFontP);

%---RiseTime
s.R3 = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0)); s.RC.add(s.R3);
s.RiseTime = com.mathworks.mwt.MWLabel(sprintf('Show rise time from')); s.R3.add(s.RiseTime,WEST);
s.RiseTime.setFont(Prefs.JavaFontP);
   %---RiseTimeLimits
   s.R3E = com.mathworks.mwt.MWPanel(FL_L50); s.R3.add(s.R3E,CENTER);
   s.RiseTimeLimits1 = com.mathworks.mwt.MWTextField(3); s.R3E.add(s.RiseTimeLimits1);
   s.RiseTimeLimits1.setFont(Prefs.JavaFontP);
   s.R3EL1 = com.mathworks.mwt.MWLabel(sprintf('to')); s.R3E.add(s.R3EL1);
   s.R3EL1.setFont(Prefs.JavaFontP);
   s.RiseTimeLimits2 = com.mathworks.mwt.MWTextField(3); s.R3E.add(s.RiseTimeLimits2);
   s.RiseTimeLimits2.setFont(Prefs.JavaFontP);
   s.R3EL2 = com.mathworks.mwt.MWLabel(sprintf('%%')); s.R3E.add(s.R3EL2);
   s.R3EL2.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
CLS = findclass(findpackage('cstprefs'),'tbxprefs');
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---SettlingTimeThreshold
    EventSrc = CLS.findprop('SettlingTimeThreshold');
    s.SettlingTimeThresholdListener = handle.listener(h,EventSrc,'PropertyPostSet',Callback);
    set(s.SettlingTimeThreshold,'Name','SettlingTimeThreshold',...
       'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback);
   %---RiseTimeLimits
    EventSrc = CLS.findprop('RiseTimeLimits');
    s.RiseTimeLimitsListener = handle.listener(h,EventSrc,'PropertyPostSet',Callback);
    set(s.RiseTimeLimits1,'Name','RiseTimeLimits1',...
       'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback);
    set(s.RiseTimeLimits2,'Name','RiseTimeLimits2',...
       'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback);

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
Name = eventSrc.Name;
NewValue = eventData.NewValue;
%---Set GUI state/text
switch Name
case 'SettlingTimeThreshold'
   s.SettlingTimeThreshold.setText(num2str(NewValue*100));
case 'RiseTimeLimits'
   s.RiseTimeLimits1.setText(num2str(NewValue(1)*100));
   s.RiseTimeLimits2.setText(num2str(NewValue(2)*100));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
Name = get(eventSrc,'Name');
switch Name
case 'SettlingTimeThreshold'
   oldval = h.SettlingTimeThreshold;
   val = evalnum(get(eventSrc,'Text'))/100;
   if isequal(h,val)
      %---No change: return
      return;
   elseif isempty(val)
      %---Invalid number: revert to original value
      set(eventSrc,'Text',num2str(oldval*100));
      return;
   else
      val = max(min(val,1),0);
      set(eventSrc,'Text',num2str(val*100));
      h.SettlingTimeThreshold = val;
   end
case {'RiseTimeLimits1','RiseTimeLimits2'}
   oldvec = h.RiseTimeLimits;
   if strcmpi(Name,'RiseTimeLimits1')
      oldval = oldvec(1);
   else
      oldval = oldvec(2);
   end
   val = evalnum(get(eventSrc,'Text'))/100;
   if isequal(oldval,val)
      %---No change: return
      return;
   elseif isempty(val)
      %---Invalid number: revert to original value
      set(eventSrc,'Text',num2str(oldval*100));
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
            set(eventSrc,'Text',num2str(oldval*100));
         end
      else
         if val>oldvec(1)
            h.RiseTimeLimits = [oldvec(1) val];
         elseif val>0
            h.RiseTimeLimits = [0 val];
         else
            %---Invalid number, revert to original value
            set(eventSrc,'Text',num2str(oldval*100));
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
