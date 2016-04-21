function idText=linkid(m,object,type)
%LINKID returns a DocBook link ID
%   ID=LINKID(ZSLMETHODS,OBJECTHANDLE);
%   ID=LINKID(ZSLMETHODS,OBJECTHANDLE,OBJECTTYPE);
%
%   return unique stateflow object identifier (rgTag)
%
%   OBJECTHANDLE is the handle to a model, system, block, or signal
%   OBJECTTYPE is 'mdl','sys','blk',or 'sig' respectively

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:22:21 $

if iscell(object)
   object=object{1};
end

% if id was not assigned, rgTag is empty.
idText = sf( 'get', object, '.rgTag' );
if isempty( idText )
   % if empty, assign the tag and return it.
   rgsf( 'assign_rg_tag', object );
   idText = sf( 'get', object, '.rgTag' );
end