function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.CCSLink).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:39 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'CCSLink', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'CCSHandleName', 'string');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'CCS_Obj';

hThisProp = schema.prop(hThisClass, 'ExportCCSHandle', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'on';