function s = build(h)
%BUILD  Builds dialog GUI.

%   Authors: P. Gahinet, Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $ $Date: 2002/11/11 22:22:54 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
GL_21 = java.awt.GridLayout(2,1,0,3);
LEFT    = MWLabel.LEFT;
BWEST   = MWBorderLayout.WEST;
BCENTER = MWBorderLayout.CENTER;

% Main Frame
Frame = MWFrame(sprintf('Edit Constraints'));
Frame.setLayout(MWBorderLayout(0,0));
Frame.setFont(Prefs.JavaFontP);
set(Frame, 'WindowClosingCallback', {@LocalHide h}, 'Resizable', 'off');

% Constraint Panel
P1 = MWPanel(MWBorderLayout(0,0));
P1.setInsets(java.awt.Insets(8,5,11,5)); % top, left, bottom, right
Frame.add(P1, MWBorderLayout.NORTH);

% Editor/Constraint text
P2 = MWPanel(GL_21);
T1 = MWLabel(sprintf('Editor:'), LEFT);
T1.setFont(Prefs.JavaFontP)
P2.add(T1);
T2 = MWLabel(sprintf('Constraint: '), LEFT);
T2.setFont(Prefs.JavaFontP)
P2.add(T2);
P1.add(P2, BWEST);

% Editor/Constraint drop-down list
P3 = MWPanel(GL_21);
EditorSelect = MWChoice;
EditorSelect.setFont(Prefs.JavaFontP);
P3.add(EditorSelect);
set(EditorSelect, 'ItemStateChangedCallback', {@LocalSetEditor h});
ConstrSelect = MWChoice;
ConstrSelect.setFont(Prefs.JavaFontP);
P3.add(ConstrSelect);
set(ConstrSelect, 'ItemStateChangedCallback', {@LocalSetConstr h});
P1.add(P3, BCENTER);

% Parameter frame
ParamBox = MWGroupbox(sprintf('Constraint Parameters'));
ParamBox.setLayout(MWBorderLayout(10,0));
ParamBox.setFont(Prefs.JavaFontP);
Frame.add(ParamBox, MWBorderLayout.CENTER);

% Button panel
ButtonPanel = MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
ButtonPanel.setInsets(java.awt.Insets(2,0,3,0));
Frame.add(ButtonPanel, MWBorderLayout.SOUTH);
% Close button
Close = MWButton(sprintf('Close'));
Close.setFont(Prefs.JavaFontP);
ButtonPanel.add(Close);
set(Close,'ActionPerformedCallback', {@LocalHide h});
% Help button
Help = MWButton(sprintf('Help'));
Help.setFont(Prefs.JavaFontP);
ButtonPanel.add(Help);
set(Help,'ActionPerformedCallback', ...
	 'ctrlguihelp(''sisoconstraintedit'');');

% Store Handles
s = struct('Frame', Frame, ...
	   'ParamBox', ParamBox, ...
	   'ConstrSelect', ConstrSelect, ...
	   'EditorSelect', EditorSelect, ...
	   'Handles', {{P1 P2 P3 ButtonPanel T1 T2 Close Help}});


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalHide
% Purpose:  Hides dialog
% ----------------------------------------------------------------------------%
function LocalHide(eventSrc, eventData, h)
h.close;

% ----------------------------------------------------------------------------%
% Function: LocalSetConstr
% Purpose:  Select constraint to edit
% ----------------------------------------------------------------------------%
function LocalSetConstr(PopUp, eventData, h)
List = h.ConstraintList;
index = get(PopUp, 'SelectedIndex') + 1;
h.target(h.Container, List(index));

% ----------------------------------------------------------------------------%
% Function: LocalSetEditor
% Purpose:  Select Container of constraints.
% ----------------------------------------------------------------------------%
function LocalSetEditor(PopUp, eventData, h)
List = h.getlist('ActiveContainers');
index = get(PopUp, 'SelectedIndex') + 1;
h.target(List(index));

