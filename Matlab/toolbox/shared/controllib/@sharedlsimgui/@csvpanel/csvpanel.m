function h = csvpanel(ImportSelector)
% CVVPANEL @csvpanel constructor
%
% Builds the csv file import panel. Returns handles to components
% CREATEASCPANEL builds the csv file import panel. Returns handles to components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:30 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.csvpanel;

% Panel organization

%_______________________________
% PNLdata                       |
%                               |
% ______________________        |
% PNLsource             |       |
% ___________           |       |
% |PNLfile    |         |       |
% |___________|         |       |
%                       |       |
% ____________          |       |
% |PNLcsv     |         |       |
% |___________|         |       |
% ______________________        |
%                               |          
% ______________________________


% Set up "Data Source" panel: PNLdata
gridbagDataSource = GridBagLayout;
gridbagData = GridBagLayout;
constr = GridBagConstraints;

% create file import panel: PNLfile
%PNLfile1 = JPanel(FlowLayout(FlowLayout.LEFT));
PNLfile = JPanel(FlowLayout(FlowLayout.LEFT));
LBLfile = JLabel('File: ');
h.FilterHandles.PNLcsv = JTextField(12);
h.FilterHandles.PNLcsv.setName('csvimport:textfield:filename');
h.Jhandles.BTNfile = JButton('Browse...');
h.Jhandles.BTNfile.setName('csvimport:button:browse');
PNLfile.add(LBLfile);
PNLfile.add(h.FilterHandles.PNLcsv);
PNLfile.add(h.Jhandles.BTNfile);
localBagConstraints(constr);
constr.weightx  = 0;
constr.weighty = 0;
constr.fill = GridBagConstraints.BOTH;
gridbagDataSource.setConstraints(PNLfile,constr);

% Create csv panel
h.Jhandles.PNLcsv = JPanel(BorderLayout);
h.Jhandles.PNLcsv.setPreferredSize(Dimension(650,400));

% Create empty @csvtable
h.csvsheet = sharedlsimgui.csvtable;
h.csvsheet.initialize;
h.csvsheet.STable.setName('csvimport:table:csvsheet');
h.csvsheet.addlisteners(handle.listener(h.csvsheet, ...
    'rightmenuselect',{@localCSVRightSelect ImportSelector}));
scroll1 = JScrollPane(h.csvsheet.STable);
h.Jhandles.PNLcsv.add(scroll1,BorderLayout.CENTER);
set(h.Jhandles.BTNfile, 'ActionPerformedCallback',{@openFile, ImportSelector, h.Jhandles.PNLcsv, h.FilterHandles.PNLcsv, h});
set(h.FilterHandles.PNLcsv,'ActionPerformedCallback', {@openThisFile, ImportSelector, h.FilterHandles.PNLcsv});
localBagConstraints(constr);
constr.gridy = 1;
constr.gridwidth = GridBagConstraints.REMAINDER;
constr.weightx = 1;
constr.weighty = 1;
gridbagDataSource.setConstraints(h.Jhandles.PNLcsv,constr);

% Build source panel container
PNLsource = JPanel(gridbagDataSource);
PNLsource.add(PNLfile);
PNLsource.add(h.Jhandles.PNLcsv);
localBagConstraints(constr);
constr.weightx = 1;
constr.weighty = 1;
gridbagData.setConstraints(PNLsource,constr);
%PNLsource.setBorder(BorderFactory.createTitledBorder('Data source:'));

% Buil final panel
PNLdata = JPanel(gridbagData);
PNLdata.add(PNLsource);

h.Panel = PNLdata;


%-------------------- Local Functions ---------------------------

function localSheetSelect(eventSrc, eventData, COMBOsheet, ImportSelector)

ImportSelector.csvpanel.csvsheet.sheetname = char(COMBOsheet.getSelectedItem);

function openFile(eventSrc, eventData, ImportSelector, PNLcsv,  TXTfile, h)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded

[fname pname] = uigetfile([h.Folder '*.csv'],'Select .csv file');

% Check for cancel
if isempty(fname) | ~ischar(fname)
    return
end

filename = [pname fname];
h.Folder = pname;
TXTfile.setText(filename);
ImportSelector.csvpanel.csvsheet.filename = filename;

function localBagConstraints(constr)

% Resets the bag layout constraints 

import java.awt.*;
constr.anchor = GridBagConstraints.NORTHWEST;
constr.fill = GridBagConstraints.BOTH;
constr.weightx = 0;
constr.weighty = 0;
constr.gridwidth = 1;
constr.gridheight = 1;
constr.gridx = 0;
constr.gridy = 0;

function localCSVRightSelect(eventSrc, eventData, importSelector)

importSelector.csvpanel.import(importSelector.importtable,'copy');

function openThisFile(eventSrc, eventData, ImportSelector, TXTfile)

ImportSelector.csvpanel.csvsheet.filename = char(TXTfile.getText);