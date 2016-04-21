function ax_block_dclk(varargin)
%AX_BLOCK_DCLK Callback file for ActiveX Block's double click event.
%   Designed only for use by dglib.mdl.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2003/12/15 15:53:08 $

% Get and check the handle to the activex control
hActx = varargin{1};
if isempty(hActx),      return;     end

% get and check the handle to the parent block
blk = ax_block( 'FindActiveXBlock', hActx );
if isempty (blk),       return;     end;

% get the root model
Root   = bdroot( blk );

% Special cases for Dial controls:
if ~isempty( get_param( blk, 'DialOutEvent' ) ),
    SimStatus = get_param( Root, 'SimulationStatus' );
    if strcmp( SimStatus, 'running' )
        %
        % Don't open the active X dialog when the simulation is running.  This
        % is rarely the desired intention.  This is done by ignoring the 2nd
        % click of a double click.  The 1st click is still processed as
        % a single click, causing a change of the controls value.
        %
        return;
    end
    if strcmp( SimStatus, 'external' ) & ...
        strcmp( get_param( Root, 'ExtModeUploadStatus' ), 'uploading' ),
		%
		% Don't open the active X dialog when the simulation is running.  This
		% is rarely the desired intention.  This is done by ignoring the 2nd
		% click of a double click.  The 1st click is still processed as
		% a single click, causing a change of the controls value.
		%
		return;
    end
end

% get the parent system
Parent = get_param( blk, 'Parent' );
  
% Set the block and system as current.
OldLock = get_param( Root, 'lock' );
set_param( Root,    'lock',         'off' );
set_param( 0,       'CurrentSystem', Parent  );
set_param( Parent,  'CurrentBlock',  blk  );
set_param( Root,    'lock',          OldLock );
 
% Open the ActiveX property sheet for this control if it is known to have one
if localHasPropertyPage(hActx),
    if strcmp( OldLock, 'off' )
      set_param( Root, 'dirty', 'on'); % if not in a library,
	                                       % set Root dirty.
    end
    propedit(hActx) % Open the property edit sheet for this control.
end


function out = localHasPropertyPage(hActx),
    out = ismethod(hActx,'ShowPropertyPage');
