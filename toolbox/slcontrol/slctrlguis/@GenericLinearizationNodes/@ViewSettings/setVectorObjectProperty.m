function setVectorObjectProperty(this,Property,DataObject);
%% setVectorObjectProperty

%%  Author(s): John Glass
%%  Copyright 1986-2003 The MathWorks, Inc.

Data = DataObject(1,1);
       
if islogical(Data)
    if Data
        this.(Property) = true;
    else
        this.(Property) = false;
    end 
else
    DoubleData = str2num(Data);
    if ~isempty(DoubleData)
        this.(Property) = DoubleData;
    else
        this.(Property) = Data;
    end
end