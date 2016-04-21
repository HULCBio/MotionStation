function setMetaData(this,var,MD)
% Construct metadata structure

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:28:17 $
if ~isa(MD,'hds.metadata')
   error('Third argument must be a @metadata object.')
end
[var,idx] = findvar(this,var);
if isempty(idx)
   error('Can only retrieve metadata for root-level variables.')
end
this.Data_(idx).MetaData = MD;
