function ret_blks = cdma_links(sys,mode)
%CDMA_LINKS Display and return library link information for
%   blocks linked to the CDMA Reference Blockset libraries.
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
%   CDMA_LINKS(SYS) toggles the display of block links in system
%   SYS.  CDMA_LINKS(SYS,MODE) directly sets the link display state
%   by setting MODE to 'on', 'off', or 'toggle'.  By default, SYS
%   is the current system (gcs) and MODE is set to 'toggle'.
%
%   See also LIBLINKS.

% Copyright 2000-2002 The MathWorks, Inc. and ALGOREX, Inc.
% $Revision: 1.3 $ $Date: 2002/04/14 16:35:44 $

if nargin<1, sys=gcs; end
if nargin<2, mode='toggle'; end

libs = {'cdmalib', 'cdmalibv1p1'};
clrs = {'red','blue'};
blks = liblinks(sys,mode,libs,clrs);

if nargout>0, ret_blks = blks; end

% [EOF]
