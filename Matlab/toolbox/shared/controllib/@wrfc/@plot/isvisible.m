function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @plot object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:27:25 $
boo = strcmp(this.Visible,'on') && strcmp(this.AxesGrid.Parent.Visible,'on');