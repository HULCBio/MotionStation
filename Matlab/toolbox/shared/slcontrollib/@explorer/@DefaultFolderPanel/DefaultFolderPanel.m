function this = DefaultFolderPanel( Panel, Node, manager, varargin )
% DEFAULTFOLDERPANEL Constructor for @DefaultFolderPanel class
%
% This class manages the com.mathworks.toolbox.control.util.DefaultExplorerPanel
% dialog callbacks.
%
% VARARGIN If you want to exclude certain classes of objects from the table
% in the dialog, provide a cell array of strings that has the class names
% to be excluded.

% Author(s): Bora Eryilmaz
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:00 $

% Create class instance
this = explorer.DefaultFolderPanel;

% Store the current node & panel
this.Node  = Node;
this.Panel = Panel;

% Exclude list
if ~isempty(varargin)
  this.ExcludeList = varargin{:};
end

% Configure callbacks & listeners
configureFolderPanel(this, manager);
