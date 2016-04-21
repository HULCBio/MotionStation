function hnewmenu = faddmenu(varargin)
%FADDMENU Add a menu to the Filter Analysis Tool (FATool).
%   FADDMENU(H,POS,STRING) creates a menu, named STRING, at position POS
%   on the menu bar at the top of FATool and returns a handle to it.  To 
%   add submenus (menus parented by menus), POS must be a vector and STRING must 
%   be a cell array. See the help for the ADDMENU function for more information.
%
%   FADDMENU(H,POS,STRING,CALLBACKS,TAGS,SEPARATORS,ACCELERATORS) creates
%   the menu and sets it properties. To add submenus (menus parented by menus), 
%   POS must be a vector and STRING must be a cell array. See the help for the 
%   ADDMENU function for more information.
%
%   EXAMPLE:
%   % Add a submenu to the "Analysis" menu
%   hndl = faddmenu(h,[5 3],'My Analysis'},...
%          'disp(''Compute my analysis'');','myanalysis','On','A');
%
% See also ADDMENU, UIMENU

%   Author(s): P. Costa 
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2002/04/14 23:51:50 $ 

error(nargchk(3,9,nargin));

% Handle to FATool
h = varargin{1}; 

% Call the menu rendering engine 
hnewmenu = addmenu(h,varargin{2:end});

% [EOF]
