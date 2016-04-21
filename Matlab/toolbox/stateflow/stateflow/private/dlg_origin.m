function origin = dlg_origin(refObject,refCorner,offset)
%ORIGIN = DLG_ORIGIN( REFOBJECT, REFCORNER, OFFSET )

%   E.Mehran Mestchian January 1997
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.11.2.1 $  $Date: 2004/04/15 00:57:05 $

   refPos = get(refObject,'Position');
   if strcmp(get(refObject,'type'),'figure')
      refPos(1:2)=[0 0];
   end
	switch(refCorner)
		case('BL'),	origin = refPos(1:2) + offset;
		case('BR'), origin = refPos(1:2) + offset + [refPos(3) 0];
		case('TL'), origin = refPos(1:2) + offset + [0 refPos(4)];
		case('TR'), origin = refPos(1:2) + offset + refPos(3:4);
		otherwise, error('Bad refCorner.');
	end

