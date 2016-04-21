function TextBox = editColors(this,BoxLabel,BoxPool)
%EDITCOLORS  Builds group box for editing Colors.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:43 $

TextBox = find(handle(BoxPool),'Tag','Colors');
if isempty(TextBox)
   % Create groupbox if not found
   TextBox = LocalCreateUI;
end
TextBox.GroupBox.setLabel(sprintf(BoxLabel))
TextBox.Tag = 'Colors';

% Targeting
TextBox.Target = this;
props = [findprop(this,'XColor')];
TextBox.TargetListeners = ...
   handle.listener(this,props,'PropertyPostSet',{@localReadProp TextBox});

% Initialization
s = get(TextBox.GroupBox,'UserData');
set(s.AxesForegroundColor,'Text',sprintf('[%0.3g %0.3g %0.3g]',this.XColor));

%------------------ Local Functions ------------------------

function OptionsBox = LocalCreateUI()

% Toolbox Preferences
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

%---Store java handles
set(Main,'UserData',s);
%---Create @editbox instance
OptionsBox          = cstprefs.editbox;
OptionsBox.GroupBox = Main;

%---Install listeners and callbacks
GUICallback = {@localWriteProp,OptionsBox};
set(s.AxesForegroundColor,'Name','AxesForegroundColor',...
   'ActionPerformedCallback',GUICallback,'FocusLostCallback',GUICallback,...
   'ComponentResizedCallback',@localResetCaret);
set(s.Select,'Name','Select','ActionPerformedCallback',GUICallback);

%%%%%%%%%%%%%%%%%%%
% localResetCaret %
%%%%%%%%%%%%%%%%%%%
function localResetCaret(eventSrc,eventData)
% Workaround to ensure that text in MWTextField is visible
set(eventSrc,'CaretPosition',1,'CaretPosition',0);


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,OptionsBox)
% Update GUI when property changes
s = get(OptionsBox.GroupBox,'UserData');
switch eventSrc.Name
case 'XColor'
   s.AxesForegroundColor.setText(sprintf('[%0.3g %0.3g %0.3g]',eventData.NewValue));
end


%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,OptionsBox)
% Update property when GUI changes
h = OptionsBox.Target;
switch get(eventSrc,'Name')
case 'Select'
   oldval = h.XColor;
   val = uisetcolor(sprintf('Select Color: Axes Foreground'));
   if val == 0
      return;
   else
      if ~isequal(oldval,val)
         h.XColor = val;
         h.YColor = val;
      else
         return;
      end
   end
case 'AxesForegroundColor'
   oldval = get(h,'XColor');
   newval = evalnum(get(eventSrc,'Text'));
   if isempty(newval)
      %---Invalid number: revert to original value
      set(eventSrc,'Text',sprintf('[%0.3g %0.3g %0.3g]',oldval));
   elseif ~isequal(oldval,newval)
      newval = max(min(newval,1),0);
      h.XColor = newval;
      h.YColor = newval;
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
