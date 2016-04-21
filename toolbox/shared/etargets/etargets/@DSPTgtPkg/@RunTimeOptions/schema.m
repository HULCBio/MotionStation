function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.RunTimeOptions).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:06 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'RunTimeOptions', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'BuildAction', 'BuildActionType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Build_and_execute';

hThisProp = schema.prop(hThisClass, 'OverrunAction', 'OverrunActionType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Continue';
