function schema
%SCHEMA Defines properties for interpolation class
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:33:19 $

p = findpackage('tsdata');
c = schema.class(p,'interpolation');

% Properties
schema.prop(c, 'Fhandle','MATLAB array');   
schema.prop(c, 'Name','string');   


