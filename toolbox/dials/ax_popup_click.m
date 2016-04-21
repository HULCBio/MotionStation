function ax_popup_click(varargin)
%AX_POPUP_CLICK Callback file for ActiveX Block's Popup Menu
%   click event.
%   Designed only for use by dglib.mdl.

%   Copyright 1998-2004 The MathWorks, Inc.
%   $Revision: 1.14.4.1 $  $Date: 2003/12/15 15:53:09 $

blk = gcb;
axblkUd=get_param(blk, 'UserData');
hActx=axblkUd.hActx;
sys = gcs;

switch localGetPopVal(varargin),
  case 1,
    if ~isempty(hActx)
      if localHasPropertyPage(hActx),
        lock = get_param(bdroot(sys), 'lock');
        if strcmp(lock, 'off')
          set_param(bdroot(sys), 'dirty', 'on');
        end
        propedit(hActx)
      end
    end
  case 2,
    open_system(blk,'mask'); % Open the block params explicitly
end

function out = localHasPropertyPage(hActx),
    out = ismethod(hActx,'ShowPropertyPage');
  
  function out = localGetPopVal(argsIn),
        out = double(argsIn{3});

