function edit(h, varargin)

% EDIT Creates/links an importSelector with an importtable (h).
% If passed with an additional argument, the import selected will
% be a java dialog decended from that java owner. 

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:24:18 $

import javax.swing.*;
import java.awt.*;
import javax.swing.border.*;
import com.mathworks.mwt.*
import com.mathworks.mwswing.*;
import com.mathworks.ide.workspace.*;
import com.mathworks.toolbox.control.spreadsheet.*;

% Input/output table behavior
if strcmp(h.Type,'io') % build importSelector GUI if empty
    if isempty(h.getImportSelector)
        importSelector = sharedlsimgui.importselector;

        % assign the target table
        importSelector.importtable = h;

        % assign the target importSelector
        h.setImportSelector(importSelector);

        gridbag = GridBagLayout;
        constr = GridBagConstraints;

        % initial properties
        importSelector.filetype = 'wor';
        importSelector.importhandles.PNLdataSource = cell(1,5);

        % Build source selection combo panel    
        PNLsourceouter = JPanel(BorderLayout);
        PNLsource = JPanel;
        importSelector.importhandles.LBLimport = JLabel('Import from:');
        importSelector.importhandles.COMBOimport = JComboBox;
        importSelector.importhandles.COMBOimport.setName('import:combo:source');
        importSelector.importhandles.COMBOimport.addItem('Workspace');
        importSelector.importhandles.COMBOimport.addItem('MAT file');
        importSelector.importhandles.COMBOimport.addItem('XLS file');
        importSelector.importhandles.COMBOimport.addItem('CSV file');
        importSelector.importhandles.COMBOimport.addItem('ASCII file');
        PNLsource.add(importSelector.importhandles.LBLimport);
        PNLsource.add(importSelector.importhandles.COMBOimport);
        PNLsourceouter.add(PNLsource,BorderLayout.WEST);
        PNLsourceouter.setBorder(EmptyBorder(10,0,10,5));
        PNLsourceouter.add(Box.createHorizontalGlue,BorderLayout.CENTER);

        % Combo callback switches the import panel visivility
        set(importSelector.importhandles.COMBOimport,'ItemStateChangedCallback', ...
            {@localFileTypeSelect importSelector});

        % Build the available data panels and the listener which regulates
        % their visibility
        importSelector.importhandles.PNLdataSource = cell(1,5);  
        importSelector.addlisteners(handle.listener(importSelector, ...
            findprop(importSelector,'filetype'),'PropertyPostSet',...
            {@localSwitchPanelVisibility importSelector}));

        % Create main panel and frame so that local functions can add things
        importSelector.importhandles.mainPanel = JPanel(BorderLayout);
        importSelector.importhandles.mainPanel.setBorder(EmptyBorder(10,10,10,10));
        if nargin==1
            importSelector.importhandles.importDataFrame = MJFrame('Data Import');
        else
            importSelector.importhandles.importDataFrame = MJDialog(varargin{1},'Data Import');
        end
        % Exercise the visibility listener which will draw the workapace import
        % panel
        importSelector.filetype = 'wor';
        localSwitchPanelVisibility([],[],importSelector)
        importSelector.importhandles.PNLdataSource{1} = ...
            h.getImportSelector.importhandles.PNLdataSource{1};

        % Build close & help buttons    
        PNLbuttons = JPanel; 
        importSelector.importhandles.BTNimport = JButton('Import');
        importSelector.importhandles.BTNimport.setName('import:button:import');
        set(importSelector.importhandles.BTNimport,'ActionPerformedCallBack',{@localImportFromWorkspace importSelector});
        importSelector.importhandles.BTNclose = JButton('Close');
        importSelector.importhandles.BTNclose.setName('import:button:close');
        importSelector.importhandles.BTNhelp = JButton('Help');
        importSelector.importhandles.BTNhelp.setName('import:button:help');
        PNLbuttons.add(importSelector.importhandles.BTNimport);
        PNLbuttons.add(importSelector.importhandles.BTNclose);
        PNLbuttons.add(importSelector.importhandles.BTNhelp);
        PNLbuttons.setBorder(BorderFactory.createEmptyBorder(10,0,10,0));
        PNLbuttonsouter = JPanel(BorderLayout);
        PNLbuttonsouter.add(Box.createHorizontalGlue,BorderLayout.CENTER);
        PNLbuttonsouter.add(PNLbuttons,BorderLayout.EAST);

        % Build main panel & data import frame  
        importSelector.importhandles.mainPanel.add(PNLsourceouter,BorderLayout.NORTH);
        importSelector.importhandles.mainPanel.add(PNLbuttonsouter,BorderLayout.SOUTH);   
        importSelector.importhandles.importDataFrame.getContentPane.add(importSelector.importhandles.mainPanel);
        importSelector.importhandles.importDataFrame.setSize(414,500);
        importSelector.importhandles.importDataFrame.setLocation(50,50);
        importSelector.importhandles.importDataFrame.setVisible(0);
        importSelector.importhandles.importDataFrame.toFront;

        % Close the importselector if the siminput table is hidden    
        importSelector.addlisteners(handle.listener(importSelector.importtable,...
            findprop(importSelector.importtable,'visible'),'PropertyPostSet', ...
            {@localVisibilityToggle importSelector}));

        % Window close callback
        set(importSelector.importhandles.BTNclose,'ActionPerformedCallback',...
            {@localCloseImport importSelector.importhandles.importDataFrame});
        importSelector.importhandles.importDataFrame.pack;
    else % TO DO: edit should not be called if the importSelector does not 
         % to be rebuilt
        importSelector = h.getImportSelector;
    end 
% State table behavior
elseif strcmp(h.Type,'state')
    frame = varargin{1};
    
    % create an initialselector dialog
    h.setImportSelector(sharedlsimgui.initialselector);

    %workspace browser
    h.getImportSelector.workbrowser = sharedlsimgui.varbrowser;
    h.getImportSelector.workbrowser.typesallowed = {'double','single','uint8','uint16','unit32','int8',...
            'int16','int32'};
    if ~isempty(h.numstates)
        h.getImportSelector.workbrowser.open([h.numstates 1; 1 h.numstates]); %restrict vectors to right size
    else
        h.getImportSelector.workbrowser.open;
    end
    h.getImportSelector.workbrowser.javahandle.setName('initialworkimport:browser:workfiles');

    % buttons
    PNLbtns = JPanel(GridLayout(1,2,5,5));
    javahandles.BTNimport = JButton('Import');
    set(javahandles.BTNimport,'ActionPerformedCallBack',{@localImportState h});
    javahandles.BTNclose = JButton('Close');
    PNLbtns.add(javahandles.BTNimport);
    PNLbtns.add(javahandles.BTNclose);
    PNLbtnsouter = JPanel;
    PNLbtnsouter.add(PNLbtns);

    % Build data panel
    PNLdata = JPanel(BorderLayout);
    PNLbrowse = JPanel;
    PNLbrowse.add(h.getImportSelector.workbrowser.javahandle);
    PNLdata.add(PNLbrowse,BorderLayout.CENTER);
    PNLdata.add(PNLbtnsouter, BorderLayout.SOUTH);
    PNLdata.setBorder(BorderFactory.createEmptyBorder(10,10,10,10));

    % Build frame/dialog
    h.getImportSelector.frame = MJDialog(frame, ...
        'Import State From Workspace');
    

    % Close button callback      
    set(javahandles.BTNclose,'ActionPerformedCallBack', ...
        {@localCloseImport h.getImportSelector.frame});
    h.getImportSelector.frame.setSize(Dimension(340,207));
    h.getImportSelector.frame.getContentPane.add(PNLdata);
    
    % Listener to window activation so that variable browser updates to reflect
    % the current workspace
     javahandles.frame = h.getImportSelector.frame; % Needed for response to
                                                    % callback
     set(javahandles.frame, 'WindowActivatedCallback', ...
       {@localRefresh h})   
    h.getImportSelector.importhandles = javahandles;
end

%-------------------- Local Functions ---------------------------

function localVisibilityToggle(eventSrc, eventData, importSelector)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

importSelector.visible = importSelector.importtable.visible;
rw = MLthread(importSelector.importhandles.importDataFrame,'setVisible', ...
    {strcmp(importSelector.visible,'on')});
SwingUtilities.invokeLater(rw);

function localFileTypeSelect(eventSrc, eventData, importSelector)

importSelector.importhandles.importDataFrame.setCursor ...
    (java.awt.Cursor(java.awt.Cursor.WAIT_CURSOR));  

thisFileType = importSelector.importhandles.COMBOimport.getSelectedItem;
if ~isempty(thisFileType)
    importSelector.filetype = lower(thisFileType(1:3));
end

importSelector.importhandles.importDataFrame.setCursor ...
    (java.awt.Cursor(java.awt.Cursor.DEFAULT_CURSOR));  

function localSwitchPanelVisibility(eventSrc, eventData, importSelector)

import java.awt.*;

thisPanel = [];
switch lower(importSelector.filetype)
    case 'wor'
        if isempty(importSelector.workpanel)
            importSelector.workpanel = sharedlsimgui.workpanel(importSelector);
            % prevents vanishing of the import browser if it's resized too small
            importSelector.workpanel.Panel.setMinimumSize(Dimension(264,140));
        end
        thisPanel = importSelector.workpanel.Panel;
    case 'mat'
        if isempty(importSelector.matpanel)
            importSelector.matpanel = sharedlsimgui.matpanel(importSelector);
            % prevents vanishing of the import browser if it's resized too small
            importSelector.matpanel.Panel.setMinimumSize(Dimension(264,140));
        end
        thisPanel = importSelector.matpanel.Panel;
    case 'xls'
        if isempty(importSelector.excelpanel)
            importSelector.excelpanel = sharedlsimgui.excelpanel(importSelector);
        end
        thisPanel = importSelector.excelpanel.Panel;
    case 'csv'
        if isempty(importSelector.csvpanel)
            importSelector.csvpanel = sharedlsimgui.csvpanel(importSelector);
        end
        thisPanel = importSelector.csvpanel.Panel;
    case 'asc'
        if isempty(importSelector.ascpanel)
            importSelector.ascpanel = sharedlsimgui.ascpanel(importSelector);
        end
        thisPanel = importSelector.ascpanel.Panel;
end      
    
if ~isempty(thisPanel)
    importSelector.importhandles.mainPanel.add(thisPanel, BorderLayout.CENTER);
end

% Turn visible panel on first to reduce the flicker
thisPanel.setVisible(1);
thesePanels = {importSelector.workpanel,importSelector.excelpanel,...
                    importSelector.csvpanel,importSelector.matpanel,...
                    importSelector.ascpanel};
for k=1:5 
	if ~isempty(thesePanels{k}) && ~isempty(thesePanels{k}.Panel) && thesePanels{k}.Panel~=thisPanel
        thesePanels{k}.Panel.setVisible(0);
	end
end

importSelector.importhandles.importDataFrame.pack;

function localCloseImport(eventSrc, eventData, frame)

% close button callback
frame.setVisible(0);

function localImportFromWorkspace(eventSrc, eventData, importSelector)

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;

% Copies information from currently selected item in the 
% currently selected variable browser

% Find visible browser
switch lower(importSelector.filetype)
	case 'wor'
        importSelector.workpanel.import(importSelector.importtable);
	case 'mat'
        importSelector.matpanel.import(importSelector.importtable);
	case 'xls'
        importSelector.excelpanel.import(importSelector.importtable);
	case 'asc'
        importSelector.ascpanel.import(importSelector.importtable);
	case 'csv'
        importSelector.csvpanel.import(importSelector.importtable);
end
    
% fire rowselect event so that signal summary updates
%importSelector.importtable.javasend('userentry','');
importSelector.importtable.refresh;

function localImportState(es,ed, h)

currentRows = double(h.importSelector.workbrowser.javahandle.getSelectedRows);
if length(currentRows)>0
    selectedvar = h.importSelector.workbrowser.variables(currentRows(1)+1);
    if length(selectedvar.size)~=2 || min(selectedvar.size)>1
        msgbox('Variable must be a vector','State Import','modal')
    end
    
    % Load data and convert to col
    initvec = evalin('base', selectedvar.name);
    
    % Call overloaded pasteData method onto paste target table
    h.pasteData(cellstr(num2str(initvec(:))));
end    

function localRefresh(es,ed,h)

% State import window activation fcn
open(get(getImportSelector(h),'workbrowser'));
