function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.eZdspF2407TgtPrefs).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:20 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('DSPTgtPkg');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'tic2000TgtPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'eZdspF2407TgtPrefs', hDeriveFromClass);

%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'BuildOptions', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.C2400BuildOptions;

hThisProp = schema.prop(hThisClass, 'DSPBoard', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.eZdspF2407DSPBoard;

hThisProp = schema.prop(hThisClass, 'CCSLink', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.C2400CCSLink;

hThisProp = schema.prop(hThisClass, 'CodeGeneration', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.C2400CodeGeneration;
