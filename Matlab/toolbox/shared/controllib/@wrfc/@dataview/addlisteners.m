function addlisteners(this, L)
%ADDLISTENERS  Adds new listeners to listener set.

%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:26:57 $
this.Listeners = [this.Listeners; L];
