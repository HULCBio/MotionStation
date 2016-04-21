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
%   $Revision: 1.13 $  $Date: 2002/04/10 06:07:12 $

% Get all TF-specific public properties and their values
TFPropNames = pnames(sys,'specific');
TFPropValues = struct2cell(sys);

if nargin==2,
   % Value of single property
   % First look among TF-specific properties
   imatch = find(strcmp(Property,TFPropNames));
   
   if isempty(imatch),
      % Look among parent properties
      Value = pvget(sys.lti,Property);
   else
      % TF specific property
      Value = TFPropValues{imatch};
   end
   
else
   % Return all public property values
   Value = [TFPropValues(1:length(TFPropNames)) ; pvget(sys.lti)];
   if nargout==2,
      ValStr = pvformat(Value);
   end
end


