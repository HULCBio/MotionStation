function [Value,ValStr] = pvget(sys,Property)
%PVGET  Get values of public LTI properties.
%
%   VALUES = PVGET(SYS) returns all public values in a cell
%   array VALUES.
%
%   [VALUES,VALSTR] = PVGET(SYS) also returns a cell array 
%   of strings VALSTR containing formatted property value
%   info to be displayed by GET(SYS).  The formatting is done
%   using PVFORMAT. 
%
%   VALUE = PVGET(SYS,PROPERTY) returns the value of the
%   single property with name PROPERTY.  The string property
%   must contain the true property name.
%
%   See also GET.

%   Author(s): P. Gahinet, 7-8-97
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/10 06:16:58 $

% Get all FRD-specific public properties and their values
FRDPropNames = pnames(sys,'specific');
FRDPropValues = struct2cell(sys);

if nargin==2,
   % Value of single property
   % First look among FRD-specific properties
   imatch = find(strcmp(Property,FRDPropNames));
   
   if isempty(imatch),
      % Look among parent properties
      Value = pvget(sys.lti,Property);
   else
      % FRD specific property
      Value = FRDPropValues{imatch};
   end
   
else
   % Return all public property values
   Value = [FRDPropValues(1:length(FRDPropNames)) ; pvget(sys.lti)];
   if nargout==2,
      ValStr = pvformat(Value);
   end
end
