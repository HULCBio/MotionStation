function rmpar(this,Name)
% Deletes parameter from grid.

%   $Revision: 1.1.6.1 $ $Date: 2004/01/03 12:27:59 $
%   Copyright 1986-2004 The MathWorks, Inc.
if ~isempty(this.Parameters)
   this.Parameters(strcmp(Name,{this.Parameters.Name}),:) = [];
end
