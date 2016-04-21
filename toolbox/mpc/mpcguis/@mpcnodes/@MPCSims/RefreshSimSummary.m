function RefreshSimSummary(this)

% Refresh the summary text in the MPCSims view

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.8.4 $ $Date: 2004/04/19 01:16:30 $

import com.mathworks.toolbox.mpc.*;
import javax.swing.*;

%disp('In RefreshSimSummary')

TextArea = this.Handles.TextArea;
Item = this.Handles.UDDtable.selectedRow;
[Rows,Cols] = size(this.Handles.UDDtable.CellData);
Sims = this.getChildren;
if Item < 1 || Item > length(Sims) ...
        || Item > Rows
    Text = '';
    Notes = '';
else
    SimNode = Sims(Item);
    Sim = SimNode.Label;
    this.CurrentScenario = Sim;
    Text = ListScenario(SimNode);
    try
        Notes = SimNode.Notes;
    catch
        Notes = '';
    end
end
%setJavaLogical(TextArea,'setVisible',0);
this.Handles.SummaryText.setText(Text);
this.Handles.NotesArea.setText(Notes);

% SwingUtilities.invokeLater(MLthread(this.Handles.SummaryText,'setText',{Text}));
% SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea,'setText',{Notes}));
SwingUtilities.invokeLater(MLthread(this.Handles.NotesArea, ...
    'setCaretPosition',{int32(0)},'int'));
%setJavaLogical(TextArea,'setVisible',1);

%disp('Exiting RefreshSimSummary')

% ------------------------------------------------------------------------

function Text = ListScenario(this)

% Update the scenario summary view.

% Author(s):   Larry Ricker
Text = '';
if isempty(this)
    return
else
    Text = '';
end
Text = htmlText(Text);
