function ret_blks = dsp_links(sys,mode)
% DSP_LINKS Display and return library link information for
%   blocks linked to the Signal Processing Blockset libraries.
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
%   DSP_LINKS(SYS) toggles the display of block links in system
%   SYS.  DSP_LINKS(SYS,MODE) directly sets the link display state
%   by setting MODE to 'on', 'off', or 'toggle'.  By default, SYS
%   is the current system (gcs) and MODE is set to 'toggle'.
%
%   See also LIBLINKS.

% Copyright 1995-2003 The MathWorks, Inc.
% $Revision: 1.6.4.2 $ $Date: 2004/04/12 23:05:12 $

if nargin<1, sys=gcs; end
if nargin<2, mode='toggle'; end

libs = {'dsp2','dsp3','dsp4'};
clrs = {'red','yellow','green'};
blks = liblinks(sys,mode,libs,clrs);

if nargout>0, ret_blks = blks; end

% [EOF] dsp_links.m
