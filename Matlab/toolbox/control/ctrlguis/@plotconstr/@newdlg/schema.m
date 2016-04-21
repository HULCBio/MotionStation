function schema
% Defines properties for @newdlg class

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $ $Date: 2002/04/10 05:09:13 $

% RE: CLIENT object is assumed to have
%       * ADDCONSTR method to add a constraint to its list of constraints
%       * NEWCONSTR method to list available constraint types and create instance of 
%         particular type

% Register class 
c = schema.class(findpackage('plotconstr'),'newdlg');

% Public
schema.prop(c,'Client','handle');           % Object invoking dialog
p = schema.prop(c,'Constraint','handle');   % Handle of specified constraint
set(p,'AccessFlags.AbortSet','off')         % Always trigger listener (updates constr. param. box)

% Private
schema.prop(c,'ParamEditor','mxArray');      % Param editor handles
schema.prop(c,'Handles','mxArray');          % Other handles
schema.prop(c,'Listeners','handle vector');  % Listeners

