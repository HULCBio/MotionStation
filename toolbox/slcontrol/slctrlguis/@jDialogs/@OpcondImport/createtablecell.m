function TableData = createdatacell(this,VarNames,VarData)
% 

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:37:18 $

Nsys = length(VarData);
TableData = javaArray('java.lang.Object',Nsys,3);

for cnt=1:Nsys
    sys = VarData{cnt};
    if isa(sys,'opcond.OperatingPoint')
        nStates = 0;
        for ct = 1:length(sys.States)
            nStates = nStates + sys.States(ct).Nx;
        end
        
        TableData(cnt,1) = java.lang.String(VarNames{cnt});
        TableData(cnt,2) = java.lang.String('Operating Point');
        TableData(cnt,3) = java.lang.String(sprintf('%d - States',nStates));
    elseif isa(sys,'double')
        TableData(cnt,1) = java.lang.String(VarNames{cnt});
        TableData(cnt,2) = java.lang.String(class(sys));
        TableData(cnt,3) = java.lang.String(sprintf('%d - States',length(sys)));
    else
        TableData(cnt,1) = java.lang.String(VarNames{cnt});
        TableData(cnt,2) = java.lang.String('Simulink State Structure');
        nStates = 0;
        for ct = 1:length(sys.signals)
            nStates = nStates + sys.signals(ct).dimensions;
        end
        TableData(cnt,3) = java.lang.String(sprintf('%d - States',nStates));        
    end
end
