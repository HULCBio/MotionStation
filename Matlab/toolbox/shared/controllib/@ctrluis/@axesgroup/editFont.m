function FontBox = editFont(this,BoxLabel,BoxPool,FontData)
%EDITLABELS  Builds group box for editing Labels.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:17:06 $

% Look for a group box with matching Tag in the pool of group boxes
FontBox = find(handle(BoxPool),'Tag','Fonts');
if isempty(FontBox)
   % Create group box if not found
   FontBox = LocalCreateUI(FontData);
end
FontBox.GroupBox.setLabel(sprintf(BoxLabel))
FontBox.Data = FontData;
FontBox.Tag = 'Fonts';

% Targeting and initialization 
RowSelectors = get(FontBox.GroupBox,'UserData');  % struct array of Java handles
for ct = 1:length(RowSelectors)
   EditedStyles = FontBox.Data(ct).FontTarget;
   select(RowSelectors(ct).Size,(EditedStyles(1).FontSize - 8)/2);
   setState(RowSelectors(ct).Weight,strcmpi(EditedStyles(1).FontWeight,'bold'));
   setState(RowSelectors(ct).Angle,strcmpi(EditedStyles(1).FontAngle,'italic'));
   % Listeners
   props = [findprop(EditedStyles(1),'FontSize');...
         findprop(EditedStyles(1),'FontWeight');...
         findprop(EditedStyles(1),'FontAngle')];
   TargetListeners(ct) = handle.listener(EditedStyles,props,...
      'PropertyPostSet',{@localReadProp RowSelectors(ct) EditedStyles});
end

FontBox.Target = this;
FontBox.TargetListeners = TargetListeners;


%------------------ Local Functions ------------------------
function FontBox = LocalCreateUI(Data)
% Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
FontBox = cstprefs.editbox;
FontBox.Data = Data;
nrows = length(Data);
%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox;
Main.setLayout(java.awt.GridLayout(nrows,1,0,3));
Main.setFont(Prefs.JavaFontB);
%---Add a font panel for each text group
for ct = 1:nrows
   [RowPanel,JavaHandles(ct,1)] = ...
      localFontPanel(FontBox,FontBox.Data(ct).FontLabel,ct); 
   Main.add(RowPanel);
end
%---Store java handles
set(Main,'UserData',JavaHandles);
FontBox.GroupBox = Main;


%%%%%%%%%%%%%%%%%%
% localFontPanel %
%%%%%%%%%%%%%%%%%%
function [Panel,s] = localFontPanel(FontBox,Label,RowIndex)
% Create a java panel for editing font properties
%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Build GUI
Panel = com.mathworks.mwt.MWPanel(com.mathworks.mwt.MWBorderLayout(0,0));
s.Label = com.mathworks.mwt.MWLabel(sprintf('%s',Label),com.mathworks.mwt.MWLabel.LEFT);
s.Label.setFont(Prefs.JavaFontP);
Panel.add(s.Label,com.mathworks.mwt.MWBorderLayout.WEST);
s.East = com.mathworks.mwt.MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,15,0));
Panel.add(s.East,com.mathworks.mwt.MWBorderLayout.EAST);
s.Size = com.mathworks.mwt.MWChoice; s.East.add(s.Size);
s.Size.setFont(Prefs.JavaFontP);
for n=8:2:16
   s.Size.add(sprintf('%d pt',n));
end
s.Weight = com.mathworks.mwt.MWCheckbox(sprintf('Bold')); s.East.add(s.Weight);
s.Weight.setFont(Prefs.JavaFontB);
s.Angle = com.mathworks.mwt.MWCheckbox(sprintf('Italic')); s.East.add(s.Angle);
s.Angle.setFont(Prefs.JavaFontI);
% GUI callbacks
%---FontSize callback
set(s.Size,    'Name','FontSize',  'ItemStateChangedCallback',{@localWriteProp,FontBox,RowIndex});
%---FontWeight callback
set(s.Weight,  'Name','FontWeight','ItemStateChangedCallback',{@localWriteProp,FontBox,RowIndex});
%---FontAngle callback
set(s.Angle,   'Name','FontAngle', 'ItemStateChangedCallback',{@localWriteProp,FontBox,RowIndex});


%%%%%%%%%%%%%%%%%
% localReadProp %
%%%%%%%%%%%%%%%%%
function localReadProp(eventSrc,eventData,JavaHandles,EditedStyles)
% Update GUI when property object changes
switch char(eventSrc.Name)
case 'FontSize'
   JavaHandles.Size.select((eventData.NewValue-8)/2);
   Value = 8 + 2*get(JavaHandles.Size,'SelectedIndex');
   set(EditedStyles,'FontSize',Value);
case 'FontWeight'
   JavaHandles.Weight.setState(strcmpi(eventData.NewValue,'bold'));
   if strcmpi(get(JavaHandles.Weight,'State'),'on')
      Value = 'bold';
   else
      Value = 'normal';
   end
   set(EditedStyles,'FontWeight',Value);
case 'FontAngle'
   JavaHandles.Angle.setState(strcmpi(eventData.NewValue,'italic'));
   if strcmpi(get(JavaHandles.Angle,'State'),'on')
      Value = 'italic';
   else
      Value = 'normal';
   end
   set(EditedStyles,'FontAngle',Value);
end

%%%%%%%%%%%%%%%%%%
% localWriteProp %
%%%%%%%%%%%%%%%%%%
function localWriteProp(eventSrc,eventData,FontBox,RowIndex)
% Update property object when GUI changes
EditedStyles = FontBox.Data(RowIndex).FontTarget;
switch get(eventSrc,'Name')
case 'FontSize'
   Value = 8 + 2*get(eventSrc,'SelectedIndex');
   set(EditedStyles,'FontSize',Value);
case 'FontWeight'
   if strcmpi(get(eventSrc,'State'),'on')
      Value = 'bold';
   else
      Value = 'normal';
   end
   set(EditedStyles,'FontWeight',Value);
case 'FontAngle'
   if strcmpi(get(eventSrc,'State'),'on')
      Value = 'italic';
   else
      Value = 'normal';
   end
   set(EditedStyles,'FontAngle',Value);
end
