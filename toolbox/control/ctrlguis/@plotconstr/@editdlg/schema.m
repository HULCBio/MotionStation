function schema
% Defines properties for @editdlg class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $ $Date: 2002/04/10 05:08:49 $

pk = findpackage('plotconstr');

% Register class 
c = schema.class(pk,'editdlg',findclass(pk,'constreditor'));

% Public
schema.prop(c, 'Constraint', 'handle');   % Handle of edited constraint

% Private
schema.prop(c, 'ParamEditor', 'mxArray');     % Param editor handles
schema.prop(c, 'Handles', 'mxArray');         % Other handles
schema.prop(c, 'Listeners', 'handle vector'); % Listeners
% Listeners associated w/ targeted constraint (temporary)
schema.prop(c, 'TempListeners', 'handle vector');
