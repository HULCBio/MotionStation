function schema()
%SCHEMA  Class constructor function (for DAStudio.MXArray).

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:30:59 $

    pkg = findpackage('DAStudio');
    dao = findclass(pkg, 'Object');
    cls = schema.class ( pkg, 'MXArray', dao);
    pkg.JavaPackage  = 'com.mathworks.toolbox.dastudio.explorer';
    cls.JavaInterfaces = {'com.mathworks.toolbox.dastudio.explorer.MXArrayWrapper'};

    % Define private fields
    p = schema.prop(cls,'workspace','handle');
    p.AccessFlags.PublicSet = 'off';
    p.Visible = 'off';

    p = schema.prop(cls, 'name', 'string');
    p.Visible = 'off';

    % define public field
    p = schema.prop(cls, 'Value', 'MATLAB array');
    p.GetFunction = @getValue;
    p.SetFunction = @setValue;

    % define read only fields
    p = schema.prop(cls, 'Size', 'string');
    p.AccessFlags.PublicSet = 'off';
    p.GetFunction = @getSize;

    p = schema.prop(cls, 'Bytes', 'MATLAB array');
    p.AccessFlags.PublicSet = 'off';
    p.GetFunction = @getBytes;

    p = schema.prop(cls, 'MATLABType', 'string');
    p.AccessFlags.PublicSet = 'off';
    p.GetFunction = @getMATLABType;

    % define overloaded methods
    m = schema.method(cls, 'getPreferredProperties');
    s = m.Signature;
    s.varargin = 'off';
    s.InputTypes = {'handle'};
    s.OutputTypes = {'string vector'};

    m = schema.method(cls, 'getDisplayIcon');
    s = m.Signature;
    s.varargin = 'off';
    s.InputTypes = {'handle'};
    s.OutputTypes = {'string'};


% This is the function used to get the Value property
function sv = getValue(h, currentV)
    sv = h.workspace.evalin(h.name);

% This is the function used to set the Value property
function sv = setValue(h, inputV)
    sv = inputV;
    h.workspace.assignin(h.name, sv);

% This is the function used to get the Size property
function sv = getSize(h, currentV)
    s = h.workspace.evalin(['whos(''' h.name ''')']);
    sv = int2str(s.size(1));
    for i = 2:length(s.size)
        sv = [sv 'x' int2str(s.size(i))];
    end

% This is the function used to get the Bytes property
function sv = getBytes(h, currentV)
    s = h.workspace.evalin(['whos(''' h.name ''')']);
    sv = s.bytes;

% This is the function used to get the Class property
function sv = getMATLABType(h, currentV)
    s = h.workspace.evalin(['whos(''' h.name ''')']);
    sv = s.class;
    if ~isequal(s.size, [1 1])
        sv = [sv ' array'];
    end

