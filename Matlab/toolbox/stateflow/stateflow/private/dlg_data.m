function userData = dlg_data( refObject, refCorner, offset, widthScale, heightScale, callback, revert )
% DLGDATA forms userdata for property dialogs.

%   E.Mehran Mestchian
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.10.2.1 $  $Date: 2004/04/15 00:56:50 $

	userData.geom.refObject = refObject;
	userData.geom.refCorner = refCorner;
	userData.geom.offset = offset;
	userData.geom.heightScale = 0;
	userData.geom.widthScale = 0;
	if nargin>3
		userData.geom.heightScale = heightScale;
	   if nargin>4
			userData.geom.widthScale = widthScale;
	      if nargin>5
	         userData.callback = callback;
	         if nargin>6
	            userData.revertBuffer = revert;
	         end
	      end
	   end
	end






