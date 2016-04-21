function schema
% Defines properties for @axespair class (pair of axes, Bode-style)

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:34 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axespair',findclass(pk,'axesgroup'));

% Properties
p = schema.prop(c,'AxesGrouping','on/off');        % Grouping of subaxes [on|{off}]
p = schema.prop(c,'Geometry','MATLAB array');      % Geometry parameters (structure)
% VerticalGap: vertical spacing in pixels
% HeightRatio: relative heights of 1st and 2nd axes (sum = 1)
p.FactoryValue = struct('VerticalGap',14,'HeightRatio',[.53 .47]);
p = schema.prop(c,'RowVisible','string vector');   % Visibility of subaxes (default=on,on)
p.FactoryValue = {'on';'on'};               
