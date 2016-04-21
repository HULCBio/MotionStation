function id = new_data(parentId, scope,name),
%NEW_DATA( parentId, scope )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.15.2.1 $  $Date: 2004/04/15 00:58:49 $

ds = sf('DataOf', parentId);

DATA = sf('get','default','data.isa');
if(nargin<3)
   name = unique_name_for_list(ds, DATA);
end
if(nargin<2)
   %%% Data created for functions must be TEMPORARY by default
   %%% For other parents, use LOCAL_DATA
   if(~isempty(sf('find',parentId,'state.type','FUNC_STATE')))
      scope = 'TEMPORARY_DATA';
   else
      scope = 'LOCAL_DATA';
   end
end
id = sf('new','data','.linkNode.parent', parentId, '.name', name, '.scope', scope);
