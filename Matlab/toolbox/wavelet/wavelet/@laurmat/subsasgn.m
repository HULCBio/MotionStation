function M = subsasgn(A,index,InputVAL)
%SUBSASGN Subscripted assignment for Laurent matrix.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 26-Apr-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:24 $ 

switch index.type
case '()',   % InputVAL is an lm object or a number
    MA = A.Matrix;
    if isnumeric(InputVAL)
        if length(InputVAL)==1
            nbR = length(index.subs{1});
            nbC = length(index.subs{2});
            InputVAL = InputVAL*ones(nbR,nbC);
        end
        InputVAL = laurmat(InputVAL);
    end
    if isa(InputVAL,'laurmat')  
        MA(index.subs{:}) = InputVAL.Matrix;
    else
        error('Invalid argument value.')
    end
    M = laurmat(MA);
        
case '{}',   % InputVAL is an lp object or a number
    MA = A.Matrix;
    if isa(InputVAL,'laurpoly')  
        MA{index.subs{:}} = InputVAL;
    elseif isnumeric(InputVAL) && length(InputVAL)==1
        MA{index.subs{:}} = laurpoly(InputVAL,0);
    else
        error('Invalid argument value.')
    end
    M = laurmat(MA);
    
case '.',    % InputVAL is a cell array of lp objects or of numbers.
    if isequal(index.subs,'Matrix')
        M = laurmat(InputVAL);
    else
        error('Invalid field name.')
    end
end
