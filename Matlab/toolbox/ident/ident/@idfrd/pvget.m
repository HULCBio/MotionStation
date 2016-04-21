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

 %   Copyright 1986-2001 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2001/04/06 14:22:06 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   ssubs = struct('type','.','subs',Property);
   try
      Value = builtin('subsref',sys,ssubs);
   catch
          end
else
      IDMPropNames  = pnames(sys);
   IDMPropValues = struct2cell(sys);
   Value = IDMPropValues(1:length(IDMPropNames));
end
