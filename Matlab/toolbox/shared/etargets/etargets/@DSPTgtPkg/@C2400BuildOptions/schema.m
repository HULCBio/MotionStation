function schema()
%SCHEMA  Class constructor function (for DSPTgtPkg.BuildOptions).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/08 21:05:50 $

%%%% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('DSPTgtPkg');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'BuildOptions');
hCreateInPackage   = findpackage('DSPTgtPkg');

%%%% Construct class
hThisClass = schema.class(hCreateInPackage, 'C2400BuildOptions', hDeriveFromClass);
