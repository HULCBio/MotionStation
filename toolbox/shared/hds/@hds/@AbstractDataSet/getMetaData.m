function MD = getMetaData(this,var)
% Construct metadata structure

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:07 $
if nargin==1
   % Construct structure of @metadata objects with one field per variable
   MD = cell2struct(get(this.Data_,{'MetaData'}),get(getvars(this),{'Name'}),1);
else
   % Return metadata object for specified variable
   [var,idx] = findvar(this,var);
   if isempty(idx)
      error('Can only retrieve metadata for root-level variables.')
   end
   MD = this.Data_(idx).MetaData;
end
