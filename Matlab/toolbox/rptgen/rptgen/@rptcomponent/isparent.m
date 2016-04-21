function true=isparent(c)
%ISPARENT returns true if the component accepts subcomponents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:11:09 $

cinfo=getinfo(c);
true=cinfo.ValidChildren{1};