function table_data = getOpConditionTableData(this);
%getOpConditionTableData  Method to get the current operating conditions

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.*; 
import java.awt.*;

Children = this.getChildren;

if ~isempty(Children)
    table_data = javaArray('java.lang.Object',length(Children),2);
    for ct = 1:length(Children)
        table_data(ct,1) = String(Children(ct).Label);
        if isa(Children(ct),'OperatingConditions.OperConditionResultPanel')
            table_data(ct,2) = String(Children(ct).OperatingConditionSummary);
        else
            table_data(ct,2) = String('Define the model operating points by hand');
        end
    end
else
    table_data = javaArray('java.lang.Object',1,2);
    table_data(1,1) = String('No operating points available');
    table_data(1,2) = String('');
end