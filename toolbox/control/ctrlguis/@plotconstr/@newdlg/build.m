function s = build(h)
%BUILD  Builds dialog GUI.

%   Authors: P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $ $Date: 2002/05/11 17:35:14 $

import com.mathworks.mwt.*;

% Definitions
Prefs = cstprefs.tbxprefs;
LEFT  = com.mathworks.mwt.MWLabel.LEFT;

% Frame
Frame = MWFrame(sprintf('New Constraint'));
Frame.setLayout(MWBorderLayout(0,0));
Frame.setFont(Prefs.JavaFontP);
set(Frame,'WindowClosingCallback',{@LocalHide h},'Resizable','off');

% Constraint Type
TypePanel = MWPanel(MWBorderLayout(10,0));
TypePanel.setInsets(java.awt.Insets(8,5,11,3)); % top, left, bottom, right
TypeText = MWLabel(sprintf(' Constraint Type:'),LEFT);
TypePanel.add(TypeText,MWBorderLayout.WEST);
TypeSelect = MWChoice;
TypePanel.add(TypeSelect,MWBorderLayout.CENTER);
TypeSelect.setFont(Prefs.JavaFontP);
set(TypeSelect,'ItemStateChangedCallback',{@LocalSetType h});
    
% Parameter frame
ParamBox = MWGroupbox(sprintf('Constraint Parameters'));
ParamBox.setLayout(MWBorderLayout(10,0));
ParamBox.setFont(Prefs.JavaFontP);

% Button panel
ButtonPanel = MWPanel(java.awt.FlowLayout(java.awt.FlowLayout.RIGHT,5,0));
ButtonPanel.setInsets(java.awt.Insets(2,0,3,0));
%---OK
OK = MWButton(sprintf('OK'));          
ButtonPanel.add(OK);
OK.setFont(Prefs.JavaFontP);
set(OK,'ActionPerformedCallback',{@LocalAddConstr h});
%---Cancel
Cancel = MWButton(sprintf('Cancel'));
ButtonPanel.add(Cancel);
Cancel.setFont(Prefs.JavaFontP);
set(Cancel,'ActionPerformedCallback',{@LocalHide h});
%---Help
Help = MWButton(sprintf('Help'));
ButtonPanel.add(Help);
Help.setFont(Prefs.JavaFontP);
set(Help,'ActionPerformedCallback', ...
	 'ctrlguihelp(''sisoconstraintnew'');');

% Put GUI together
Frame.add(TypePanel,MWBorderLayout.NORTH);
Frame.add(ParamBox,MWBorderLayout.CENTER);
Frame.add(ButtonPanel,MWBorderLayout.SOUTH);

% Store Handles
s = struct(...
	'Frame',Frame,...
	'ParamBox',ParamBox,...
	'TypeSelect',TypeSelect,...
	'Handles',{{TypePanel TypeText ButtonPanel OK Cancel Help}});


%---------------- Local functions ----------------------------------

%%%%%%%%%%%%%
% LocalHide %
%%%%%%%%%%%%%
function LocalHide(eventSrc,eventData,h)
% Hides dialog
h.close;

%%%%%%%%%%%%%%%%%%
% LocalAddConstr %
%%%%%%%%%%%%%%%%%%
function LocalAddConstr(eventSrc,eventData,h)
% Add constraint to client list (includes rendering)
Client = h.Client;
Constr = h.Constraint;

% Hide New Constraint dialog (decouples it from constraint)
h.close;

% Start recording
T = ctrluis.transaction(Constr,'Name','Add Constraint',...
    'OperationStore','on','InverseOperationStore','on');
% Create copy (ensures Undo Add works properly, especially wrt connect)
Constr = copy(Constr);
T.RootObject = Constr;
% Add to client list (takes care of rendering)
Client.addconstr(Constr);
% Mark constraint as selected
Constr.Selected = 'on';
% Commit and stack transaction
Constr.EventManager.record(T);

  
%%%%%%%%%%%%%%%%
% LocalSetType %
%%%%%%%%%%%%%%%%
function LocalSetType(PopUp,eventData,h)
% Select constraint type
ud = get(PopUp,'UserData');
h.settype(ud{get(PopUp,'SelectedIndex')+1});
