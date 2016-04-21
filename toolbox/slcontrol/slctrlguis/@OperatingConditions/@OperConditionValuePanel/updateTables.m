function updateTables(this)

% Copyright 2004 The MathWorks, Inc.

%%%%%% STATE TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create the cell attributes
cellAtt = CreateCellAttrib(this.StateIndecies, size(this.StateTableData,1), 2);
this.StateCondTableModelUDD.cellAtt = cellAtt;
this.StateCondTableModelUDD.data = this.StateTableData;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.StateCondTableModelUDD);
this.StateCondTableModelUDD.fireTableChanged(evt);

%%%%%% INPUT TABLE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Create the cell attributes
cellAtt = CreateCellAttrib(this.InputIndecies, size(this.InputTableData,1), 2);
this.InputCondTableModelUDD.cellAtt = cellAtt;
this.InputCondTableModelUDD.data = this.InputTableData;

%% Create a table model event to update the table
evt = javax.swing.event.TableModelEvent(this.InputCondTableModelUDD);
this.InputCondTableModelUDD.fireTableChanged(evt);

%%----------------------------------------------------------------------
%% CreateCellAttrib(indecies, nrows, ncols) - Creates cell attributes for 
%% the results tables
function cellAtt = CreateCellAttrib(indecies, nrows, ncols)

import com.mathworks.toolbox.slcontrol.AdvTableObjects.*;

%% Create the new color and font objects for the cell attributes;
color = java.awt.Color(int16(255),int16(238),int16(204));
font = java.awt.Font('',1,12);

%% Create the cell attributes
col_combine = 0:ncols-1;
cellAtt = DefaultCellAttribute(nrows,ncols);
%% Combine rows and columns
for ct = 1:size(indecies,1);
    row_combine = indecies(ct,1).intValue;
    cellAtt.combine(row_combine,col_combine);
    cellAtt.setBackground(color,row_combine,col_combine);
    cellAtt.setFont(font,row_combine,col_combine);
end
