function out=execute(c)
%EXECUTE generates report contents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:46 $

sysList=getobjects(c,logical(0));

out=loopobject(c,...
   'System',...
   sysList);

