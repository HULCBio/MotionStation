function output = get(obj, varargin)
%GET Get COM object properties.
%   GET(OBJ) displays all property names and their current values for
%   COM object OBJ.
%
%   Equivalent syntax is
%      S = OBJ.GET
%
%   S = GET(OBJ) returns a structure, S, where each field name is the
%   name of a property of OBJ and each field contains the value of that 
%   property.
%
%   S = GET(OBJ, PROPERTY) returns the value of the specified 
%   property for COM object OBJ. PROPERTY is a quoted string 
%   containing the property name.
%
%   Equivalent syntax is
%      S = OBJ.PROPERTY
%
%   S = GET(OBJ, PROPERTY, VALUE1, VALUE2, ...) returns the value of 
%   the specified property that takes arguments VALUE1, VALUE2, etc.
%
%   Example:
%       e = actxserver('Excel.Application');
%       e.get('Path') OR e.Path
%       e.get
%
%   See also COM/SET, COM/INSPECT, COM/ISPROP, COM/ADDPROPERTY, 
%   COM/DELETEPROPERTY.

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $ $Date: 2004/01/02 18:06:03 $
