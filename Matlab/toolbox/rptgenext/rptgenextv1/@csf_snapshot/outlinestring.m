function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   OUTLINESTRING(cobj) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:33 $

info=getinfo(c);
strout=xlate(info.Name);

parent = rgsf( 'get_sf_parent', c );
if ~rgsf( 'is_parent_valid', c );
	strout = xlate('? Stateflow Snapshot <invalid parent>');
else
	strout = sprintf('Stateflow Snapshot (%s)', parent.att.typeString );
end