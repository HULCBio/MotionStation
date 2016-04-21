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
%   $Revision: 1.13 $  $Date: 2002/04/10 06:12:09 $

% Get all ZPK-specific public properties and their values
ZPKPropNames = pnames(sys,'specific');
ZPKPropValues = struct2cell(sys);

if nargin==2,
   % Value of single property
   % First look among ZPK-specific properties
   imatch = find(strcmp(Property,ZPKPropNames));
   
   if isempty(imatch),
      % Look among parent properties
      Value = pvget(sys.lti,Property);
   else
      % ZPK specific property
      Value = ZPKPropValues{imatch};
   end
   
else
   % Return all public property values
   Value = [ZPKPropValues(1:length(ZPKPropNames)) ; pvget(sys.lti)];
   if nargout==2,
      ValStr = pvformat(Value);
   end
end

