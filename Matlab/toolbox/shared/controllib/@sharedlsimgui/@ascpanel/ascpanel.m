function h = ascpanel(ImportSelector)
%ASCPANEL @ascpanel constructor
%
% Builds the ascii file import panel.Returns handles to
% components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:24 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.ascpanel;

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
% |PNLasc     |         |       |
% |___________|         |       |
% ______________________        |
%                               |       
% ______________________________


% Set up "Data Source" panel: PNLdata
gridbagDataSource = GridBagLayout;
gridbagData = GridBagLayout;
constr = GridBagConstraints;

% create file import panel: PNLfile
PNLfileinner1 = JPanel(FlowLayout(FlowLayout.LEFT,5,5));
LBLfile = JLabel('File: ');
h.Jhandles.TXTfile = JTextField(12);
h.Jhandles.TXTfile.setName('asciiimport:textfield:filename');
h.Jhandles.BTNfile = JButton('Browse...');
h.Jhandles.BTNfile.setName('asciiimport:button:browse');
LBLdelimeter = JLabel('Select delimeter character: ');
h.FilterHandles.COMBOdelimeter = JComboBox;
h.FilterHandles.COMBOdelimeter.setName('asciiimport:combo:delim');
h.FilterHandles.COMBOdelimeter.addItem('space');
h.FilterHandles.COMBOdelimeter.addItem(',');
h.FilterHandles.COMBOdelimeter.addItem(':');
h.FilterHandles.COMBOdelimeter.addItem('tab');
PNLfileinner1.add(LBLfile);
PNLfileinner1.add(h.Jhandles.TXTfile);
PNLfileinner1.add(h.Jhandles.BTNfile);
PNLfileinner2 = JPanel;
PNLfileinner2.add(LBLdelimeter);
PNLfileinner2.add(h.FilterHandles.COMBOdelimeter);
PNLfileinner = JPanel(BorderLayout);
PNLfileinner.add(PNLfileinner1,BorderLayout.WEST);
PNLfileinner.add(Box.createHorizontalGlue,BorderLayout.CENTER);
PNLfileinner.add(PNLfileinner2,BorderLayout.EAST);
PNLfile = JPanel(BorderLayout);
PNLfile.add(PNLfileinner, BorderLayout.CENTER);
set(h.FilterHandles.COMBOdelimeter,'ItemStateChangedCallback',{@localRender h.FilterHandles.COMBOdelimeter ImportSelector});
localBagConstraints(constr);
constr.anchor = GridBagConstraints.NORTH;
constr.weightx  = 1;
gridbagDataSource.setConstraints(PNLfile,constr);

% Create ascii panel
h.Jhandles.PNLasc = JPanel(BorderLayout);
h.Jhandles.PNLasc.setPreferredSize(Dimension(650,400));

% Create empty @exceltable
h.ascsheet = sharedlsimgui.asctable;
h.ascsheet.initialize;
h.ascsheet.STable.setName('asciiimport:table:ascsheet');
h.ascsheet.addlisteners(handle.listener(h.ascsheet, ...
    'rightmenuselect',{@localASCRightSelect ImportSelector}));
scroll1 = JScrollPane(h.ascsheet.STable);
h.Jhandles.PNLasc.add(scroll1,BorderLayout.CENTER);

% set file open callbacks
set(h.Jhandles.BTNfile, 'ActionPerformedCallback',{@openFile, h.ascsheet, h.FilterHandles.COMBOdelimeter, h.Jhandles.TXTfile, h});
set(h.Jhandles.TXTfile, 'ActionPerformedCallback',{@localProcessFile h.ascsheet  h.FilterHandles.COMBOdelimeter  h.Jhandles.TXTfile});

localBagConstraints(constr);
constr.gridy = 1;
constr.gridwidth = GridBagConstraints.REMAINDER;
constr.weightx = 1;
constr.weighty = 1;
gridbagDataSource.setConstraints(h.Jhandles.PNLasc,constr);

% Build source panel container
PNLsource = JPanel(gridbagDataSource);
PNLsource.add(PNLfile);
PNLsource.add(h.Jhandles.PNLasc);
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

function localRender(eventSrc, eventData, COMBOdelimeter, ImportSelector)

% (Re)renders asctable when delimeter is changed
delimeter = localParseDelimeter(COMBOdelimeter);
ImportSelector.ascpanel.ascsheet.delimeter = delimeter;


function openFile(eventSrc, eventData, ascsheet, COMBOdelimeter, TXTfile,h)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded


[fname pname] = uigetfile([h.Folder '*.txt;*.tab;*.dlm'],'Select file');

% Check for cancel
if ~ischar(fname)
    return
end
h.Folder = pname;
TXTfile.setText([pname fname]);
if strcmp(class(fname),'char')
    localProcessFile([],[],ascsheet, COMBOdelimeter, TXTfile)
end

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


function localASCRightSelect(eventSrc, eventData, importSelector)

importSelector.ascpanel.import(importSelector.importtable,'copy');

function delimeter = localParseDelimeter(COMBOdelimeter)

% (Re)renders asctable when delimeter is changed
delimeter = char(COMBOdelimeter.getSelectedItem);
if length(delimeter)>1
    switch delimeter
    case 'space'
        delimeter = ' ';
    case 'tab'
        delimeter = '\t';
    otherwise
        error('delimeters must be a single character');
    end
end


function localProcessFile(eventSrc, eventData, ascsheet, COMBOdelimeter, TXTfile)

try
    ascsheet.filename = char(TXTfile.getText);
    ascsheet.delimeter = localParseDelimeter(COMBOdelimeter);
catch
    errordlg(lasterr,'Ascii File Import','modal')
end

