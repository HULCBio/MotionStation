function addLinearizationDialog(h,M)

% Copyright 2003-2004 The MathWorks, Inc.

% Create linearization dialog for current Simulink model
% TO DO: Disable this if the parent node is not a Simulink 
% project node

import com.mathworks.toolbox.mpc.*;
import java.awt.*;

%% Cannot add without slcontrol
if ~license('test','Simulink_Control_Design')
    return
end
    
%% Create IOPanel object
h.Linearization = mpcnodes.MPCLinearizationSettings(h.up.Model);

%% Create a linearization import panel and add it to the LTI importer
h.Linearization.LinearizationDialog = MPCLinearizationPanel(h.Linearization.IOPanel);
javaimporter = getfield(h.Handles,'ImportLTI');
javasend(javaimporter,'Hide','OK',javaimporter)
javaimporter.javahandle.addLinearizationPanel(h.Linearization.LinearizationDialog);

%% Reduce the IOTable preferred size so that the imorter looks right
h.Linearization.IOPanel.setPreferredSize(Dimension(400,200));
javaimporter.javahandle.pack;

%% If an operating condition task exists, excerise the listener to its
%% children to update the linearization dialog combo. Needed for load.
opcondtask = h.up.find('-class','OperatingConditions.OperatingConditionTask');
if ~isempty(opcondtask)
    h.opCondAdded(opcondtask);
end

% Callbacks
set(handle(javaimporter.javahandle.jOKButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localLinearize javaimporter M});
set(handle(javaimporter.javahandle.jCancelButton,'callbackproperties'),'ActionPerformedCallback',...
    {@localClose javaimporter.javahandle});



function localLinearize(es,ed,javaimporter,M)

% Find the right MPCGUI node and get the corresponding opcondtask
Isel = javaimporter.javahandle.jProjectCombo.getSelectedIndex + 1;
mpcnode = javaimporter.Tasks(Isel);
jframe = javaimporter.javahandle;
opcondtask = mpcnode.up.find('-class','OperatingConditions.OperatingConditionTask');

%% Only linearize if the linearization tab is active
if ~isempty(jframe.mainTabPane) && jframe.mainTabPane.getSelectedIndex==1
    newNodeName = '';
    if ~mpcnode.linearization.LinearizationDialog.nominalRadio.isSelected
        % Contraint node selected from drop down list
        opcondnodestr = char(...
            mpcnode.linearization.LinearizationDialog.existingOpsCombo.getSelectedItem);
        opconnodes = opcondtask.getChildren;
        I = find(strcmp(opcondnodestr,get(opconnodes,{'Label'})));
        newNodeName = mpcnode.linearize(opcondtask,M,opconnodes(I(1)));
    else % Use the mpc i/o table
        newNodeName = mpcnode.linearize(opcondtask,M,[]);
    end
    
%% Overwrite new nominals back to the table. Must be done after the new
%% linearized model has been added to guarentee that the MPC i/o table is
%% syncronized with the linearization i/o and only if the linearization 
%% was sucessful
    if ~isempty(newNodeName) && ...
            mpcnode.linearization.LinearizationDialog.overwriteNominalChk.isSelected
       mpcnode.setNominal(mpcnode.Linearization.OPReport)
    end
end


%% Callbacks --------------------------------------------------------------

function localClose(es,ed,h)

%% Cancel button callback
awtinvoke(h,'hide');

    
