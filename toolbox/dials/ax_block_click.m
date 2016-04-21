function ax_block_click(varargin)
%AX_BLOCK_CLICK Callback file for ActiveX Block's click event.
%   Designed only for use by dglib.mdl.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.1 $  $Date: 2003/12/15 15:53:07 $

% Find the block that contains the control

blk = ax_block('FindActiveXBlock', varargin{1});

if ~isempty(blk)
    Parent = get_param( blk, 'Parent' );
    Root = bdroot( Parent );
    set_param(blk,'Selected','on')
    % Set the block and system as current.
    OldLock = get_param( Root, 'lock' );
    set_param( Root,    'lock',         'off' );
    set_param( 0,       'CurrentSystem', Parent  );
    set_param( Parent,  'CurrentBlock',  blk  );
    set_param( Root,    'lock',          OldLock );

    if IsRightClick(varargin),
        persistent h;
        h = actxcontrol('Internet.PopupMenu',[0 0 0 0], Parent,...
               {'click', 'ax_popup_click'});

        invoke(h, 'AddItem', 'Control Display Properties');
        invoke(h, 'AddItem', 'Block Parameters');
        invoke(h, 'PopUp');
    end
end


function out = IsRightClick(argsin),
    out = (argsin{3} == 2);

