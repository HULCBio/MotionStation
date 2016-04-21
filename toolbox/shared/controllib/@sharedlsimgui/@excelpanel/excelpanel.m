function h = excelpanel(importSelector)
% CREATEEXCELPANEL builds the Excel file import panel. Returns handles to
% components
% with callbacks, since there need to remain in scope

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:36 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

h = sharedlsimgui.excelpanel;

% Build North worksheet selection panel
LBLfile = JLabel('File: ');
h.Jhandles.TXTfile = JTextField(12);
h.Jhandles.TXTfile.setName('excelimport:textfield:filename');
h.Jhandles.BTNfile = JButton('Browse...');
h.Jhandles.BTNfile.setName('excelimport:button:browse');
LBLsheet = JLabel('       Select sheet: ');
COMBOsheet = JComboBox;
COMBOsheet.setName('excelimport:combo:sheetname');
COMBOsheet.setPreferredSize(h.Jhandles.TXTfile.getPreferredSize);
outerworksheetselectPnl = JPanel(BorderLayout(5,5));
worksheetselectPnl = JPanel(FlowLayout.LEFT);
worksheetselectPnl.add(LBLfile);
worksheetselectPnl.add(h.Jhandles.TXTfile);
worksheetselectPnl.add(h.Jhandles.BTNfile);
worksheetselectPnl.add(LBLsheet);
worksheetselectPnl.add(COMBOsheet);
outerworksheetselectPnl.setBorder(EmptyBorder(0,0,10,0));
outerworksheetselectPnl.add(worksheetselectPnl,BorderLayout.WEST);
outerworksheetselectPnl.add(Box.createHorizontalGlue,BorderLayout.CENTER);

% Create center Excel table panel
h.Jhandles.PNLxls = JPanel(GridLayout(1,1));
h.Jhandles.PNLxls.setPreferredSize(Dimension(650,400));
h.excelsheet = sharedlsimgui.exceltable;
h.excelsheet.initialize;
h.excelsheet.STable.setName('excelimport:table:excelsheet');
h.excelsheet.addlisteners(handle.listener(h.excelsheet, ...
    'rightmenuselect',{@localExcelRightSelect importSelector}));
h.Jhandles.scroll1 = JScrollPane(h.excelsheet.STable);
h.Jhandles.PNLxls.add(h.Jhandles.scroll1);

% Build selection options panel 
LBLSkipped = JLabel(sprintf('%s','Ignore header rows prior to row: '));
h.filterHandles.TXTrowEnd = JTextField(5);
h.filterHandles.TXTrowEnd.setName('excelimport:textfield:header');
h.filterHandles.TXTrowEnd.setText('1');
set(h.filterHandles.TXTrowEnd,'Tag','1','ActionPerformedCallback',...
     {@localChkNum h.filterHandles.TXTrowEnd},'FocusLostCallback',{@localChkNum h.filterHandles.TXTrowEnd});
LBLbadData = JLabel(sprintf('%s','Bad data substitution method:'));
h.FilterHandles.COMBOinterp = JComboBox;
interpmethods = {'Skip rows','Skip cells','Linearly interpolate','Zero order hold'};
for k=1:length(interpmethods)
    h.FilterHandles.COMBOinterp.addItem(interpmethods{k});
end
h.FilterHandles.COMBOinterp.setName('excelimport:combo:baddata');
optionsPnl = JPanel(BorderLayout);
optionsPnl.setBorder(BorderFactory.createTitledBorder('Text and Missing Data'));

optionsgridPnl = JPanel(GridLayout(2,2,0,10));
optionsgridPnl.add(LBLSkipped);
optionsgridPnl.add(h.filterHandles.TXTrowEnd);
optionsgridPnl.add(LBLbadData);
optionsgridPnl.add(h.FilterHandles.COMBOinterp);
optionsgridPnl.setBorder(EmptyBorder(5,5,5,0));
optionsPnl.add(optionsgridPnl,BorderLayout.WEST);
optionsPnl.add(Box.createHorizontalGlue,BorderLayout.CENTER);


% callbacks
set(h.Jhandles.BTNfile, 'ActionPerformedCallback',{@openFile, importSelector,  COMBOsheet, ...
        h.Jhandles.TXTfile, h.filterHandles.TXTrowEnd, h});
set(h.Jhandles.TXTfile,'ActionPerformedCallback', {@localUpdateFile, h.Jhandles.TXTfile,...
        COMBOsheet importSelector, h.filterHandles.TXTrowEnd});
set(COMBOsheet,'ItemStateChangedCallback',{@localSheetSelect COMBOsheet importSelector h.filterHandles.TXTrowEnd});  

% Build final panel
PNLdata = JPanel(BorderLayout);
PNLdata.add(outerworksheetselectPnl, BorderLayout.NORTH);
PNLdata.add(h.Jhandles.PNLxls, BorderLayout.CENTER);
PNLdata.add(optionsPnl, BorderLayout.SOUTH);

h.Panel = PNLdata;

%-------------------- Local Functions ---------------------------


function localSheetSelect(eventSrc, eventData, COMBOsheet, ImportSelector, HeadEnd)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

% turn on hourglass cursor since the spread sheet load may take a while
thisFrame = ImportSelector.importhandles.importDataFrame;
if ~isempty(thisFrame)
    thisFrame.setCursor(Cursor(Cursor.WAIT_CURSOR));
end
    
ImportSelector.excelpanel.excelsheet.sheetname = char(COMBOsheet.getSelectedItem);

% set header length
HeadEnd.setText(num2str(min(find(all(isnan(ImportSelector.excelpanel.excelsheet.numdata)')'==false))));

% reset cursor
if ~isempty(thisFrame)
    thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
end
    
function openFile(eventSrc, eventData, ImportSelector, COMBOsheet, TXTfile, HeaderBox, h)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded with the "Browse" button

[fname pname] = uigetfile([h.Folder '*.xls'],'Select .xls file');

% Check for cancel
if ~ischar(fname)
    return
end
filename = [pname fname];
h.Folder = pname;
% open file and write default header lenth
HeaderBox.setText(num2str(localProcessFile(filename,ImportSelector, COMBOsheet, TXTfile)));

function localExcelRightSelect(eventSrc, eventData, importSelector)

importSelector.excelpanel.import(importSelector.importtable,'copy');

function localUpdateFile(eventSrc, eventData, TXTfile,COMBOsheet, ImportSelector, HeadBox)

file = char(TXTfile.getText);
[pathname filename ext] = fileparts(file); 
if isempty(pathname) 
   if isunix
      file = [pwd '/' file];
   else
      file = [pwd '\' file];
   end
end
if isempty(ext)
   file = [file '.xls'];
end

% Callback for the file text box
HeadBox.setText(num2str(localProcessFile(file,ImportSelector, COMBOsheet, TXTfile)));

function numericStart = localProcessFile(filename,ImportSelector, COMBOsheet, TXTfile)

% updates the GUI state, sheetnames combo & file name text box when a new
% file is loaded and returns the default header length

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

fileerr = false;
try
    [status, sheetnames] = xlsfinfo(filename); 
catch
    fileerr = true;
end
if fileerr || length(dir(filename))==0 % should have the full path here
    errordlg('File not found','Excel File Import','modal')
    numericStart = 0;
    return
end    
    
if ~isempty(status) && length(sheetnames)>0% Don't update anything unless xlsread returns valid status
    
    % turn on hourglass cursor since the spread sheet load may take a while
    thisFrame = ImportSelector.importhandles.importDataFrame;
	if ~isempty(thisFrame)
        thisFrame.setCursor(Cursor(Cursor.WAIT_CURSOR));
	end

    TXTfile.setText(filename);
    
    % update sheet combo box
    COMBOsheet.removeAllItems;
    for k=1:length(sheetnames)
        COMBOsheet.addItem(sheetnames{k});
    end
    
    % listeners will open the spreadsheet
    ImportSelector.excelpanel.excelsheet.filename = filename;
    ImportSelector.excelpanel.excelsheet.sheetname = sheetnames{1};
    
    % find the start row for the numeric data
    numericStart = min(find(all(isnan(ImportSelector.excelpanel.excelsheet.numdata)')'==false));

    % reset cursor
	if ~isempty(thisFrame)
        thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
	end
else
    TXTfile.setText('');
    numericStart = 0;
    errordlg('Invalid or empty workbook','Excel File Import','modal')
end


function localChkNum(eventSrc, eventData, textbox)

boxcontents = char(textbox.getText);
try 
    eval([boxcontents ';']);
catch
    errordlg([boxcontents ' is an invalid text box entry'],'Excel File Import','modal')
    textbox.setText(get(textbox,'Tag'));
end