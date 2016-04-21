function h = rlplot(varargin)
%RLPLOT  Constructor for @rlplot class.
%
%  H = RLPLOT(AX) creates a root locus plot in the area occupied  
%  by the axes with handle AX.
%
%  H = RLPLOT uses GCA as default axes.
%
%  H = RLPLOT('Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): P. Gahinet
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:22:57 $

% Create class instance
h = resppack.rlplot;

% Parse input list
if nargin & isa(handle(varargin{1}),'hg.axes')
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

% Initialize the handle graphics objects used in @rlplot class.
h.initialize(ax,gridsize);   % calls @pzplot method
h.AxesGrid.Title = 'Root Locus';
if HeldGridFlag
   h.AxesGrid.Grid = 'on';
end

% Listener to PreLimitChanged event for limit picking
L = handle.listener(h.AxesGrid,'PreLimitChanged',@LocalAdjustView);
L.CallbackTarget = h;
h.addlisteners(L);

%--------------------- Local Functions -------------------------
function LocalAdjustView(this, eventdata)
% Prepares view for limit picker
% REVISIT: use FIND
for r=this.Responses(strcmp(get(this.Responses,'Visible'),'on'))'
   adjustview(r,'prelim')
end


