function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.LinkerOptions).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:02 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'LinkerOptions', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'KeepOBJFiles', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'on';

hThisProp = schema.prop(hThisClass, 'CreateMAPFile', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'on';

hThisProp = schema.prop(hThisClass, 'LinkerCMDFile', 'LinkerCMDFileType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Full_memory_map';

hThisProp = schema.prop(hThisClass, 'LinkerCmdFileName', 'string');
