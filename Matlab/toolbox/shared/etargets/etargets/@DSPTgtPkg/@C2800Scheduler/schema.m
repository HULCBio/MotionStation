function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.C2800Scheduler).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:15 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'C2800Scheduler', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'Timer', 'C2800TimerType');
%%hThisProp = schema.prop(hThisClass, 'TimerClockPrescaler', 'TimerClockPrescalerType');

% hThisProp = schema.prop(hThisClass, 'TimerClockPrescaler', 'int32');
% hThisProp.AccessFlags.Init = 'on';
% hThisProp.FactoryValue = 0;