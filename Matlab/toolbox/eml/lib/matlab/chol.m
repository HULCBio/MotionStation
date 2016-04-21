function [A,p] = chol(A)
% Embedded MATLAB Library function.
%
% Limitations:
%    1) Does not support CHOL with two output arguments
%    2) May factor matrices that MATLAB will not.
%    3) May fail to factor matrices that MATLAB will factor.

% $INCLUDE(DOC) toolbox\matlab\matfun\chol.m$
% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.1.4.1 $  $Date: 2004/04/10 23:15:01 $

% Translated from LAPACK functions zpotf2.f/cpotf2.f/dpotf2.f/spotf2.f

eml_assert(isfloat(A),['Function ''chol'' is not defined for values of class ''' class(A) '''.']);
eml_assert(nargin == 1, 'Not enough input arguments.');
eml_assert(size(A,1) == size(A,2), 'Matrix must be square.');
eml_assert(nargout<2,'Embedded MATLAB''s CHOL function does not support the two output version.');

if isempty(A)
    return;
end

n = size(A,1);
A = triu(A);
p = 0;
for j = 1 : n
    
    %s = real(A(j,j)) - A(1:j-1,j)' * A(1:j-1,j);
    t = cast(0,class(A));
    if j>1
        for k = 1 : j-1
            akj = A(k,j);
            % t = t + real(conj(A(k,j)) * A(k,j));
            t = t + real(akj)*real(akj) + imag(akj)*imag(akj);
        end
    end
    ajj = real(A(j,j)) - t;

    if ajj <= 0
        A(j,j) = ajj;
        p=j;
        if nargout <= 1
            error('Not positive definite(2).');
        end
        return;
    end

    ajj = sqrt(ajj);
    A(j,j) = ajj;
    
    if j < n        
        %A(j,j+1:n) = A(j,j+1:n) - A(1:j-1,j)'*A(1:j-1,j+1:n);
        for k = j+1:n
            if isreal(A)
                temp = cast(0,class(A));
                if j > 1
                    for w = 1 : j-1
                        temp = temp + A(w,j) * A(w,k);
                    end
                end
                A(j,k) = (A(j,k) - temp)/ajj;
            else
                tre = cast(0,class(A));
                tim = cast(0,class(A));
                tim2 = cast(0,class(A));
                if j > 1
                    for w = 1 : j-1
                        awj = A(w,j);
                        awk = A(w,k);
                        tre = tre + real(awj) * real(awk) + imag(awj) * imag(awk);
                        tim = tim + real(awj) * imag(awk);
                        tim2 = tim2 + imag(awj) * real(awk);
                    end
                end
                A(j,k) = (A(j,k) - complex(tre,tim - tim2))/ajj;
            end                                    
        end                
    end
end

function B = cast(A,cls)

switch cls
    case 'double', 
        B = double(A);
    case 'single',
        B = single(A);
    otherwise,
        eml_assert(false,'error','Internal error: unexpected class.');
end
