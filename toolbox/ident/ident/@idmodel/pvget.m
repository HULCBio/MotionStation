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

%       Author(s): P. Gahinet, 7-8-97
%       Copyright 1986-2001 The MathWorks, Inc.
%       $Revision: 1.6 $  $Date: 2001/04/06 14:22:10 $

if nargin==2,
   % Value of single property: VALUE = PVGET(SYS,PROPERTY)
   ssubs = struct('type','.','subs',Property);
   try
      Value = builtin('subsref',sys,ssubs);
   catch
      try
         Value = builtin('subsref',sys.Algorithm,ssubs);
      catch
                   Value = builtin('subsref',sys.EstimationInfo,ssubs);
      end
   end
else
   % Return all public property values
   % RE: Private properties always come last in IDMODEL PropValues
   IDMPropNames  = pnames(sys);
   IDMPropValues = struct2cell(sys);
   Value = IDMPropValues(1:length(IDMPropNames));
end
