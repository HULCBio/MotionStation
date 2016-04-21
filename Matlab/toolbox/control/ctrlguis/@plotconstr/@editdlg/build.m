function s = build(h)
%BUILD  Builds dialog GUI.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/04/10 05:08:55 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
LEFT  = com.mathworks.mwt.MWLabel.LEFT;

% Frame
Frame = MWFrame(sprintf('Edit Constraint'));
Frame.setLayout(MWBorderLayout(0,0));
Frame.setFont(Prefs.JavaFontP);
set(Frame,'WindowClosingCallback',{@LocalHide h},'Resizable','off');

% Constraint Type
TypePanel = MWPanel(MWBorderLayout(10,0));
TypePanel.setInsets(java.awt.Insets(8,5,11,3)); % top, left, bottom, right
TypeText = MWLabel(sprintf(' Constraint Type:'),LEFT);
TypePanel.add(TypeText,MWBorderLayout.WEST);
TypeDescription = MWLabel('',LEFT);
TypePanel.add(TypeDescription,MWBorderLayout.CENTER);
TypeDescription.setFont(Prefs.JavaFontP);
    
% Parameter frame
ParamBox = MWGroupbox(sprintf('Constraint Parameters'));
ParamBox.setLayout(MWBorderLayout(10,0));
ParamBox.setFont(Prefs.JavaFontP);

% Button panel
ButtonPanel = MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
ButtonPanel.setInsets(java.awt.Insets(2,0,3,0));
%---Close
Close = MWButton(sprintf('Close'));    ButtonPanel.add(Close);
Close.setFont(Prefs.JavaFontP);
set(Close,'ActionPerformedCallback',{@LocalHide h});
%---Help
Help = MWButton(sprintf('Help'));      ButtonPanel.add(Help);
Help.setFont(Prefs.JavaFontP);
set(Help,'ActionPerformedCallback', ...
	 'ctrlguihelp(''sisoconstraintedit'');');


% Put GUI together
Frame.add(TypePanel,MWBorderLayout.NORTH);
Frame.add(ParamBox,MWBorderLayout.CENTER);
Frame.add(ButtonPanel,MWBorderLayout.SOUTH);

% Store Handles
s = struct('Frame', Frame, ...
	   'ParamBox', ParamBox, ...
	   'TypeDescription', TypeDescription, ...
	   'Handles', {{TypePanel TypeText ButtonPanel Close Help}});


%---------------- Local functions ----------------------------------

%%%%%%%%%%%%%
% LocalHide %
%%%%%%%%%%%%%
function LocalHide(eventSrc,eventData,h)
% Hides dialog
h.close;
