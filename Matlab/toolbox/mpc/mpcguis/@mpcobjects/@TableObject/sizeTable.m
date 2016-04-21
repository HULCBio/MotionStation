function sizeTable(this, ViewportSize, ColumnSizes, AutoResizeMode)

%    sizeTable(this,ViewPortSize,ColumnSizes,AutoResizeMode)
%
% Size an MPCTable (mpcobjects.TableObject) table

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:33 $

import java.awt.*;
import javax.swing.*;

[nRows,nCols] = size(this.CellData);
Table=this.Table;
if ~isnumeric(ViewportSize) || length(ViewportSize(:)) ~= 2
    error(sprintf(['ViewportSize must be vector, length 2,\n   but', ...
            ' size(ViewportSize) = [%i,%i].'],size(ViewportSize)))
elseif ~isnumeric(ColumnSizes) || length(ColumnSizes(:)) ~= nCols
    error(sprintf(['Expected ColumnSizes to be vector, length %i,\n', ...
            '   but size(ColumnSizes) = [%i,%i].'],nCols,size(ColumnSizes)))
elseif ~ischar(AutoResizeMode)
    error('ResizePolicy must be a string')
end
Model = Table.getColumnModel;
for i=1:nCols
    Column = Model.getColumn(i-1);
    Column.setMinWidth(ColumnSizes(i));
    Column.setPreferredWidth(ColumnSizes(i));
end

Table.setPreferredScrollableViewportSize(Dimension(ViewportSize(1), ...
    ViewportSize(2)));

if strcmpi(AutoResizeMode,'off')
    Policy = JTable.AUTO_RESIZE_OFF;
elseif strcmpi(AutoResizeMode,'next_column')
    Policy = JTable.AUTO_RESIZE_NEXT_COLUMN;
elseif strcmpi(AutoResizeMode,'last_column')
    Policy = JTable.AUTO_RESIZE_LAST_COLUMN;
elseif strcmpi(AutoResizeMode,'all_columns')
    Policy = JTable.AUTO_RESIZE_ALL_COLUMNS;
else
    Policy = JTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS;
end
Table.setAutoResizeMode(Policy);
        