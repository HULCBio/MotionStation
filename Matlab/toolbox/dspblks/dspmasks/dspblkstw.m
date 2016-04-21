function varargout = dspblkstw(varargin)
% DSPBLKSTW Signal Processing Blockset Signal To Workspace block helper function.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:07:22 $

blk    = gcbh;
frame  = lower(get_param(blk,'FrameBased'));
en     = get_param(blk,'maskenables');  
if ~strcmp(frame, lower(en{5})),
   en{5}  = frame;
   set_param(blk,'maskenables',en);
end

% [EOF] dspblkstw.m
