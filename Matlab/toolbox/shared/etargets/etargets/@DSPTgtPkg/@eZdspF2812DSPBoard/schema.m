function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.eZdspF2812DSPBoard).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:07:23 $

%%%% Get handles of associated packages and classes
% hDeriveFromPackage = findpackage('RTW');
% hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
% hCreateInPackage   = findpackage('DSPTgtPkg');
hDeriveFromPackage = findpackage('DSPTgtPkg');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'DSPBoard');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'eZdspF2812DSPBoard', hDeriveFromClass);

%%%% Add properties to this class
% hThisProp = schema.prop(hThisClass, 'DSPBoardLabel', 'string');
% hThisProp.FactoryValue = 'F2812 PP Emulator';
% 
% hThisProp = schema.prop(hThisClass, 'Memory', 'handle vector');

hThisProp = schema.prop(hThisClass, 'DSPChip', 'handle');
hThisProp.AccessFlags.Init = 'on';
hThisProp.FactoryValue = DSPTgtPkg.C2812DSPChip;
