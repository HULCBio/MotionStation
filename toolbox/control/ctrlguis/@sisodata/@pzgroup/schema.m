function schema
%SCHEMA  Schema for pole/zero group class

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.3 $ $Date: 2002/04/10 04:52:49 $


% Register class 
c = schema.class(findpackage('sisodata'),'pzgroup');

% Define properties
% RE: Supported group types are Real, Complex, LeadLag, and Notch
schema.prop(c,'Type','string');           % Group type 
p(1) = schema.prop(c,'Zero','MATLAB array');   % Zero handles (HG objects)
p(2) = schema.prop(c,'Pole','MATLAB array');   % Pole handles (HG objects)

% Defaults
% RE: AbortSet=off to correctly overwrite bad user input in PZ editor 
%     (group data is unchanged in such case)
set(p,'AccessFlags.AbortSet','off',...
      'AccessFlags.Init','on','FactoryValue',zeros(0,1));

% Event
schema.event(c,'PZDataChanged');    % Notifies of modified Zero or Pole data
    
