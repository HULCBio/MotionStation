function result = ispc

% ISPC	 Determine if computer is a PCWIN

% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.7.2.1 $  $Date: 2004/04/15 00:58:34 $

result=strncmp(computer,'PC',2);
