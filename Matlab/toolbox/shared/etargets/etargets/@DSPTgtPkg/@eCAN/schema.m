function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.eCAN).

%   Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:14 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'eCAN', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'BitRatePrescaler', 'int32');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 10;

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'TSEG1', 'TSEG1Type');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = '8';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'TSEG2', 'TSEG2Type');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = '6';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'SBG', 'SBGType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Only_falling_edges';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'SJW', 'SJWType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = '2';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'SAM', 'SAMType');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'Sample_one_time';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'EnhancedCANMode', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'on';

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'SelfTestMode', 'on/off');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = 'off';