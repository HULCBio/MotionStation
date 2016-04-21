function strout=outlinestring(c)
%OUTLINESTRING returns a short description of the component

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:18:54 $

if ~rgsf( 'is_parent_valid', c );
	strout = xlate('? Stateflow Linking Anchor <invalid parent>');
else
   strout=('Stateflow Linking Anchor');
end