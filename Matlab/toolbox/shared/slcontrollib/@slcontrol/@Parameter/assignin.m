function assignin(this)
% ASSIGNIN Assigns the value of property VALUE to the workspace parameter
% with name as in property NAME.

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:52 $

% Update the parameter in the workspace
for ct=1:length(this)
  assignin( 'base', this(ct).Name, this(ct).Value );
end
