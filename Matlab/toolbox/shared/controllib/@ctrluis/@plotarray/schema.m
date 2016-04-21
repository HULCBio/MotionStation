function schema
% @plotarray class: low-level axes container for @axesgroup classes.
%
% REVISIT: make a value class
% 
% Purpose: 
%   * encapsulate nested arrays of HG axes
%   * manage positioning and row/column visibility.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:18:23 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'plotarray');

% General
% REVISIT: need bool vector
schema.prop(c,'Axes','MATLAB array');               % Array of HG or @plotarray handles
schema.prop(c,'ColumnVisible','MATLAB array');      % Visibility of individual columns in axes array
p = schema.prop(c,'Geometry','MATLAB array');       % Geometry parameters (structure)
% HeightRatio: Proportion of vertical space occupied by each row of axes (sum=1)
% HorizontalGap: horizontal spacing of axes in pixels
% LeftMargin: Additional margin along left border (12 pixels for resp obj)
% TopMargin: Additional margin along top border (20 pixels for resp obj)
% VerticalGap: vertical spacing of axes in pixels
p.FactoryValue = struct(...
   'HeightRatio',[],...
   'HorizontalGap',16,...
   'LeftMargin',0,...
   'TopMargin',0,...
   'VerticalGap',16,...
   'PrintScale',1);
p = schema.prop(c,'Position','MATLAB array');       % Axes array position (in normalized units)
p.AccessFlags.Init = 'off';
schema.prop(c,'RowVisible','MATLAB array');         % Visibility of individual rows in axes array
schema.prop(c,'Visible','bool');                    % Axes array visibility (default=0)
p = schema.prop(c,'Units','string');                % Position units (queried by LAYOUT for bode)
p.FactoryValue = 'normalized';  % always normalized

% Private properties
p = schema.prop(c,'Listeners','handle vector');     % Listeners
set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off');  