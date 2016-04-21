function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.BuildOptions).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:47 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'BuildOptions', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'CompilerOptions', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.CompilerOptions;

hThisProp = schema.prop(hThisClass, 'LinkerOptions', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.LinkerOptions;

hThisProp = schema.prop(hThisClass, 'RunTimeOptions', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.RunTimeOptions;
