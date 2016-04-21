function id = new_event(parentId, scope)
%NEW_EVENT( parentId, scope )

%   Jay R. Torgerson
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/04/15 00:58:50 $

	es = sf('EventsOf', parentId);

	EVENT = sf('get','default','event.isa');
	name = unique_name_for_list(es, EVENT);
   
	if (nargin > 1)
		id = sf('new','event','.linkNode.parent', parentId,'.name', name, '.scope', scope);
	else
		id = sf('new','event','.linkNode.parent', parentId,'.name', name);
	end;
	switch sf('get',id,'event.scope')
	case 1 % INPUT_EVENT
		sf('set',id,'event.trigger','RISING_EDGE_EVENT');
	case 2 % OUTPUT_EVENT
		sf('set',id,'event.trigger','FUNCTION_CALL');
	otherwise
	end

