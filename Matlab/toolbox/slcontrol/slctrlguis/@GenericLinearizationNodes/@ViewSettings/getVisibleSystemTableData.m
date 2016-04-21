function f = getVisibleSystemTableData(this);
%getVisibleSystemTableData  Method to update the visible systems in a view table

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.* java.awt.*;

if length(this.VisibleSystems) > 0
    f = javaArray('java.lang.Object',length(this.VisibleSystems),2);    
    for ct = 1:length(this.VisibleSystems)
        f(ct,1) = String(this.VisibleSystems(ct).Analysis.Label);
        f(ct,2) = java.lang.Boolean(this.VisibleSystems(ct).PlotAll);
        f(ct,3) = java.lang.Boolean(this.VisibleSystems(ct).Plot1);
        f(ct,4) = java.lang.Boolean(this.VisibleSystems(ct).Plot2);
        f(ct,5) = java.lang.Boolean(this.VisibleSystems(ct).Plot3);
        f(ct,6) = java.lang.Boolean(this.VisibleSystems(ct).Plot4);
        f(ct,7) = java.lang.Boolean(this.VisibleSystems(ct).Plot5);
        f(ct,8) = java.lang.Boolean(this.VisibleSystems(ct).Plot6);
    end
else
    f = javaArray('java.lang.Object',1,2);
    f(1,1) = String('No Active Results');
    f(1,2) = java.lang.Boolean(0);
    f(1,3) = java.lang.Boolean(0);
    f(1,4) = java.lang.Boolean(0);
    f(1,5) = java.lang.Boolean(0);
    f(1,6) = java.lang.Boolean(0);
    f(1,7) = java.lang.Boolean(0);
    f(1,8) = java.lang.Boolean(0);
end