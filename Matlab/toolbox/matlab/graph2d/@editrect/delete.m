function delete(A)
%EDITRECT/DELETE Delete editrect object
%   This file is an internal helper function for plot annotation.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/01/15 21:12:25 $

delete(A.Objects);
delete(A.editline);
