function strout=outlinestring(c)
%OUTLINESTRING display short component description
%   OUTLINESTRING(cobj) Returns a terse description of the
%   component in the setup file editor report outline.  The
%   default outlinestring method returns the component's name.

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:18 $

strout = sprintf('Stateflow %s', xlate(c.att.typeString) );
% see if we have invalid parent
if ~rgsf( 'is_parent_valid', c );
	strout = sprintf( '? %s <invalid parent>',strout);
end