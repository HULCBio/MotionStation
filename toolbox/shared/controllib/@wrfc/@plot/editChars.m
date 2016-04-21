function TextBox = editChars(this,BoxLabel,BoxPool)
%EDITCHARS  Builds group box for editing Characteristics.

%   Author (s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:27:18 $

% Look for a group box with matching Tag in the pool of group boxes
TextBox = find(handle(BoxPool),'Tag',BoxLabel);
if isempty(TextBox)
   % Create group box if not found
   TextBox = LocalCreateUI(this);
end
%------------------ Local Functions ------------------------
function TextBox = LocalCreateUI(h)

%---Get Toolbox Preferences
Prefs = cstprefs.tbxprefs;
%---Create @editbox instance
TextBox = cstprefs.editbox;

%---Top-level panel (MWGroupbox)
Main = com.mathworks.mwt.MWGroupbox(sprintf('Characteristics'));
Main.setLayout(com.mathworks.mwt.MWBorderLayout(0,0));
Main.setFont(Prefs.JavaFontB);

s.NullString = com.mathworks.mwt.MWLabel(sprintf('(No options available for selected response plot)'));
s.NullString.setFont(Prefs.JavaFontP);
Main.add(s.NullString,com.mathworks.mwt.MWBorderLayout.NORTH);

%---Store java handles
set(Main,'UserData',s);
TextBox.GroupBox = Main;
TextBox.Tag = 'Characteristics';
