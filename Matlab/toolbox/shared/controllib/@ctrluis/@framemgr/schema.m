function schema
% Defines properties for @framemgr class.
%
% This class manages events and actions in an entire frame and
% acts as mediator/broker between the various objects sharing 
% the frame space.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:06 $

pk = findpackage('ctrluis');

% Register class 
c = schema.class(pk,'framemgr',findclass(pk,'eventmgr'));

% Public properties
schema.prop(c, 'EventRecorder', 'handle');       % @recorder instance
schema.prop(c, 'Frame', 'MATLAB array');         % Supporting frame
schema.prop(c, 'Status', 'String');              % Status text (permanent)
schema.prop(c, 'StatusField', 'MATLAB array');   % Text field where to display status

