function doclick(A)
%DOCLICK Processes ButtonDown on ML objects.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 04:07:27 $
%   J.H. Roh & B.A. Jones 4-25-97.

ud = getscribeobjectdata(A);
p  = ud.HandleStore;

doclick(p)
