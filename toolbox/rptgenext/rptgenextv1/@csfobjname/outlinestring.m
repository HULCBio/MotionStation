function strout=outlinestring(c)
%OUTLINESTRING displays a representation of the component in the outline

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:01 $

info=getinfo(c);
strout=xlate(info.Name);

if ~rgsf( 'is_parent_valid', c );
	strout = xlate('? Stateflow Object Name <invalid parent>');
else
   curNameString = rgsf('get_parent_type', c );
	strout = sprintf('Stateflow Name (%s)', curNameString );
end