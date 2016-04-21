function schema
%SCHEMA Defines timeseriesArray data storage class
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:34:04 $

% Register class 
p = findpackage('tsdata');
c = schema.class(p,'timeseriesArray', ...
    findclass(findpackage('hds'),'BasicArray'));

% Public properties
% The ReadOnly flag is used by the @tscollection to disable user
% writes to the time vector of a member @timeseries
p = schema.prop(c,'ReadOnly','on/off'); 
p.FactoryValue = 'off';
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'off', 'AccessFlags.PublicSet', 'off',...
    'AccessFlags.Serialize','off');

