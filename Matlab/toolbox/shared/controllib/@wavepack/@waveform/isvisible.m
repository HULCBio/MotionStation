function boo = isvisible(this)
%ISVISIBLE  Determines effective visibility of @waveform object.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:14 $
boo = strcmp(this.Visible,'on') && isvisible(this.Parent);