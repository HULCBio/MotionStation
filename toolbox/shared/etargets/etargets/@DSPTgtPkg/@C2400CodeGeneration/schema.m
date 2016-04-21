function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.C2400CodeGeneration).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:05:58 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('DSPTgtPkg');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'CodeGeneration');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'C2400CodeGeneration', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'Scheduler', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.C2400Scheduler;
