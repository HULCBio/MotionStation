function RefreshControllerSummary(this)

% RefreshControllerSummary(this)
%
% Refreshes the summary text in the MPCModels view

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.9 $ $Date: 2004/04/19 01:16:26 $


import com.mathworks.toolbox.mpc.*;
import javax.swing.*;
TextArea = this.Handles.TextArea;
iController = this.Handles.UDDtable.selectedRow;
[Rows,Cols] = size(this.Handles.UDDtable.CellData); 
Controllers = this.getChildren;
if iController < 1 || iController > length(Controllers) ...
        || iController > Rows
    Text = '';
    Notes = '';
else
    ControllerNode = Controllers(iController);
    Controller = ControllerNode.Label;
    this.CurrentController = Controller;
    mpcExporter = this.getRoot.Handles.mpcExporter;
    mpcExporter.CurrentController = ControllerNode;
    Text = getControllerText(ControllerNode);
    try
        Notes = ControllerNode.Notes;
    catch
        Notes = '';
    end
end
%setJavaLogical(TextArea,'setVisible',0);
this.Handles.SummaryText.setText(Text);
this.Handles.NotesArea.setText(Notes);
%SwingUtilities.invokeLater(MLthread(this.Handles.SummaryText,'setText',{Text}));
SwingUtilities.invokeLater(MLthread(this.Handles.SummaryText, ...
    'setCaretPosition',{int32(0)},'int'));
SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea,'setText',{Notes}));
SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea, ...
    'setCaretPosition',{int32(0)},'int'));
%setJavaLogical(TextArea,'setVisible',1);

% =============================================== %

function Text = getControllerText(this)

% Text = getControllerText(this)
%
% Gets text for display of controller details

if isempty(this)
    % No controller node yet
    Text = '';
else
    % Controller node exists.  Avoid calculating a new MPC object.
    if this.HasUpdated || isempty(this.MPCobject)
        % An up-to-date MPC object doesn't exist yet, so return a simple
        % text message, avoiding creation of a new MPC object.
        Text = sprintf(['Click the "Display" button to see', ...
            ' controller details.\n\nNOTE:  controller object will be', ...
            ' recalculated.']);
    else
        % A "good" object exists, so display its properties in detail
        Text = evalc('display(this.MPCobject)');
    end
end
