function schema
% Defines properties for @tooleditor adapter class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:12:46 $

% RE: @tooleditor adapts @tooldlg editor to @constreditor interface

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'tooleditor',findclass(pk,'constreditor'));

% Public
schema.prop(c, 'Container', 'handle');    % Current constraint container
schema.prop(c, 'Dialog', 'handle');       % @tooldlg handle
