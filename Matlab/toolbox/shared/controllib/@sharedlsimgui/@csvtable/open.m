function open(h)
% OPEN Opens a @csvtable with a defined filename

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:34 $

import com.mathworks.toolbox.control.spreadsheet.*;
import com.mathworks.mwswing.*;
import javax.swing.*;

if ~isempty(h.filename) 
    try
        numData = csvread(h.filename);
    catch
        msg = ['Could not open file. Message returned from csvread: ', ...
            lasterr];
        errordlg(msg,'Ascii File Import','modal')
        return
    end
    h.colnames = [{' '} cellstr(char('A'+(1:size(numData,2))-1)')'];
    
    % limit the displayed size
%     if prod(size(thisData1))>64000 && 64000/size(thisData1,2)>=1
%         warndlg('The size of the ascii file exceeds the display capability of 64000 cells, truncating displayed columns to fit...',...
%             'Linear simulation tool', 'modal')
%         thisData1 = thisData1(1:floor(64000/size(thisData1,2)),:);
%     elseif 64000/size(thisData1,2)<1
%         errordlg('Files with more than 64000 columns cannot be used','Linear simulation tool', 'modal')
%         return
%     end

    
    % Only need to create a new STable if one didn't previously exist,
    % since
    h.numdata = numData;
    if isempty(h.STable)
        h.STable = STable(SheetTableModel(numData,h));
    else 
        thisTableModel = SheetTableModel(numData,h);
        rw = MLthread(h.STable,'setModel',{thisTableModel});
        SwingUtilities.invokeLater(rw);
    end
    
    % Enable context menus
    h.STable.getModel.setMenuStatus(1);
    
    % column only selections
    rw = MLthread(h.STable,'setCellSelectionEnabled',{boolean(0)},'boolean');
    SwingUtilities.invokeLater(rw);
    rw = MLthread(h.STable,'setColumnSelectionAllowed',{boolean(1)},'boolean');
    SwingUtilities.invokeLater(rw);
    
    % Make table & header visible
    drawnow
    h.STable.setVisible(1);
    h.STable.getTableHeader.setVisible(1);
    rw = MLthread(h.STable.getColumnModel.getColumn(0),'setMaxWidth',{int32(20)});
    SwingUtilities.invokeLater(rw);
    rw = MLthread(h.STable,'setAutoResizeMode',{int32(JTable.AUTO_RESIZE_OFF)},'int');
    SwingUtilities.invokeLater(rw);
    rw = MLthread(h.STable,'sizeColumnsToFit',{int32(JTable.AUTO_RESIZE_OFF)},'int');
    SwingUtilities.invokeLater(rw);
end





        
        