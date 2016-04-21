function [Value,ValStr] = pvget(mpcobj,Property)
%PVGET  Get values of public MPC properties.
%
%   VALUES = PVGET(MPCOBJ) returns all public values in a cell
%   array VALUES.
%
%   VALUE = PVGET(MPCOBJ,PROPERTY) returns the value of the
%   single property with name PROPERTY.
%
%   See also GET.

%   Author: A. Bemporad, P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.10.3 $  $Date: 2003/12/04 01:32:51 $   

if nargin==2,
   % Value of single property: VALUE = PVGET(MPCOBJ,PROPERTY)
   % Public MPCOBJ properties
   Value = builtin('subsref',mpcobj,struct('type','.','subs',Property));
   
else
   % Return all public property values
   % RE: Private properties always come last in MPCPropValues
   MPCPropNames = pnames(mpcobj);
   MPCPropValues = struct2cell(mpcobj);
   Value = MPCPropValues(1:length(MPCPropNames));
   if nargout==2,
      ValStr = pvformat(Value);
   end
   
end
