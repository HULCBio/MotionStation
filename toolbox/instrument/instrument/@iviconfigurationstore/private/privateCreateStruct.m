function s = privateCreateStruct(type, name)
%PRIVATECREATESTRUCT Create an entry struct.
%
%   S = PRIVATECREATESTRUCT(type, name) creates a default structure for a
%   configuration store entry of TYPE. 

%   PE 10-01-03
%   Copyright 1999-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/02/01 21:55:10 $

s.Type = type;
s.Name = name;

switch type
    case 'HardwareAsset'
        s.Description = '';
        s.IOResourceDescriptor = '';
    case 'DriverSession'
        s.Description = '';
        s.HardwareAsset = '';
        s.VirtualNames = [];
        s.SoftwareModule = '';
        s.Cache = false;
        s.QueryInstrStatus = false;
        s.DriverSetup = '';
        s.InterchangeCheck = false;
        s.RangeCheck = false;
        s.RecordCoercions = false;
        s.Simulate = false;
    case 'LogicalName'
        s.Description = '';
        s.Session = '';
end
