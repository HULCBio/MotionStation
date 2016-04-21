function Frame = clview2(sisodb)
%CLVIEW  Creates and manages the closed-loop data view.
%
%   See also SISOTOOL.

%   Authors:  Bora Eryilmaz
%   Revised:
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.9.4.2 $ $Date: 2004/04/10 23:14:23 $

% Import Java packages
import com.mathworks.mwt.*;
import java.awt.*;

% GUI data structure
s = struct(...
    'LoopData', sisodb.LoopData, ...
    'Preferences', cstprefs.tbxprefs, ...
    'sPreferences', sisodb.Preferences, ...
    'Table', [], ...
    'Handles', [], ...
    'Listeners', []);

% Create main Frame
Frame = MWFrame(sprintf('Closed-Loop Pole Viewer'));
Frame.setLayout(MWBorderLayout(0,0));
Frame.setFont(s.Preferences.JavaFontP);
set(Frame, 'HandleVisibility', 'off', ...
	   'Resizable', 'off');

% Main panel
MainPanel = MWPanel(MWBorderLayout(0,0));
MainPanel.setInsets(Insets(10,5,5,5));
Frame.add(MainPanel, MWBorderLayout.CENTER);
s.Handles = {MainPanel};

% Add list and button panels
[ListPanel, s]   = LocalAddList(Frame, s);
[ButtonPanel, s] = LocalAddButton(Frame, s);
MainPanel.add(ListPanel,   MWBorderLayout.CENTER);
MainPanel.add(ButtonPanel, MWBorderLayout.SOUTH);

% Layout the frame
Frame.pack;

% Center wrt SISO Tool window
centerfig(Frame, sisodb.Figure);

% Install listeners
lsnr(1) = handle.listener(s.LoopData, ...
	  'ObjectBeingDestroyed', {@LocalClose Frame});
lsnr(2) = handle.listener(s.LoopData, ...
	  'LoopDataChanged', {@LocalRefresh Frame});
p = findprop(s.sPreferences, 'FrequencyUnits');
lsnr(3) = handle.listener(s.sPreferences, p, ...
			  'PropertyPostSet', {@LocalRefresh Frame});
s.Listeners = lsnr;

% Set callbacks and store handles 
set(Frame, 'WindowClosingCallback', {@LocalHide Frame}, 'UserData', s);
LocalRefresh([], [], Frame);  % populate to limit flashing

% Make frame visible
Frame.show;
Frame.toFront;


% ----------------------------------------------------------------------------%
% Callback Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalHide
% Purpose:  Hide dialog Frame
% ----------------------------------------------------------------------------%
function LocalHide(hSrc, event, f)
f.hide;

% ----------------------------------------------------------------------------%
% Function: LocalClose
% Purpose:  Destroy dialog Frame
% ----------------------------------------------------------------------------%
function LocalClose(hSrc, event, f)
f.hide;
f.dispose;

% ----------------------------------------------------------------------------%
% Function: LocalRefresh
% Purpose:  Refresh the content of the list (closed-loop pole info)
% ----------------------------------------------------------------------------%
function LocalRefresh(hSrc, event, Frame, sisodb)
s = get(Frame, 'UserData');
if ~isa(s.LoopData, 'sisodata.loopdata')
  % Protect against race condition when SISO Tool is closed
  return
end

% Get closed-loop poles
% RE: Use same algorithm as in RLEDITOR/UPDATEPLOT for consistency
OL = getopenloop(s.LoopData);
if isempty(OL)
   P = [];
else
   P = fastrloc(OL,getzpkgain(s.LoopData.Compensator,'mag'));
end

% Group the Poles into real and complex values
im = imag(P);
P = [P(~im,:) ; P(im>0,:)];

% Add text for pole data
if isempty(P)
  PoleText = cell(1,3);
  PoleText(1,1) = {sprintf('<None>')};
else
  % Natural frequencies )in current units) and damping ratios
  [Wn, Z] = damp(P, s.LoopData.Ts);
  Wn = unitconv(Wn, 'rad/sec', s.sPreferences.FrequencyUnits);
  PoleText = cell(length(P), 3);
  
  % Populate the list
  for ct = 1:length(P),
    rP = real(P(ct));
    iP = imag(P(ct));
    if iP
      PoleText(ct,1) = {sprintf('%0.3g %s %0.3gi', rP, char(177), iP)};
    else
      PoleText(ct,1) = {sprintf('%0.3g', rP)};
    end
    PoleText(ct,2) = {sprintf('%0.3g', Z(ct))};
    PoleText(ct,3) = {sprintf('%0.3g', Wn(ct))};
  end
end

% Adjust table size
Table = s.Table;
TData = Table.getData;
nrows = Table.getTableSize.height;
npoles = length(P);
if (npoles > nrows)
  TData.addRows(nrows, npoles-nrows);
elseif (npoles<nrows) & (npoles>=10)
  % REM: Magic number 10: initial number of rows
  TData.removeRows(npoles, nrows-npoles);
end

% Update table content
minrows = max(1, npoles); % if npoles = 0, display <none> for no poles.
for ctcol = 1:3,
  for ctrow = 1:minrows 
    TData.setData(ctrow-1, ctcol-1, PoleText{ctrow,ctcol});
  end
  for ctrow = minrows+1:Table.getTableSize.height
    TData.setData(ctrow-1, ctcol-1, '');
  end
end

% Store modified data
set(Frame, 'UserData', s)


% ----------------------------------------------------------------------------%
% Local Functions
% ----------------------------------------------------------------------------%

% ----------------------------------------------------------------------------%
% Function: LocalAddButton
% Purpose:  Adds Close button (and Help if needed)
% ----------------------------------------------------------------------------%
function [Panel, s] = LocalAddButton(Frame, s)
import com.mathworks.mwt.*;
import java.awt.*;

% Button panel
Panel = MWPanel(FlowLayout);

% Close button
closeButton = MWButton(sprintf('Close'));  
closeButton.setFont(s.Preferences.JavaFontP);
set(closeButton, 'ActionPerformedCallback', {@LocalHide Frame})

% Help button
% helpButton = MWButton(sprintf('Help'));       
% helpButton.setFont(s.Preferences.JavaFontP);
% set(helpButton, 'ActionPerformedCallback', ...
%         	'ctrlguihelp(''sisoclosedpoleview'');')

% Connect components
Panel.add(closeButton);
% Panel.add(helpButton);

% Store handle for persistency
% s.Handles = [s.Handles ; {Panel;cancelButton;helpButton}];
s.Handles = [s.Handles ; {Panel;closeButton}];


% ----------------------------------------------------------------------------%
% Function: LocalAddList
% Purpose:  Adds closed-loop poles list to the List panel
% ----------------------------------------------------------------------------%
function [Panel, s] = LocalAddList(Frame, s)
import com.mathworks.mwt.*;
import java.awt.*;

% Main panel
Panel = MWGroupbox(sprintf('Closed-Loop Poles'));
Panel.setLayout(MWBorderLayout(0,5));
Panel.setFont(s.Preferences.JavaFontB);

% Table view
Table = MWTable(10,3);
Table.setPreferredTableSize(8,4);
Table.getTableStyle.setFont(s.Preferences.JavaFontP);
Table.getColumnOptions.setResizable(1);
Table.getHScrollbarOptions.setMode(-1);

% Table style parameters
Cstyle = table.Style(table.Style.BACKGROUND);
Cstyle.setBackground(java.awt.Color(.94,.94,.94));

% First column
Table.setColumnStyle(0, Cstyle);
Table.setColumnWidth(0, 100);
Table.setColumnHeaderData(0, sprintf('Pole Value'));

% Second column
Table.setColumnStyle(1, Cstyle);
Table.setColumnWidth(1, 100);
Table.setColumnHeaderData(1, sprintf('Damping'));

% Third column
Table.setColumnStyle(2, Cstyle);
Table.setColumnWidth(2, 100);
Table.setColumnHeaderData(2, sprintf('Frequency'));

Table.setAutoExpandColumn(0);
Table.getRowOptions.setHeaderVisible(0);
Table.getSelectionOptions.setMode(0);      % none

% Connect components
Panel.add(Table, MWBorderLayout.CENTER);

% Store handle for persistency
s.Table = Table;
s.Handles = [s.Handles ; {Panel}];
