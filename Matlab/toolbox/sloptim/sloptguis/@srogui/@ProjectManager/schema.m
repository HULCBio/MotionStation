function schema
% Definition for SRO Project Manager class.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:17 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'ProjectManager');
c.Description = 'Response Optimizer Project Manager (singleton)';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'Projects','handle vector');  % all existing projects
p.Description = 'All loaded projects';

% Events
schema.event(c,'LoadProject');