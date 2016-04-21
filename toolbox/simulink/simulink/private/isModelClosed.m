function y = isModelClosed(iMdl)
% Abstract:
%    Returns whether model <iMdl> is closed.

%   Copyright 2002 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $
  
  y = isempty(find_system('SearchDepth', 0, ...
                          'type', 'block_diagram', ...
                          'Name', iMdl));
