function h = pzplot(varargin)
% PZPLOT  Constructor for @pzplot class
%
%  H = PZPLOT(AX,[M N]) creates a @pzplot object with a M-by-N @axesgrid object
%      in the area occupied by the axes with handle AX.
%
%  H = PZPLOT([M N]) uses GCA as default axes.
%
%  H = PZPLOT([M N],'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:22:10 $

% Create class instance
h = resppack.pzplot;
%
% Parse input list
if isa(handle(varargin{1}),'hg.axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = varargin{1};

%
% Check for hold mode
[h,HeldRespFlag,HeldGridFlag] = check_hold(h, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (h overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end
%
% Generic property init
init_prop(h, ax, gridsize);
%
% User-specified initial values (before listeners are installed...)
h.set(varargin{2:end});

% Initialize the handle graphics objects used in @pzplot class.
h.initialize(ax, gridsize);
if HeldGridFlag
   h.AxesGrid.Grid = 'on';
end