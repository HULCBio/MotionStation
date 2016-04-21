function result = walk( root, state, from, method )
%RESULT = WALK( ROOT, STATE, FROM, METHOD )

%	E. Mehran Mestchian
%	Copyright 1995-2002 The MathWorks, Inc.
%  $Revision: 1.11.2.1 $  $Date: 2004/04/15 01:01:33 $

global WALK;
if nargin==1 | nargin==2
	if ~sf('ishandle',root)
		error('Invalid Stateflow object .');
	end
	if nargin==2
		switch (state)
		case 'once per state',
			method=0;
		otherwise
			method=1;
		end
	else
		method=1;
	end
	WALK = {};
	sf('TraverseHierarchy',root,'walk',method);
	result = [WALK{:}];
	clear global WALK
	return;
end

if method==1 | from==0
	WALK{end+1}.state = state;
	WALK{end}.from = from;
end

result = 1; % CONTINUE_TRAVERSAL


