function tmtool
%TMTOOL open the Test & Measurement Tool.
%
%   TMTOOL opens the Test & Measurement Tool. The Test & Measurement 
%   Tool displays the available hardware used by each test & measurement
%   toolbox installed. Each toolbox provides additional tools for:
%       - configuring the hardware
%       - outputting data to the hardware
%       - reading data from the hardware
%
%   To view the tools associated with each toolbox, navigate through the 
%   nodes under each Toolbox tree node.
%

%   MP 08-06-02
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2004/01/16 20:03:17 $

% Determine if the window is hidden. If so, use it.
h = com.mathworks.toolbox.testmeas.browser.Browser.findInstance('Test & Measurement Tool');
if ~isempty(h)
    h.show;
    return;
end

% Find the tmgui.xml files.
files = which('tmgui.xml', '-all');

% For each XML file, read in the browser client.
clients = cell(1, length(files));
for i=1:length(files)
    clientName = getBrowserClient(xmlread(files{i}));
    if ~isempty(clientName)
        clients{i} = clientName;
    end
end

% Remove empty clients.
clients(cellfun('isempty', clients)) = [];

% Create and configure browser.
b = com.mathworks.toolbox.testmeas.browser.Browser('Test & Measurement Tool');
b.setBrowserLayout(com.mathworks.toolbox.testmeas.browser.Browser.COMPLETE_WITH_HELP);
b.setConfigurationFileName('tmtool.cfg');

% Add and configure clients.
btd = b.addClients(clients, 'Test & Measurement',...
    com.mathworks.toolbox.testmeas.browser.Browser.matlabImage,...
    com.mathworks.toolbox.testmeas.browser.BrowserTreeDetail.BOTH, [], false);
btd.okToHiliteTreeView(false);

% Show.
b.layoutBrowser;
b.addToFrame;

% ------------------------------------------------------------------
% Parse the tmgui.xml file and find the Browser gui client.
function out = getBrowserClient(info)

% Get the root node.
rootNode = info.getChildNodes.item(0).getChildNodes;

% Loop through the root nodes and find the client value for the Browser GUI.
for i=0:rootNode.getLength-1
    % Get the name of the node.
    name = rootNode.item(i).getNodeName;
    
    % If the node is a gui node, get it's children.
    if strcmp(name, 'gui')
        
        % GUI children nodes.
        guiNode = rootNode.item(i).getChildNodes;
        
        % Loop through the children and find the name node.
        for j=0:guiNode.getLength-1
            % Find the Name node.
            if strcmp(guiNode.item(j).getNodeName, 'name')
                % If the name node is Browser, then get the client value.
                if strcmp(guiNode.item(j).getChildNodes.item(0).getNodeValue, 'Browser')
                    % Get the client value and return.
                    out = char(guiNode.item(j+2).getChildNodes.item(0).getNodeValue);
                    return;
                end
            end
        end
    end
end