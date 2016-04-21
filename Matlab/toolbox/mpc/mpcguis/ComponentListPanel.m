function [Panel, Buttons, NotesArea] = ComponentListPanel( Width, ...
    UTitle, LTitle, NTitle, UContent, ButtonLabels, ButtonFields, LContent);

% Creates panel to hold list of models, controllers, or scenarios

%	Author:  Larry Ricker
%	Copyright 1986-2003 The MathWorks, Inc. 
%	$Revision: 1.1.8.2 $  $Date: 2003/12/04 01:35:51 $

import com.mathworks.toolbox.mpc.*;
import com.mathworks.mwswing.*;
import javax.swing.*;
import javax.swing.border.*;
import java.awt.*;

% Larry Ricker

TitleFont = Font('Dialog',Font.PLAIN,12);
UTitledBorder = TitledBorder(UTitle);
UTitledBorder.setTitleFont(TitleFont);
LTitledBorder = TitledBorder(LTitle);
LTitledBorder.setTitleFont(TitleFont);
c = GridBagConstraints;

% Upper section

% Upper content -- add table contained in scroller
UContent.Table.setRowSelectionAllowed(true);
UContent.Table.setShowHorizontalLines(true);
UContent.Table.setShowVerticalLines(false);

% Button panel at bottom of upper section
Buttons=[];
ButPanel = MJPanel;
ButPanel.setLayout(GridBagLayout);
c.fill = GridBagConstraints.NONE;
c.gridx = GridBagConstraints.RELATIVE;
c.gridy = 0;
c.weightx = 0;
c.weighty = 0;
c.insets = Insets(5, 5, 5, 5);
for i = 1:length(ButtonLabels)
    thisButton = MJButton(ButtonLabels{i});
    FieldName = ButtonFields{i};
    k = strfind(FieldName, ' ');
    if ~isempty(k)
        FieldName = FieldName(1:k(1)-1);
    end
    Buttons = setfield(Buttons,FieldName,thisButton);
    ButPanel.add(thisButton, c);
end 

UPanel = MJPanel;
UPanel.setBorder(UTitledBorder);
UPanel.setLayout(GridBagLayout);
c.fill = GridBagConstraints.BOTH;
c.gridx = 0;
c.gridy = 0;
c.weightx = 1;
c.weighty = 1;
c.insets = Insets(0, 0, 0, 0);
UPanel.add(MJScrollPane(UContent.Table), c);
c.gridy = 1;
c.weighty = 0;
UPanel.add(ButPanel, c);

% Summary content -- add something in a scroller
Size = Dimension(Width+30,160);
LContent.setBorder(LTitledBorder);
LContent.setPreferredSize(Size);

NotesArea = MJTextArea;
NotesArea.setLineWrap(true);
NotesArea.setWrapStyleWord(true);
NotesArea.setEditable(true);
NotesScroll = MJScrollPane(NotesArea);
NotesScroll.setPreferredSize(Size);
NotesTitle = TitledBorder(NTitle);
NotesTitle.setTitleFont(TitleFont);
NotesScroll.setBorder(NotesTitle);
NotesScroll.setViewportBorder(BorderFactory.createLoweredBevelBorder);

Panel = MJPanel;
Panel.setLayout(GridBagLayout);
c.gridx = 0;
c.gridy = GridBagConstraints.RELATIVE;
c.weightx = 1;
c.weighty = 0.4;
c.fill = GridBagConstraints.BOTH;
c.insets = Insets(2, 10, 3, 10);
Panel.add(UPanel, c);
c.weighty = 0.3;
Panel.add(LContent, c);
Panel.add(NotesScroll, c);
