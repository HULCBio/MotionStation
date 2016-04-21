function L = getlinks(this)
%GETLINKS  Gathers data link variables.
%
%   L = GETLINKS(D) returns the list L of data link
%   variables in the root node D.

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:09 $
L = get(this.Children_,{'Alias'});
L = cat(1,L{:});
