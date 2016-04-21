function boo = isreal(sys)
%ISREAL   Checks if the zero/pole/gain model SYS is real-valued.

%      Author: P. Gahinet
%      Copyright 1986-2003 The MathWorks, Inc.
%      $Revision: 1.4.4.2 $  $Date: 2004/04/10 23:13:50 $

boo = isreal(sys.k);
if boo
    % Further check that all Zs and Ps are complex conjugate
    for ct=1:prod(size(sys.k))
        if ~isconjugate(sys.z{ct}) | ~isconjugate(sys.p{ct})
            boo = false;
            break
        end
    end
end