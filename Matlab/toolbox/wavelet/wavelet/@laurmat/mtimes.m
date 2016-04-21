function P = mtimes(A,B)
%MTIMES Laurent matrices multiplication.
%   P = MTIMES(A,B) returns a Laurent matrix which is
%   the product of the two Laurent matrices A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/13 00:39:18 $ 

if isnumeric(A)
    if length(A)==1 , A = A*eye(size(B.Matrix,1)); end
    A = laurmat(A);
elseif isnumeric(B)
    if length(B)==1 , B = B*eye(size(A.Matrix,2)); end
    B = laurmat(B);
end

MA = A.Matrix;
MB = B.Matrix;
[rA,cA] = size(MA);
[rB,cB] = size(MB);
if cA~=rB
    msg = sprintf('Error using ==> *\nInner matrix dimensions must agree.');
    error(msg)
end
MP = cell(rA,cB);
for i=1:rA
    for j=1:cB
        S = laurpoly(0,0);
        for k=1:cA
            S = S+MA{i,k}*MB{k,j};
        end
        MP{i,j} = S;
    end
end
P = laurmat(MP);
