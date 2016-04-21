function Main = clr_gui(h)
%CLR_GUI  GUI for editing color properties of h

%   Author(s): A. DiVergilio
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2004/04/10 23:14:18 $

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;

%---Definitions
WEST   = com.mathworks.mwt.MWBorderLayout.WEST;
CENTER = com.mathworks.mwt.MWBorderLayout.CENTER;
EAST   = com.mathworks.mwt.MWBorderLayout.EAST;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Colors'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(10,0));
Main.setFont(Prefs.JavaFontB);

%---Axes Foreground
s.Label = com.mathworks.mwt.MWLabel(sprintf('Axes foreground:')); Main.add(s.Label,WEST);
s.Label.setFont(Prefs.JavaFontP);
s.AxesForegroundColor = com.mathworks.mwt.MWTextField(12); Main.add(s.AxesForegroundColor,CENTER);
s.AxesForegroundColor.setFont(Prefs.JavaFontP);
s.Select = com.mathworks.mwt.MWButton(sprintf('Select...')); Main.add(s.Select,EAST);
s.Select.setFont(Prefs.JavaFontP);

%---Tooltips
str = 'Set color for plot box, tick labels, and grid lines';
s.LabelTT  = com.mathworks.mwt.MWToolTip(s.Label,sprintf('%s',str));
s.EditTT   = com.mathworks.mwt.MWToolTip(s.AxesForegroundColor,sprintf('%s',str));
s.SelectTT = com.mathworks.mwt.MWToolTip(s.Select,sprintf('Open color selection dialog'));

%---Install listeners and callbacks
Callback = {@localReadProp,s};
GUICallback = {@localWriteProp,h};
   %---AxesForegroundColor
    EventSrc = findprop(h,'AxesForegroundColor');
    s.AxesForegroundColorListener = handle.listener(h,EventSrc,'PropertyPostSet',Callback);
    set(s.AxesForegroundColor,'Name','AxesForegroundColor',...
       'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback,...
       'ComponentResizedCallback',@localResetCaret);
    set(s.Select,'Name','Select','ActionPerformedCallback',GUICallback);

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
switch eventSrc.Name
case 'AxesForegroundColor'
   s.AxesForegroundColor.setText(sprintf('[%0.3g %0.3g %0.3g]',eventData.NewValue));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,h)
% Update property when GUI changes
switch get(eventSrc,'Name')
case 'Select'
   oldval = h.AxesForegroundColor;
   val = uisetcolor(oldval,sprintf('Select Color: Axes Foreground'));
   if ~isequal(oldval,val)
      h.AxesForegroundColor = val;
   end
case 'AxesForegroundColor'
   oldval = h.AxesForegroundColor;
   newval = evalnum(get(eventSrc,'Text'));
   if isempty(newval)
      %---Invalid number: revert to original value
      set(eventSrc,'Text',sprintf('[%0.3g %0.3g %0.3g]',oldval));
   elseif ~isequal(oldval,newval)
      newval = max(min(newval,1),0);
      set(eventSrc,'Text',sprintf('[%0.3g %0.3g %0.3g]',newval));
      h.AxesForegroundColor = newval;
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
