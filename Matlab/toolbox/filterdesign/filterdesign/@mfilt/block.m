%BLOCK Generate a Signal Processing Blockset block.
%   BLOCK(Hm) generates a Signal Processing Blockset block equivalent to Hm.
%
%   BLOCK(Hm, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates a
%   Signal Processing Blockset block using the options specified in the
%   parameter/value pairs. The available parameters are:
%
%   Destination:    <'Current'>, 'New'
%   Blockname:      'Filter' by default
%   OverwriteBlock: 'on', <'off'>
%   MapStates:      'on', <'off'>
%
%    EXAMPLES:
%    L = 3; % interpolation factor
%    Hm = mfilt.firinterp(L);
% 
%    %#1 Default syntax:
%    block(Hm);
% 
%    %#2 Using parameter/value pairs:
%    block(Hm, 'Blockname', 'FirInterp');

% Copyright 1999-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:24:46 $

% Help for the filter's BLOCK method.

% [EOF]
