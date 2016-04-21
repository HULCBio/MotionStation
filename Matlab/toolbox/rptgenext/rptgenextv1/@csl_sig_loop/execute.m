function out=execute(c)
%EXECUTE creates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:23 $

sigList=getobjects(c,logical(0));
out=loopobject(c,'Signal',sigList);


