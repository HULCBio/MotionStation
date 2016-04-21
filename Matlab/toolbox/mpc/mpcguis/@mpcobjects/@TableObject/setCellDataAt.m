function setCellDataAt(this, javaObj, row, col)

% Callback executes when a TableObject cell has been edited.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:37:30 $

[Rows,Cols] = size(this.CellData);

if (row > 0 & row <= Rows) & ...
        (col > 0 & col <= Cols)
    
    % However, if dataObj.class is Boolean, assume that
    % validation isn't needed.
    Message = 'Updating cell [%i,%i].\n';
    if isjava(javaObj)
        objClass = javaObj.class;
    else
        objClass = 'none';
    end
    if ~this.isString(col)
        try
            if isjava(javaObj)
                CellData = javaObj.booleanValue;
            else
                CellData = javaObj;
            end
            if isempty(this.DataCheckArgs)
                OK = feval(this.DataCheckFcn, CellData, row, col);
            else
                OK = feval(this.DataCheckFcn, CellData, row, col, ...
                                this.DataCheckArgs);
            end
        catch
            OK = 0;
            warning(sprintf([Message, ...
                        'Cell class is java.lang.Boolean, but ', ...
                        'object supplied is "%s".'],row,col,objClass))
        end
    else
        try
            CellData = char(javaObj);
            if isempty(this.DataCheckArgs)
                OK = feval(this.DataCheckFcn, CellData, row, col);
            else
                OK = feval(this.DataCheckFcn, CellData, row, col, ...
                                this.DataCheckArgs);
            end
        catch
            OK = 0;
            lasterr
            warning(sprintf([Message, ...
                        'Cell class is java.lang.String, but ', ...
                        'object supplied is "%s".'],row,col,objClass))
        end
    end
    if OK
        % Valid data, so store in UDD table object
        this.ListenerEnabled = false;
        this.CellData{row,col} = CellData;
    else
        % Invalid data, so reset java table data
        this.Table.getModel.setCellDataAt(this.CellData{row,col}, row-1, col-1);
    end
else
    % Outside table dimensions.
    warning(sprintf([Message,'Request is outside of table', ...
            ' dimensions, [%i,%i].'],row,col,Rows,Cols));
end
