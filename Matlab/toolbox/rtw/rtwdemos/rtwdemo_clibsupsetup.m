% Copyright 1994-2004 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2004/02/11 19:36:13 $

function rtwdemo_clibsupsetup(val) 

cs = getActiveConfigSet(bdroot);
set_param(cs,'GenFloatMathFcnCalls',val);
set_param(bdroot,'dirty','off');
