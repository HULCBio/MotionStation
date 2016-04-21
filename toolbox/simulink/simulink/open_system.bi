function [varargout] = open_system(varargin)
%OPEN_SYSTEM Open a Simulink system window or a block dialog box.
%   OPEN_SYSTEM('SYS') opens the specified system or subsystem window.
%
%   OPEN_SYSTEM('BLK'), where 'BLK' is a full block path name, opens the
%   dialog box associated with the specified block.
%
%   OPEN_SYSTEM also supports various options as additional input arguments.
%   These are:
%
%       DESTSYS    Another system window in which to open SYS into.  This
%                  option can also be used in conjunction with options
%                  'replace' and 'reuse'. Note that SYS and
%                  DESTSYS must be within the same model.
%       force      Open the system under its mask and/or any OpenFcn that
%                  is configured for the block.
%       parameter  Open the parameter dialog for the block.
%       property   Open the property dialog for the block.
%       mask       Open the Mask dialog for the block.
%       OpenFcn    Execute the OpenFcn for the block.
%       replace    When opening a system into another system's window, 
%                  reuse the destination window but set the window 
%                  size to be the size of the system being opened.
%       reuse      When opening a system into another system's window, reuse
%                  the window, and also perform a 'fit to screen'.
%
%   There are cases in which you may want to use combinations of the above
%   options.  For instance, if you want to open a masked block with window
%   reuse, you would use:
%
%     OPEN_SYSTEM(SYS,DESTSYS,'force','replace')
%
%   The 'force' option is required so that open_system opens the underlying
%   subsystem window for the masked block.
%
%   Note that OPEN_SYSTEM accepts cell arrays for the input arguments.  This
%   allows you to vectorize calls to OPEN_SYSTEM.
%
%   Examples:
%
%       % open 'f14'
%       open_system('f14');
%
%       % open the subsystem 'f14/Controller'
%       open_system('f14/Controller')
%
%       % open 'f14' into the 'f14/Controller' window in 'reuse' mode
%       open_system('f14','f14/Controller','reuse');
%
%       % vectorized open_system
%       open_system( { 'f14', 'vdp' });
%
%       % another vectorized open_system, note that empty strings
%       % are treated as no operation
%       % also note that this requires that 'f14' be opened before
%       % executing
%       open_system( { 'f14', 'f14/Controller', 'f14' },...
%                    {  '',   '',               'vdp' }, ...
%                    {  '',   '',               'replace' } );
%
%   See also CLOSE_SYSTEM, SAVE_SYSTEM, NEW_SYSTEM, LOAD_SYSTEM.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.20.2.2 $
%   Built-in function.

if nargout == 0
  builtin('open_system', varargin{:});
else
  [varargout{1:nargout}] = builtin('open_system', varargin{:});
end
