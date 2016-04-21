function varargout = dspblkrandsrc(action)
% DSPBLKRANDSRC Signal Processing Blockset Random Source Generator block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $ $Date: 2004/04/12 23:07:05 $

blk = gcbh;

SrcType = get_param(blk,'SrcType');
InheritMode = strcmp(get_param(blk,'Inherit'),'on');
SampMode = get_param(blk,'SampMode');

enables = get_param(blk,'maskenables');

if strcmp(SrcType,'Gaussian'),
	enables(4:5) = {'on'};
	enables(2:3) = {'off'};
   enables(6)   = {'on'};
else
	enables(4:5) = {'off'};
	enables(2:3) = {'on'};
   enables(6)   = {'on'};	
end

if InheritMode,
   enables(8:11)  = {'off'};
elseif (~InheritMode & strcmp(SampMode,'Discrete')),
   enables(8:11)  = {'on'};
elseif (~InheritMode & strcmp(SampMode,'Continuous')),
   enables(8)    = {'on'};
   enables(9:10) = {'off'};
   enables(11)   = {'on'};
end

set_param(blk,'maskenables',enables);

% Plotting of icon:

% Random data:
x = (0:.1:.9)';
rand('seed',5);
y = rand(10,1);

% Axes:
x=[x;NaN;0; 0;NaN;0;1];
y=[y;NaN;1;-1;NaN;0;0];
varargout(1:2) = {x,y};



% [EOF] dspblkrandsrc.m