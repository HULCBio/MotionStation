function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.CompilerOptions).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:48 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'CompilerOptions', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'OptimizationLevel', 'OptimizationLevelType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Function(-o2)';

hThisProp = schema.prop(hThisClass, 'CompilerVerbosity', 'CompilerVerbosityType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Verbose';

hThisProp = schema.prop(hThisClass, 'SymbolicDebugging', 'SymbolicDebuggingType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Yes';

hThisProp = schema.prop(hThisClass, 'KeepASMFiles', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'off';
