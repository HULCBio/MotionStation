function isnoteq=ne(arg1, arg2)
%NE ~=  Not equal for timer objects.
%
%    C = NE(A,B) does element by element comparisons between timer objects
%    A and B and returns a logical indicating if they refer to different 
%    timer objects. 
%
%    Note: NE is automatically called for the syntax 'A ~= B'.
%
%    See also TIMER/EQ, TIMER/ISEQUAL
%

%    RDD 11-20-2001
%    Copyright 2001-2002 The MathWorks, Inc. 
%    $Revision: 1.2 $  $Date: 2002/03/14 14:34:47 $

isnoteq = ~ eq(arg1,arg2);