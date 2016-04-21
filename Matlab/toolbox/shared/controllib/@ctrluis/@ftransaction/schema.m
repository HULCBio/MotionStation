function schema
% Defines properties for @ftransaction class.
% Transaction where undo/redo actions are explicitly defined
% as function handles.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:12 $
c = schema.class(findpackage('ctrluis'),'ftransaction');

% Editor data
schema.prop(c, 'Name', 'String');            % Name
schema.prop(c, 'UndoFcn', 'MATLAB array');   % Undo function
schema.prop(c, 'RedoFcn', 'MATLAB array');   % Redo function
