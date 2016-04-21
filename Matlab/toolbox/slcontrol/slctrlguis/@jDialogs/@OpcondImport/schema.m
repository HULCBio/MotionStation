function schema
% Defines properties for @abstrimimport an abstract class for import dialog
% creation

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:37:19 $

% Register class 
pksc = findpackage('ctrldlgs');
pk = findpackage('jDialogs');
c = schema.class(pk,'OpcondImport',findclass(pksc,'abstrimport'));

% Basic properties
p = schema.prop(c,'Task','MATLAB array');
p = schema.prop(c,'NxDesired','MATLAB array');
p = schema.prop(c,'importfcn','MATLAB array');
p = schema.prop(c,'Projects','MATLAB array');
