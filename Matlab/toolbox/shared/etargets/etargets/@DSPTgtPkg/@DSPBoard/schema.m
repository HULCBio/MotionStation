function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.DSPBoard).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 21:06:52 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('RTW');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'TargetPrefs');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'DSPBoard', hDeriveFromClass);

%%%% Add properties to this class
hThisProp = schema.prop(hThisClass, 'DSPBoardLabel', 'string');

% hThisProp = schema.prop(hThisClass, 'Memory', 'handle vector');

% hThisProp = schema.prop(hThisClass, 'DSPChip', 'handle');
% hThisProp.AccessFlags.Init = 'on';
% hThisProp.FactoryValue = DSPTgtPkg.DSPChip;
