function schema
% Creates the WorkspaceObject class


%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:30 $

    pkg = findpackage('DAStudio');
    cls = schema.class ( pkg, 'WorkspaceObject');
    pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.explorer';
    cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.explorer.WorkspaceObject'};

    % Define public properties
    schema.prop(cls, 'Name', 'string');

    schema.prop(cls, 'Object', 'handle');
