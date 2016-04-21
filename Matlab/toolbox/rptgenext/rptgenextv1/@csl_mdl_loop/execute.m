function out=execute(c)
%EXECUTE generates report contents

%   Copyright 1997-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/15 00:20:06 $

mdlStruct=getfield(c.att,[c.att.LoopType 'Models']);
mdlStruct=loopmodel(c,mdlStruct);
out=loopobject(c,'Model',mdlStruct);

