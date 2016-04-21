function val = HilBlkGetParam(blk,paramName)

UDATA = get_param(blk,'UserData');
val = eval(['UDATA.' paramName]);

% Copyright 2003-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/08 20:44:23 $
