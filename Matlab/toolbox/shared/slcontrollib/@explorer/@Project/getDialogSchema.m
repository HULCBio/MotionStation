function DialogPanel = getDialogSchema(this, manager)
% GETDIALOGSCHEMA  Construct the dialog panel

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:16 $

import java.lang.*;

% First create the GUI panel
DialogPanel = com.mathworks.toolbox.control.project.ProjectPanel;

% Get the handles to the important java components and set their action
% performed callbacks.  Also set their initial data.
DateModifiedFieldUDD = DialogPanel.getDateModifiedField;
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      DateModifiedFieldUDD, 'setText', {this.DateModified}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

SubjectTextFieldUDD = DialogPanel.getSubjectTextField;
h = handle( SubjectTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @SubjectTextFieldUpdate, this };
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      SubjectTextFieldUDD, 'setText', {this.Subject}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

CreatedByTextFieldUDD = DialogPanel.getCreatedByTextField;
h = handle( CreatedByTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @CreatedByTextFieldUpdate, this };
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      CreatedByTextFieldUDD, 'setText', {this.CreatedBy}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

TitleTextFieldUDD = DialogPanel.getTitleTextField;
h = handle( TitleTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @TitleTextFieldUpdate, this };
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      TitleTextFieldUDD, 'setText', {this.Label}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

SimulinkModelTextFieldUDD = DialogPanel.getSimulinkModelTextField;
h = handle( SimulinkModelTextFieldUDD, 'callbackproperties' );
h.ActionPerformedCallback = { @SimulinkModelTextFieldUpdate, this };
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      SimulinkModelTextFieldUDD, 'setText', {this.Model}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

NotesTextAreaUDD = DialogPanel.getNotesTextArea;
h = handle( NotesTextAreaUDD, 'callbackproperties' );
h.FocusLostCallback = { @NotesTextAreaUpdate, this };
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      NotesTextAreaUDD, 'setText', {this.Notes}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

L = [ handle.listener( this, findprop(this, 'Label'), ...
                       'PropertyPostSet', {@LocalUpdateTitle, this} ) ];
this.NodePropertyListeners = L;

%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Local Functions
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function LocalUpdateTitle(es,ed,this)
TitleTextFieldUDD = this.Dialog.getTitleTextField;
thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      TitleTextFieldUDD, 'setText', {this.Label}, 'java.lang.String');
javax.swing.SwingUtilities.invokeLater(thr);

function SubjectTextFieldUpdate(es,ed,this)
this.Subject = char(ed.getSource.getText);

function CreatedByTextFieldUpdate(es,ed,this)
this.CreatedBy = char(ed.getSource.getText);

function TitleTextFieldUpdate(es,ed,this)
this.Label = char(ed.getSource.getText);

% Update the title field in case Label change hasn't been accepted.
if ~strcmp(ed.getSource.getText, this.Label)
  thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
      ed.getSource, 'setText',{this.Label},'java.lang.String');
  javax.swing.SwingUtilities.invokeLater(thr);
end

function SimulinkModelTextFieldUpdate(es,ed,this)
this.Model = char(ed.getSource.getText);

function NotesTextAreaUpdate(es,ed,this)
this.Notes = char(ed.getSource.getText);
