function ret_blks = comm_links(sys,mode)
%COMM_LINKS Display and return library link information for
%   blocks linked to the Communications Blockset libraries.
%
%   The full path to each library block found in a model is
%   displayed below the block, suppressing the original block
%   name until the link display is turned off.  The search
%   descends down to all levels of the model.
%
%   A summary report indicating the number of blocks linked to
%   each library is displayed in the MATLAB command window when
%   the link display is turned on.
%
%   Attempts to save or run the model while the link display is
%   turned on will automatically turn off the link display.
%
%   COMM_LINKS(SYS) toggles the display of block links in system
%   SYS.  COMM_LINKS(SYS,MODE) directly sets the link display state
%   by setting MODE to 'on', 'off', or 'toggle'.  By default, SYS
%   is the current system (gcs) and MODE is set to 'toggle'.
%
%   See also LIBLINKS.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.11.4.1 $ $Date: 2003/04/10 05:14:34 $

if nargin<1, sys=gcs; end
if nargin<2, mode='toggle'; end

libs = {'comm15', 'comm25', 'comm3'};
clrs = {'red', 'red', 'blue'};
blks = liblinks(sys,mode,libs,clrs);

if nargout>0, ret_blks = blks; end

% [EOF] comm_links.m
