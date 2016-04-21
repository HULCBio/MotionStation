function delete(A)
%ARROWLINE/DELETE Delete arrowline
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:11:21 $

delete(A.arrowhead);
delete(A.line);

delete(A.editline);
