function Value = pvget(sys,Property)
%PVGET  Get values of public IDMODEL properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%       Copyright 1986-2002 The MathWorks, Inc.
%       $Revision: 1.10.4.1 $  $Date: 2004/04/10 23:16:12 $

if nargin==2,
    % Value of single property: VALUE = PVGET(SYS,PROPERTY)
    % Public IDMODEL properties
    try
        switch Property % First the virtual properties
            case 'A'  
                [a,b]=arxdata(sys);
                Value = a;
            case 'B'
                [a,b]=arxdata(sys);
                Value = b;
            case 'dA'  
                [a,b,da]=arxdata(sys);
                Value = da;
            case 'dB'
                [a,b,da,db]=arxdata(sys);
                Value = db;
            case 'InitialState'
                ut = pvget(sys,'Utility');
                try
                    Value = ut.InitialState;
                catch
                    Value = 'Auto';
                end
                
            otherwise  
                Value = builtin('subsref',sys,struct('type','.','subs',Property));
        end
    catch
        Value = pvget(sys.idmodel,Property);
    end
else
    % Return all public property values
    % RE: Private properties always come last in IDMPropValues
    IDMPropNames = pnames(sys,'specific');
    IDMPropValues = struct2cell(sys);
    [Validm]=pvget(sys.idmodel);
    [a,b,da,db]=arxdata(sys);
    ut = pvget(sys,'Utility');
    try
        ini = ut.InitialState;
    catch
        ini = 'Auto';
    end
    Value = [{a;b;da;db};IDMPropValues(1:end-1);{ini};Validm];
end
