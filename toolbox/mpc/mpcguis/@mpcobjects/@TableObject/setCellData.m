function setCellData(this, Data)

% Store data in table object's CellData property.
% Make sure elements are all legal java objects.

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc. 
%  $Revision: 1.1.6.3 $ $Date: 2003/12/04 01:35:48 $

[Rows,Cols] = size(Data);
for j = 1:Cols
    for i = 1:Rows
        if isempty(Data{i,j})
            if this.isString(j)
                Data{i,j} = java.lang.String('');
            else
                error(sprintf('Unexpected null in [%i,%i]',i,j));
            end
        end
    end
end
this.ListenerEnabled = true;
this.CellData = Data;