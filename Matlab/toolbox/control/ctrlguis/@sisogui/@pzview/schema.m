function schema
%SCHEMA  Schema for HG object for pole/zero group rendering.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 05:01:18 $


% Register class 
c = schema.class(findpackage('sisogui'),'pzview');

% Define properties
% REVISIT: make them of type handle vectors when cat(1,v1,v2,..) works on such vectors
schema.prop(c,'GroupData','handle');        % Handle of underlying PZGROUP object
schema.prop(c,'Zero','MATLAB array');       % Zero handles (HG objects)
schema.prop(c,'Pole','MATLAB array');       % Pole handles (HG objects)
schema.prop(c,'Ruler','MATLAB array');      % Ruler handles (HG objects)
schema.prop(c,'Extra','MATLAB array');      % Other objects (e.g., notch width markers)

