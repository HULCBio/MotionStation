function schema

%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:31:40 $

    pkg = findpackage('DAStudio');
    cls = schema.class ( pkg, 'WorkspaceWrapper');
    pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.explorer';
    cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.explorer.WorkspaceInterface'};

    % Define private fields
    p = schema.prop(cls,'wrappedWorkspace','handle');
    p.AccessFlags.PublicSet = 'off';
    p.Visible = 'off';

    p = schema.prop(cls,'jCache','handle');
    p.AccessFlags.PublicSet = 'off';
    p.Visible = 'off';

    % Define public methods
    m = schema.method(cls, 'getData');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle'};
    m.signature.outputTypes={'handle vector'};

    m = schema.method(cls, 'clearData');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string vector'};
    m.signature.outputTypes={};

    m = schema.method(cls, 'validateNewNames');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string vector'};
    m.signature.outputTypes={'string vector'};

    m = schema.method(cls, 'renameObject');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string', 'string'};
    m.signature.outputTypes={'string'};

    m = schema.method(cls, 'addNewObjects');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string', 'string vector'};
    m.signature.outputTypes={};

    m = schema.method(cls, 'owner');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle'};
    m.signature.outputTypes={'handle'};

    m = schema.method(cls, 'assignin');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string', 'MATLAB array'};
    m.signature.outputTypes={};

    m = schema.method(cls, 'evalin');
    m.signature.varargin = 'off';
    m.signature.inputTypes={'handle', 'string'};
    m.signature.outputTypes={'MATLAB array'};

