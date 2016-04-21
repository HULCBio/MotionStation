function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.C2800CCSLink).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/08 21:06:08 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('DSPTgtPkg');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'CCSLink');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'C2800CCSLink', hDeriveFromClass);
