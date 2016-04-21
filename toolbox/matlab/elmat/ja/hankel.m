% HANKEL   Hankel行列
% 
% HANKEL(C)は、最初の列がCで、最初の反対角要素より下側の要素がゼロである、
% 正方Hankel行列を出力します。
%
% HANKEL(C,R)は、最初の列がCで、最後の行がRである、Hankel行列を出力しま
% す。 
%
% Hankel行列は、対称で反対角要素が一定の行列で、各要素の値はH(i,j) = 
% P(i+j-1)です。ここで、P = [C R(2:END)]は、Hankel行列を完全に決定します。
%
% 参考：TOEPLITZ.


%   J.N. Little 4-22-87
%   Revised 1-28-88 JNL
%   Revised 2-25-95 Jim McClellan 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:12 $
