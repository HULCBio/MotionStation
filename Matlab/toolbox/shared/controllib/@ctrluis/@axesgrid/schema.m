function schema
% Defines properties for @axesgrid class (rectangular grid of axes)

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:16:52 $

% Register class 
pk = findpackage('ctrluis');
c = schema.class(pk,'axesgrid',findclass(pk,'axesgroup'));

% General
% Nrows := prod(Size([2 4]))
% Ncols := prod(Size([1 3]))
p = schema.prop(c,'AxesGrouping','string');          % Axes grouping [none|row|column|all]
p.FactoryValue = 'none';
schema.prop(c,'AxesSelector','handle');              % Handle of row/column selector UI
schema.prop(c,'ColumnLabel','MATLAB array');         % Column label strings (Ncolsx1 string cell)
schema.prop(c,'ColumnLabelStyle','handle');          % Column label style (@labelstyle handle)
schema.prop(c,'ColumnVisible','string vector');      % Visibility of individual columns in axes grid
p = schema.prop(c,'Geometry','MATLAB array');        % Geometry parameters (structure)
% HorizontalGap: horizontal spacing of axes in pixels
% LeftMargin: Additional margin along left border (12 pixels for resp obj)
% TopMargin: Additional margin along top border (20 pixels for resp obj)
% VerticalGap: vertical spacing of axes in pixels
p.FactoryValue = struct('HeightRatio',[],...
   'HorizontalGap',16,'LeftMargin',0,'TopMargin',0,'VerticalGap',16,'PrintScale',1);
schema.prop(c,'RowLabel','MATLAB array');            % Row label strings (Ncolsx1 string cell)
schema.prop(c,'RowLabelStyle','handle');             % Row label style (@labelstyle handle)
schema.prop(c,'RowVisible','string vector');         % Visibility of individual rows in axes grid

% Private
% REVISIT: make private when private prop can be accessed in local functions of methods
p = schema.prop(c,'BackgroundAxes','handle');         % Background axes
%set(p,'AccessFlags.PublicGet','off','AccessFlags.PublicSet','off')

% Events
schema.event(c,'SizeChanged');  % notifies that axes grid has been resized