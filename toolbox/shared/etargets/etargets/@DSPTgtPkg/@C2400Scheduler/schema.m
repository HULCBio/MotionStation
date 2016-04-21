function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.C2400Scheduler).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:02 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'C2400Scheduler', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'Timer', 'C2400TimerType');
hThisProp = schema.prop(hThisClass, 'TimerClockPrescaler', 'TimerClockPrescalerType');