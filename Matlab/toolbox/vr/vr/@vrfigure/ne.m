function x = ne(A, B)
%NE True for nonequal VRFIGURE handles.
%   NE(A,B) tests for nonequality of VRFIGURE handles.
%   See VRFIGURE/EQ for detailed description.

%   Copyright 1998-2002 HUMUSOFT s.r.o. and The MathWorks, Inc.
%   $Revision: 1.1.2.1 $ $Date: 2004/04/06 01:11:09 $ $Author: batserve $

x = ~eq(A, B);
