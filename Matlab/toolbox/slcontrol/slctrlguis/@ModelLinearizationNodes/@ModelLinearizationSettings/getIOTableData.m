function f = getIOTableData(this);
%getIOTableData  Method to get the current Simulink linearization I/O 
%                settings for the I/O table in the GUI.

%  Author(s): John Glass
%  Copyright 1986-2003 The MathWorks, Inc.

import java.lang.* java.awt.*;
iodata = this.IOData;

if length(iodata) > 0
    f = javaArray('java.lang.Object',length(iodata),5);
    
    for ct = 1:length(iodata)
        f(ct,1) = java.lang.Boolean(strcmp(iodata(ct).Active,'on'));
        f(ct,2) = String(iodata(ct).Block);
        f(ct,3) = Integer(iodata(ct).PortNumber);
        if strcmpi(iodata(ct).Type,'in')
            f(ct,4) = String('Input');
        elseif strcmpi(iodata(ct).Type,'out')
            f(ct,4) = String('Output');
        elseif strcmpi(iodata(ct).Type,'inout')
            f(ct,4) = String('Input - Output');
        elseif strcmpi(iodata(ct).Type,'outin')
            f(ct,4) = String('Output - Input');
        else
            f(ct,4) = String('None');
        end
        f(ct,5) = java.lang.Boolean(strcmp(iodata(ct).OpenLoop,'on'));
    end
else
    f = javaArray('java.lang.Object',1,5);
    f(1,1) = java.lang.Boolean(0);
    f(1,2) = String('Add linearization IOs by right clicking on a signal');
    f(1,3) = Integer(0);
    f(1,4) = String('');
    f(1,5) = java.lang.Boolean(0);    
end

