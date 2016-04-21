function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:25 $

strout=outlinestring(rptproptable,c,'Stateflow');

% see if we have invalid parent
if ~rgsf( 'is_parent_valid', c );
	strout = sprintf('? %s <invalid parent>',strout);
end