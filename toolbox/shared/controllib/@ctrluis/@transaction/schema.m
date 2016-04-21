function schema
% Defines properties for @transaction class.
% Extension of transaction to support custom 
% refresh method after undo/redo.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:35 $

% Register class 
c = schema.class(findpackage('ctrluis'),'transaction');

% Editor data
schema.prop(c, 'Name', 'String');                 % name
schema.prop(c, 'Transaction', 'handle');          % handle.transaction
schema.prop(c, 'RootObjects', 'handle vector');   % Refresh action
