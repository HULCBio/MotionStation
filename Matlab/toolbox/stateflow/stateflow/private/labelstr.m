function long = labelstr( label )
%LONG = LABELSTR( LABEL)  Coverts space padded matrices to zero paded matrix

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.14.2.1 $  $Date: 2004/04/15 00:58:37 $
if isempty(label)
	long = '';
	return;
end
if ~isstr(label)
	if iscell(label)
		label = strrows(label{:});
	else
		error('Invalid label.');
	end
end

label = despace(label);
long  = strlong(label);
