function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @axesgroup object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:17:14 $
boo = (strcmp(this.Visible,'on') && strcmp(this.Parent.Visible,'on'));