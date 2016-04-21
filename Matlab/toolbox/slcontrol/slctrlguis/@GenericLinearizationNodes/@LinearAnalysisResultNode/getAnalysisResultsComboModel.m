function combo_data = getAnalysisResultsComboModel(this);
%getAnalysisResultsComboModel Get the combobox model for the linearization
% gui to toggle between analysis results.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

%% Get the notes from each model
notes = this.LinearizedModel.Notes;

%% Create a proper notes cell array.  The notes return is a cell array of
%% cell arrays.
notes_cell = cell(length(notes),1);
for ct = 1:length(notes)
    if iscell(notes{ct})
        notes_cell{ct} = notes{ct}{:};
    else
        notes_cell{ct} = notes{ct};
    end
end

%% Create the combo box model
combo_data = javax.swing.DefaultComboBoxModel(notes_cell);