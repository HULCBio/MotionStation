function h = mpzplot(varargin)
%MPZPLOT  Constructor for @mpzplot class.
%
%   H = MPZPLOT(AX) creates a @mpzplot object to be displayed in
%   the HG axes AX.
%
%   H = MPZPLOT uses GCA as default axes.
%
%   H = MPZPLOT('Property1','Value1',...) initializes the plot with the
%   specified attributes.

%   Author(s): Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:21:13 $

% Create class instance
h = resppack.mpzplot;

% Parse input list
if isa(handle(varargin{1}),'hg.axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = [1 1];

% Check for hold mode
[h,HeldRespFlag,HeldGridFlag] = check_hold(h, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (h overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end

% Generic property init
init_prop(h, ax, gridsize);

% User-specified initial values (before listeners are installed...)
h.set(varargin{:});

% Initialize the handle graphics objects used in @pzplot class.
h.initialize(ax, gridsize);
if HeldGridFlag
   h.AxesGrid.Grid = 'on';
end