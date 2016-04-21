function h = sigmaplot(varargin)
% SIGMAPLOT  Constructor for @sigmaplot class
%
%  H = SIGMAPLOT([1 1]) or H = SIGMAPLOT creates a @sigmaplot object 
%  with a 1-by-1 @axesgrid object.
%
%  H = SIGMAPLOT([1 1],'Property1','Value1',...) initializes the plot with the
%  specified attributes.

%  Author(s): Bora Eryilmaz, Pascal Gahinet, Kamesh Subbarao
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:23:21 $

% Create class instance
h = resppack.sigmaplot;
%
% Parse input list
if nargin & isa(handle(varargin{1}),'hg.axes')
   ax = varargin{1};
else
   ax = gca;
end
gridsize = [1 1];
%
% Check for hold mode
[h,HeldRespFlag] = check_hold(h, ax, gridsize);
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

% Initialize the handle graphics objects used in @sigmaplot class.
h.initialize(ax, gridsize);
