% SETXU Set states and inputs in operating points
%
%   OP_NEW=SETXU(OP_POINT,X,U) sets the states and inputs in the operating
%   point, OP_POINT, with the values in X and U. A new operating point 
%   containing these values, OP_NEW, is returned. The variable X can be a 
%   vector or a structure with the same format as those returned from a 
%   Simulink simulation. The variable U can be a vector. Both X and U can 
%   be extracted from another operating point object with the GETXU function.
%
%   See also GETXU.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2004/03/24 21:08:33 $

%% Activate the valid comlumns
PlotTypes = this.PlotConfigurations(:,2);

%% Determine if the columns should be visible
wantVisible = ~strcmp(PlotTypes(rows,2),'None');
isVisible = this.VisibleTableColumns{rows,2};

for ct = 1:length(rows)
    if (wantVisible(ct) && ~isVisible(ct))
        %% Set the data in the column to be on.  There should be no
        %% need to fire a table changed event since the column is not
        %% visible but will be made visible.
        rowelements = 1:size(this.VisibleResultTableModelUDD.data,1);
        if length(rowelements) > 0
            this.VisibleResultTableModelUDD.data(rowelements,row+1) = java.lang.Boolean(true);
        end
        %% Update the data to be saved
        this.VisibleResultTableData = this.VisibleResultTableModelUDD.data;

        %% Add the column back to the table
        ColumnModel = this.VisibleResultTableUDD.getColumnModel;
        Column = this.VisibleTableColumns{row,1};

        %% Get the number of visible columns
        ncols = ColumnModel.getColumnCount;

        %% Add the column
        thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            ColumnModel, 'addColumn', {Column}, 'javax.swing.table.TableColumn');
        javax.swing.SwingUtilities.invokeLater(thr);

        %% Mark the column as visible
        this.VisibleTableColumns{row,2} = true;

        %% Get the number of visible columns that are to the left
        if row > 1
            nleftcols = sum([this.VisibleTableColumns{1:row-1,2}]);
        else
            nleftcols = 0;
        end

        %% Move it to the right index invoke method in AWT
        thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            ColumnModel, 'moveColumn', {int32(ncols);int32(nleftcols+1)},'int,int');
        javax.swing.SwingUtilities.invokeLater(thr);
    elseif (~wantVisible && isVisible)
        %% Remove the column
        ColumnModel = this.VisibleResultTableUDD.getColumnModel;
        Column = this.VisibleTableColumns{row,1};

        thr = com.mathworks.toolbox.control.spreadsheet.MLthread(...
            ColumnModel, 'removeColumn', {Column});
        javax.swing.SwingUtilities.invokeLater(thr);
        this.VisibleTableColumns{row,2} = false;
    end
end