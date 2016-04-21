function Main = ls_gui(h)
%LS_GUI  GUI for editing line color/style properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/10 23:14:19 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
EAST   = com.mathworks.mwt.MWBorderLayout.EAST;
GL     = java.awt.GridLayout(6,1,0,3);

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Line Colors'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(10,0));
Main.setFont(Prefs.JavaFontB);

s.W = com.mathworks.mwt.MWPanel(GL); Main.add(s.W,WEST);
s.C = com.mathworks.mwt.MWPanel(GL); Main.add(s.C,CENTER);
s.E = com.mathworks.mwt.MWPanel(GL); Main.add(s.E,EAST);

s.L1 = com.mathworks.mwt.MWLabel(sprintf('Plant & Sensor:')); s.W.add(s.L1);
s.L1.setFont(Prefs.JavaFontP);
s.L2 = com.mathworks.mwt.MWLabel(sprintf('Compensator:')); s.W.add(s.L2);
s.L2.setFont(Prefs.JavaFontP);
s.L3 = com.mathworks.mwt.MWLabel(sprintf('Prefilter:')); s.W.add(s.L3);
s.L3.setFont(Prefs.JavaFontP);
s.L4 = com.mathworks.mwt.MWLabel(sprintf('Open Loop:')); s.W.add(s.L4);
s.L4.setFont(Prefs.JavaFontP);
s.L5 = com.mathworks.mwt.MWLabel(sprintf('Closed Loop:')); s.W.add(s.L5);
s.L5.setFont(Prefs.JavaFontP);
s.L6 = com.mathworks.mwt.MWLabel(sprintf('Margins:')); s.W.add(s.L6);
s.L6.setFont(Prefs.JavaFontP);

s.E1 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E1);
s.E1.setFont(Prefs.JavaFontP);
s.E2 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E2);
s.E2.setFont(Prefs.JavaFontP);
s.E3 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E3);
s.E3.setFont(Prefs.JavaFontP);
s.E4 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E4);
s.E4.setFont(Prefs.JavaFontP);
s.E5 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E5);
s.E5.setFont(Prefs.JavaFontP);
s.E6 = com.mathworks.mwt.MWTextField(12); s.C.add(s.E6);
s.E6.setFont(Prefs.JavaFontP);

s.B1 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B1);
s.B1.setFont(Prefs.JavaFontP);
s.B2 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B2);
s.B2.setFont(Prefs.JavaFontP);
s.B3 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B3);
s.B3.setFont(Prefs.JavaFontP);
s.B4 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B4);
s.B4.setFont(Prefs.JavaFontP);
s.B5 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B5);
s.B5.setFont(Prefs.JavaFontP);
s.B6 = com.mathworks.mwt.MWButton(sprintf('Select...')); s.E.add(s.B6);
s.B6.setFont(Prefs.JavaFontP);

%---Install listeners and callbacks
LCallback = {@localReadProp,s};           % listener callback
ECallback = {@localWriteProp,h,'edit'};   % edit callback
   %---LineStyle
    s.LineStyleListener = handle.listener(h,findprop(h,'LineStyle'),'PropertyPostSet',LCallback);
    set(s.E1,'Name','System',     'ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.E2,'Name','Compensator','ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.E3,'Name','PreFilter',  'ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.E4,'Name','Response',   'ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.E5,'Name','ClosedLoop', 'ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.E6,'Name','Margin',     'ActionPerformedCallback',ECallback,'FocusLostCallback',ECallback,'ComponentResizedCallback',@localResetCaret);
    set(s.B1,'Name','System',     'ActionPerformedCallback',{@localWriteProp,h,'Plant & Sensor'});
    set(s.B2,'Name','Compensator','ActionPerformedCallback',{@localWriteProp,h,'Compensator'});
    set(s.B3,'Name','PreFilter',  'ActionPerformedCallback',{@localWriteProp,h,'Prefilter'});
    set(s.B4,'Name','Response',   'ActionPerformedCallback',{@localWriteProp,h,'Plot Lines'});
    set(s.B5,'Name','ClosedLoop', 'ActionPerformedCallback',{@localWriteProp,h,'Closed Loop'});
    set(s.B6,'Name','Margin',     'ActionPerformedCallback',{@localWriteProp,h,'Margins'});

%---Store java handles
set(Main,'UserData',s);


%%%%%%%%%%%%%%%%%%%
% localResetCaret %
%%%%%%%%%%%%%%%%%%%
function localResetCaret(eventSrc,eventData)
% Workaround to ensure that text in MWTextField is visible
set(eventSrc,'CaretPosition',1,'CaretPosition',0);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,s)
% Update GUI when property changes
Color = eventData.NewValue.Color;
s.E1.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.System));      % Plant & Sensor
s.E2.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Compensator)); % Compensator
s.E3.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.PreFilter));   % Prefilter
s.E4.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Response));    % Plot Lines
s.E5.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.ClosedLoop));  % Closed Loop
s.E6.setText(sprintf('[%0.3g %0.3g %0.3g]',Color.Margin));      % Margins


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h,action)
% Update property when GUI changes
Name = get(eventSrc,'Name');
LineStyle = h.LineStyle;
oldval = LineStyle.Color.(Name);
switch action
case 'edit'
   newval = evalnum(get(eventSrc,'Text'));
   if isempty(newval)
      %---Invalid number: revert to original value
      set(eventSrc,'Text',sprintf('[%0.3g %0.3g %0.3g]',oldval));
   elseif ~isequal(oldval,newval)
      newval = max(min(newval,1),0);
      set(eventSrc,'Text',sprintf('[%0.3g %0.3g %0.3g]',newval));
      LineStyle.Color.(Name) = newval;
      h.LineStyle = LineStyle;
   end
otherwise
   newval = uisetcolor(oldval,sprintf('Select Color: %s',action));
   if ~isequal(oldval,newval)
      LineStyle.Color.(Name) = newval;
      h.LineStyle = LineStyle;
   end
end


%%%%%%%%%%%
% evalnum %
%%%%%%%%%%%
function val = evalnum(val)
% Evaluate string val, returning valid real color vector only, empty otherwise
if ~isempty(val)
   val = evalin('base',val,'[]');
   if ~isnumeric(val) | ~(isreal(val) & isfinite(val) & isequal(size(val),[1 3]))
      val = [];
   end
end
