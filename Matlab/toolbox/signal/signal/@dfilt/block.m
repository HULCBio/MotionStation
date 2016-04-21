%BLOCK Generate a Signal Processing Blockset block equivalent to the filter object.
%   BLOCK(Hd) generates a Signal Processing Blockset block equivalent to Hd.
%
%   BLOCK(Hd, PARAMETER1, VALUE1, PARAMETER2, VALUE2, ...) generates a
%   Signal Processing Blockset block using the options specified in the
%   parameter/value pairs. The available parameters are:
%
%   Destination:    <'Current'>, 'New'
%   Blockname:      'Filter' by default
%   OverwriteBlock: 'on', <'off'>
%   MapStates:      'on', <'off'>
%
%    EXAMPLES:
%    [b,a] = butter(5,.5);
%    Hd = dfilt.df1(b,a);
% 
%    %#1 Default syntax:
%    block(Hd);
% 
%    %#2 Using parameter/value pairs:
%    block(Hd, 'Blockname', 'DF1');

% Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/04/12 23:59:49 $

% Help for the filter's BLOCK method.

% [EOF]
