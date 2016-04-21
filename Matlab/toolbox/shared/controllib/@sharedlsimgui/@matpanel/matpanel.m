function h = matpanel(importSelector)
% MATPANEL @matpanel constructor
%
% Builds the MAT file import panel. Returns handles to components
% with callbacks, since there need to remain in scope
%
% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:48 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h= sharedlsimgui.matpanel;


% Panel organization

% ______________________        
% PNLdata               |       
% ___________           |       
% |PNLfile    |         |       
% |___________|         |       
%                       |       
% ____________          |       
% |PNLbrowser |         |       
% |___________|         |       
% ______________________        

%workspace browser
h.matbrowser = sharedlsimgui.varbrowser;
h.matbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
        'int16','int32'};
h.matbrowser.javahandle.setName('matimport:browser:matvars');
% assign the copy callback
h.matbrowser.addlisteners(handle.listener(h.matbrowser,'rightmenuselect',...
    {@localWorkpsaceCopy importSelector}));

PNLbrowser = JPanel(BorderLayout(10,10));
PNLbrowser.add(h.matbrowser.javahandle,BorderLayout.CENTER);



PNLrowcols =  JPanel(GridLayout(2,1,5,5));
PNLcols =  JPanel(FlowLayout.LEFT);
PNLrows = JPanel(FlowLayout.LEFT);
PNLcolsOuter =  JPanel(BorderLayout);
PNLrowsOuter = JPanel(BorderLayout);

% Define radio buttons
h.FilterHandles.radioRow = JRadioButton('Assign rows');
h.FilterHandles.radioCol = JRadioButton('Assign columns');
h.FilterHandles.radioRow.setPreferredSize(h.FilterHandles.radioCol.getPreferredSize);
h.FilterHandles.radioCol.setSelected(true);
btngrp = ButtonGroup;
btngrp.add(h.FilterHandles.radioRow);
btngrp.add(h.FilterHandles.radioCol);
PNLcols.add(h.FilterHandles.radioCol);
PNLrows.add(h.FilterHandles.radioRow);

% Define row/col selection text boxes
h.FilterHandles.TXTselectedCols = JTextField(5);
h.FilterHandles.TXTselectedCols.setName('workimport:textfield:whichcols');
h.FilterHandles.TXTselectedRows = JTextField(5);
h.FilterHandles.TXTselectedRows.setName('workimport:textfield:whichrows');
PNLcols.add(h.FilterHandles.TXTselectedCols);
PNLrows.add(h.FilterHandles.TXTselectedRows);

% Add "to where" labels
PNLcols.add(JLabel('to selected channel(s)'));
PNLrows.add(JLabel('to selected channel(s)'));

% Assemble row col section panel
PNLcolsOuter.add(PNLcols,BorderLayout.WEST);
PNLrowsOuter.add(PNLrows,BorderLayout.WEST);
PNLrowcols.add(PNLcolsOuter);
PNLrowcols.add(PNLrowsOuter);

PNLbrowser.add(PNLrowcols,BorderLayout.SOUTH);
PNLbrowser.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

% file panel
PNLfile = JPanel(BorderLayout);
PNLfileinner = JPanel;
LBLfile = JLabel('File:',SwingConstants.LEFT);
h.Jhandles.TXTfile = JTextField;
h.Jhandles.TXTfile.setName('matimport:textfield:filename');
h.Jhandles.TXTfile.setColumns(12);
h.Jhandles.BTNfile = JButton('Browse...');
h.Jhandles.BTNfile.setName('matimport:button:browse');
PNLfileinner.add(LBLfile);
PNLfileinner.add(h.Jhandles.TXTfile);
PNLfileinner.add(h.Jhandles.BTNfile);
PNLfile.add(PNLfileinner,BorderLayout.WEST);

% file open callbacks
set(h.Jhandles.BTNfile, 'ActionPerformedCallBack', {@localMATfileOpen h});
set(h.Jhandles.TXTfile, 'ActionPerformedCallBack', {@localthisMATfileOpen h});

% list selection listener
radios = {h.FilterHandles.radioCol, h.FilterHandles.radioRow};
selections = {h.FilterHandles.TXTselectedCols h.FilterHandles.TXTselectedRows};
h.matbrowser.addlisteners(handle.listener(h.matbrowser,'listselect',...
      {@localMatSelect h.matbrowser, radios, selections}));

% Radio button selection listener
set(h.FilterHandles.radioCol, 'StateChangedCallback', ...
     {@localMatSelect h.matbrowser, radios, selections});

PNLfile.setBorder(BorderFactory.createEmptyBorder(0,10,0,0));

PNLdata = JPanel(BorderLayout);
PNLdata.add(PNLfile,BorderLayout.NORTH);
PNLdata.add(PNLbrowser,BorderLayout.CENTER);
%PNLdata.setBorder(BorderFactory.createTitledBorder('Data source:'));

h.Panel = PNLdata;


%-------------------- Local Functions ---------------------------

function localWorkpsaceCopy(eventSrc, eventData, importSelector)

importSelector.matpanel.import(importSelector.importtable,'copy');

function localMATfileOpen(eventSrc, eventData, h)

[fname pname] = uigetfile([h.Folder '*.mat'],'Select MAT file');
if strcmp(class(fname),'char')
    h.Jhandles.TXTfile.setText([pname fname]);
    h.Folder = pname;
    localthisMATfileOpen([], [], h.matbrowser,h.Jhandles.TXTfile)  
end

function localthisMATfileOpen(eventSrc, eventData, matbrowser,TXTfile)

try
    matbrowser.filename = char(TXTfile.getText);
    matbrowser.open
catch
    matbrowser.filename = '';
    TXTfile.setText('');
    errordlg('Invalid file or file not found', 'MAT File Import','modal')
end


function localMatSelect(eventSrc, eventData, h, radios, TXTcolrow)

% listener callback to write the number of cols/rows of the selected 
% variable to the workbrowser "columns selected" textbox

varstruc = h.getSelectedVarInfo;
dim = double(radios{2}.isSelected)+1;
TXTcolrow{3-dim}.setEnabled(0);
TXTcolrow{dim}.setEnabled(1);

if ~isempty(varstruc) % Non-empty selection
    if varstruc.size(dim)>=2 % Matrix
        TXTcolrow{dim}.setText(['[1:' num2str(varstruc.size(3-dim)) ']']);
    elseif varstruc.size(dim)==1 % Vector
        TXTcolrow{dim}.setText('1');
    end
end