function open(h)
% OPEN Opens @exceltable with known file and sheet names 

% Author(s): J. G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:41 $

import com.mathworks.toolbox.control.spreadsheet.*;
import javax.swing.*;
import java.awt.*;
import com.mathworks.mwswing.*;

if ~isempty(h.filename) & ~isempty(h.sheetname)
  
    % thisFrame.setCursor(Cursor(Cursor.WAIT_CURSOR));

    try
        [numData_, txtData, rawdata] = xlsread(h.filename,h.sheetname);
        
        if ~isempty(rawdata)
            numData = NaN*ones(size(rawdata));
            I = cellfun('isclass',rawdata,'double');
            numData(I) = [rawdata{I}];
        else % Without ActiveX support xlsread returns empty
            warndlg('There is no ActiveX client support for Excel on this machine. Loading numeric data only',...
               'Excel File Import');
            numData = numData_;
            txtData = {''};
        end
                
        % limit header size to 20x50 to prevent excessive loading times
        if size(txtData,1)>20 
            txtData = txtData(1:20,:);
        end
        if size(txtData,2)>50 
            txtData = txtData(:,1:50);
        end    
    catch
        errordlg('Requested Excel file or sheet name not found', ...
            'Excel File Import', 'modal')
        %% thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
        return
    end
    
    % non-numeric text
    h.setCells(txtData);
    
    % letter column headings
    h.colnames = [{' '} cellstr(char('A'+(1:size(numData,2))-1)')'];
   
    % limit the displayed size due to MatlabVariableData constraint
%     if prod(size(numData))>64000 && 64000>=size(numData,2)
%         warndlg('The size of the spreadsheet exceeds the display capability of 64000 cells, truncating displayed columns to fit...',...
%             'Linear simulation tool', 'modal')
%         numData = thisData1(1:floor(64000/size(numData,2)),:);
%     elseif 64000<size(numData,2)
%         errordlg('Spreadsheets with more than 64000 columns cannot be used','Linear simulation tool', 'modal')
%         %thisFrame.setCursor(Cursor(Cursor.DEFAULT_CURSOR));
%         return
%     end
    
    % Only need to create a new STable if one didn't previously exist, since
    % listeners should do all the work otherwise
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
    h.STable.setVisible(1);
    h.STable.getTableHeader.setVisible(1);
    rw = MLthread(h.STable.getColumnModel.getColumn(0),'setMaxWidth',{int32(20)});
    SwingUtilities.invokeLater(rw);
    rw = MLthread(h.STable,'setAutoResizeMode',{int32(JTable.AUTO_RESIZE_OFF)},'int');
    SwingUtilities.invokeLater(rw);
    rw = MLthread(h.STable,'sizeColumnsToFit',{int32(JTable.AUTO_RESIZE_OFF)},'int');
    SwingUtilities.invokeLater(rw);

end

