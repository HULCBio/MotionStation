function out=execute(c)
%EXECUTE creates report output

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:19:34 $

[blockList, badList]=getobjects(c,logical(0));
if ~isempty( badList ),
   warn_bad_blocks( c, badList );
end

out=loopobject(c,...
   'Block',...
   blockList);
