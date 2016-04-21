function output=set(varargin)
%SET Set a property value on a COM object.
%   SET(OBJ) displays all property names and their possible values for COM 
%   object OBJ. The return value is a structure whose field names are the 
%   property names of OBJ, and whose field values are cell arrays of 
%   possible property values. For those properties that have no predefined 
%   values, MATLAB returns an empty cell array in the corresponding 
%   structure field value.
%
%   Equivalent syntax is
%      S = OBJ.SET
%
%   SET(OBJ, PROPERTY) returns the possible values for the specified 
%   property of COM object OBJ. The returned array is a cell array of 
%   possible value strings or an empty cell array if the property does not 
%   have a finite set of possible values.
%
%   SET(OBJ, PROPERTYNAME, VALUE) sets the value of the specified property for 
%   COM object OBJ.OBJ can be a vector of COM objects, in which case SET sets 
%   the property values for all the COM objects specified.
%
%   Equivalent syntax is
%      S = OBJ.PROPERTY(VALUE)
%
%   SET(OBJ, PROPERTYNAME1, VALUE1, PROPERTYNAME2, VALUE2,...) sets multiple
%   property values with a single statement. 
%
%   Example:
%       h = actxcontrol ('mwsamp.mwsampctrl.1';
%       h.set('Label', 'Click to fire event'); %OR h.Label('Click to fire
%       event')
%       h.set('Label', 'Click to fire event', 'Radius', 40);
%       
%       h = actxserver('Excel.Application');
%       h.set
%       h.set('Cursor') %OR h.Cursor
%
%   See also  COM/GET, COM/ADDPROPERTY, COM/DELETEPROPERTY.

% Copyright 1984-2003 The MathWorks, Inc. 
% $Revision: 1.1.6.1 $ $Date: 2004/01/02 18:06:11 $
