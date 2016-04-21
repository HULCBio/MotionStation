function B = subsref(A,index)
%SUBSREF Subscripted reference for Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:25 $ 

switch index.type
case '()',
    MA = A.Matrix;
    B = laurmat(MA(index.subs{:}));
    
case '{}',
    B = A.Matrix(index.subs{:});
    if length(B)<2
        B = B{:};
    end
    
case '.',
    if isequal(index.subs,'Matrix')
       B = A.Matrix;
    else
       error('Invalid field name.')
    end
end
