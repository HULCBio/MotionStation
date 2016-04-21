function schema
%SCHEMA Defines properties for @timemetadata class (data set variable).
%
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:04 $

% This abstract parent class implements only the time merge method for
% converting time vectors onto a common basis, the timeunits enumerated
% strings, and the basic time vector descriptor proeprties. The scope of
% this abstract class excludes declaration of the Start, End, etc properties
% since the derived classes, e.g. tsdata.timemetadata, Simulink.Timemetdata, 
% Simulink.Framemetadata need to change the access properties and data types
% of the Start, End, and other properties and so these proeprties must be
% delared seperately in each derived class.

p = findpackage('tsdata');
c = schema.class(p,'abstracttimemetadata');

% Public properties
if isempty(findtype('TimeUnits'))
    schema.EnumType('TimeUnits', {'years', 'weeks', 'days', 'hours', ...
        'mins', 'secs'});
end
p = schema.prop(c,'Units','TimeUnits');
p.FactoryValue = 'secs';
p = schema.prop(c,'GridFirst','bool');
p.FactoryValue = true;
