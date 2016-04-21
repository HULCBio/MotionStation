function panel = tablepanel(this, ColumnNames) 
% Create and configure the table and scroll panel.

%   Author(s): Craig Buhr, John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:20 $

import java.awt.*;
import javax.swing.*;
import com.mathworks.mwswing.*;
import com.mathworks.page.utils.VertFlowLayout;
import javax.swing.table.*;
import javax.swing.border.*;

% Create scroll panel with table
TableModel = com.mathworks.toolbox.control.dialogs.ImportDlgTableModel;

Table = MJTable(TableModel);
panel = MJScrollPane(Table);
set(Table,'PreferredScrollableViewportSize',Dimension(450, 100));
Table.getTableHeader.setReorderingAllowed(false); % Disable column reordering

% Store Java Handles
this.Handles.Table = Table;
this.Handles.TableModel = TableModel;
