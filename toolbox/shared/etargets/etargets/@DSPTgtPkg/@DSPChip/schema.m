function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.DSPChip).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 21:06:56 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'DSPChip', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'DSPChipLabel', 'DSPChipType');
hThisProp.AccessFlags.Init = 'on';
% hThisProp.FactoryValue = 'TI TMS320C2812';
% 
% %%%% Add properties to this class
% hThisProp = schema.prop(hThisClass, 'HSPCLKPrescaler', 'HSPCLKPrescalerType');
% hThisProp.AccessFlags.Init = 'on';
% hThisProp.FactoryValue = '0';
% 
% %%%% Add properties to this class
% hThisProp = schema.prop(hThisClass, 'eCAN', 'handle');
% hThisProp.AccessFlags.Init = 'on';
% hThisProp.FactoryValue = DSPTgtPkg.eCAN;

% hThisProp = schema.prop(hThisClass, 'Memory', 'handle vector');
