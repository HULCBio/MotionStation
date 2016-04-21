function this = simplot(varargin)
%SIMPLOT  Constructor for @timeplot class
%
%  H = SIMPLOT(AX,NY) creates a @simplot object with an NY-by-1 grid of
%  axes (@axesgrid object) in the area occupied by the axes with handle AX.
%
%  H = SIMPLOT(NY) uses GCA as default axes.
%
%  H = SIMPLOT(NY,'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): 
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/10 23:37:53 $

% Create class instance
this = mpcobjects.simplot;

% Parse input list
if isa(handle(varargin{1}),'hg.axes')
   ax = varargin{1};
   varargin = varargin(2:end); 
else
   ax = gca;
end
gridsize = [varargin{1} 1];

% Check for hold mode
[this,HeldRespFlag] = check_hold(this, ax, gridsize);
if HeldRespFlag
   % Adding to an existing response (this overwritten by that response's handle)
   % RE: Skip property settings as I/O-related data may be incorrectly sized (g118113)
   return
end

% Style is always paired
this.InputStyle = 'paired';

% Generic property init
init_prop(this, ax, gridsize);

% User-specified initial values (before listeners are installed...)
this.set(varargin{2:end});

% Initialize the handle graphics objects used in @simplot class.
this.initialize(ax, gridsize);

% Create @siminput for input data tracking
createinput(this)

