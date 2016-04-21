function initialize(this, ax, gridsize)
%  INITIALIZE  Initializes the @timeplot objects.
%
%  INITIALIZE(H,AX,[M N]) creates an @axesgrid object of size MxN
%  to display response plots.

%  Author(s): Bora Eryilmaz
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:24:07 $

% Axes geometry parameters
geometry = struct('HeightRatio',[],...
   'HorizontalGap', 16, 'VerticalGap', 16, ...
   'LeftMargin', 12, 'TopMargin', 20, 'PrintScale', 1);

% Create @axesgrid object
this.AxesGrid = ctrluis.axesgrid(gridsize, ax, ...
   'Visible',     'off', ...
   'Geometry',    geometry, ...
   'LimitFcn',  {@updatelims this}, ...
   'Title',    'Time Response', ...
   'XLabel',  'Time',...
   'YLabel',  'Amplitude',...
   'XUnit',  'sec');
             
% Generic initialization
init_graphics(this)

% Add listeners
addlisteners(this)