function constellation = idealQAMConst(M)
%IDEALQAMCONST Find ideal constellation points for M-ary QAM
%   CONSTELLATION = IDEALQAMCONST(M) returns a vector of complex numbers
%   corresponding to the ideal signalling points for M-ary QAM.  The functions assumes
%   that the I and Q QAM signalling points are 1, 3, 5, etc., because the received
%   QAM signal is collapsed into the first quadrant.
%
%   See also SQUAREQAMCONST.

%   Copyright 1996-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/02/14 20:51:03 $

% Check that M is a power of 2
if (~isreal(M) || round(log2(M))~=log2(M) || log2(M)<2 )
    error('comm:idealQAMConst:Mpow2', 'log2(M) must be a positive integer greater than 1.')
end

constellation = [];

if ((round(sqrt(M))^2) == (sqrt(M))^2)    % Square QAM
    for iIndex = 1 : 2 : sqrt(M) - 1
        for qIndex = 1 : 2 : sqrt(M) - 1
            constellation = [constellation; iIndex+j*qIndex];
        end
    end
elseif (M==8)
    constellation = [1+j; 3+j];
else              % Cross constellation
    % Find the parameters of the cross constellation.  bigLen is the number of signal
    % points along an I or Q axis of a square constellation that encompasses the
    % cross constellation, and smallLen is the number of signal points along an I or
    % Q axis of the "square" of signal points that is removed from the large square
    % constellation to make the cross
    smallLen = 1;
    for bigLen = ceil(sqrt(M)) : floor(sqrt(2*M))
        while (bigLen > sqrt(M + 4*smallLen.^2))
            smallLen = smallLen + 1;
        end
        if (bigLen == sqrt(M + 4*smallLen.^2))
            break;
        else          % bigLen < target
            bigLen = bigLen + 1;
            smallLen = 1;
        end
    end
    
    for iIndex = 1 : 2 : bigLen-1
        for qIndex = 1 : 2 : bigLen-1
            if (iIndex < bigLen-(2*smallLen-1) || qIndex < bigLen-(2*smallLen-1))
                constellation = [constellation; iIndex+j*qIndex];
            end
        end
    end
end

return;

% EOF -- idealQAMConst