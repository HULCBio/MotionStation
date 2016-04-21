function [F, W, M] = slctrlexplorer(varargin)
% SLCTRLEXPLORER Method to start or interact with the Tree Explorer for
% Simulink-based control products.
% 
% [F, W, M] = SLCTRLEXPLORER returns the handles to the frame and root node.
% [F, W, M] = SLCTRLEXPLORER('initialize') returns the handles to the frame
% and root node and calls the constructor to the frame if needed.

% Author(s): B. Eryilmaz, J. Glass
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:24 $

%% Explorer GUI and UDD root node handles
mlock
persistent MANAGER;
persistent ROOT;  % To speed up UDD hierarchy browsing. Shouldn't be necessary!

% Check for valid platform for Java Swing
if ~usejava('Swing')
  error('The Tree Explorer requires Java Swing to run.');
end

% Check for a valid frame
if (nargin > 0) && isempty(MANAGER) && strcmp(varargin{1},'initialize')
  % Create the root node object
  ROOT = explorer.Workspace;
  
  % Create tree manager
  MANAGER = explorer.TreeManager( ROOT );
end

% Lang workaround for returned persistent variables
M = MANAGER;
if ~isempty(MANAGER)
  F = MANAGER.Explorer;
  W = MANAGER.Root;
else
  F = [];
  W = [];
end
