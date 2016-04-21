function out=execute(c)
%EXECUTE creates report output

% Copyright 1994-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/10 16:54:54 $

blockList=getobjects(c,logical(0));

out=loopobject(c,...
   'Block',...
   blockList);
