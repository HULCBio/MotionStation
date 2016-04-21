function newName = increment_name(name)
%NEWNAME = INCREMENT_NAME( NAME )

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.13.2.1 $  $Date: 2004/04/15 00:58:21 $

	[s,f] = regexp(name,'[\d]+$', 'once');

	if (isempty(s) | s==1),
		base = name;
		count = 0;
	else,
		base = name(1:(s-1));
		count = sscanf(name(s:f),'%d');
	end;

	if (~isempty(count)),
		count = int2str(count + 1);
	else
		count = '1';
	end;

	newName = [base,count];

