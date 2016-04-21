function MPCoptionDialog( ...

% Copyright 2003 The MathWorks, Inc.

    Title, Message, Options, Actions, nHor, nVer, HelpCB)

% Creates a modal dialog presenting two or more options, each
% represented by a radio button.  Regular buttons are "OK", "Cancel", and
% "Help".  Callback HelpCB will execute if the user pushes the help button.
% If "OK", Choice is the index of the current selection.  If "Cancel" or
% close, Choice is empty.  By default, the first option is selected.
% Choice is returned in global MPC_CHOICE

global MPC_CHOICE MPC_OPTION_DIALOG

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Panel
Dialog = MJDialog;
Dialog.setModal(1);
Dialog.setSize(Dimension(nHor,nVer));
Dialog.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
Dialog.setTitle('MPC Options');
Dialog.setResizable(false);

% Components
Panel = MJPanel(GridBagLayout);
PanelTitle = TitledBorder(Title);
PanelTitle.setTitleFont(Font('Dialog',Font.BOLD,18));
Panel.setBorder(PanelTitle);

Num = length(Options);
c = GridBagConstraints;
c.gridx = 0;
c.gridy = GridBagConstraints.RELATIVE;
c.fill = GridBagConstraints.HORIZONTAL;
c.weightx = 1;
c.weighty = 0;
c.insets = Insets(0, 5, 5, 5);

HTML = '<html><FONT face = "Arial">';
FontOFF = '</FONT>';
HTML = '';
FontOFF = '';
Panel.add(MJLabel([HTML, Message, FontOFF]), c);
rbGroup = ButtonGroup;
Handles = [];
c.insets = Insets(5, 5, 5, 5);

for i = 1:Num
    thisRB = MJRadioButton([HTML, Options{i}, FontOFF],false);
    Handles = setfield(Handles, Actions{i}, thisRB);
    rbGroup.add(thisRB);
    Panel.add(thisRB, c);
end
RB1 = getfield(Handles, Actions{1});
RB1.setSelected(true);

Buttons = MJPanel;
OKButton = MJButton('OK');
CancelButton = MJButton('Cancel');
HelpButton = MJButton('Help');
Buttons.add(OKButton);
Buttons.add(CancelButton);
Buttons.add(HelpButton);

Handles.OKButton = OKButton;
Handles.CancelButton = CancelButton;
Handles.HelpButton = HelpButton;
Handles.Actions = Actions;

set(OKButton,'ActionPerformedCallback',{@LocalOKCB});
set(CancelButton,'ActionPerformedCallback',{@LocalCancelCB});
set(HelpButton,'ActionPerformedCallback',{HelpCB});

Panel.add(Buttons, c);

MPC_CHOICE = [];
MPC_OPTION_DIALOG = Dialog;
set(MPC_OPTION_DIALOG, 'UserData', Handles)

Dialog.getContentPane.add(Panel);
Dialog.setVisible(true);
Dialog.pack;

% -----------------------------------------------

function LocalOKCB(varargin);

% React to OK -- determine option chosen
global MPC_CHOICE MPC_OPTION_DIALOG
import com.mathworks.mwswing.*;

Handles = get(MPC_OPTION_DIALOG, 'UserData');
Num = length(Handles.Actions);
MPC_CHOICE = [];
for i = 1:Num
    thisRB = getfield(Handles, Handles.Actions{i});
    if thisRB.isSelected
        MPC_CHOICE = i;
        break
    end
end
MPC_OPTION_DIALOG.dispose;
clear global MPC_OPTION_DIALOG

% -----------------------------------------------

function LocalCancelCB(varargin)

% React to user cancel or close
global MPC_CHOICE MPC_OPTION_DIALOG

import com.mathworks.mwswing.*;

MPC_CHOICE = [];
MPC_OPTION_DIALOG.dispose;
clear global MPC_OPTION_DIALOG