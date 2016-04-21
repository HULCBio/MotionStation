% [p,q12,r12,fail] = hinffi_t(p,ncon)
%
% 式を満たすように、行列d12をスケーリングし、全情報の場合についてランク
% の条件をチェックします。
%
% written:	Gary Balas  July, 1990.
%
% 全情報の場合:
%
% p  =  | ap  | b1   b2  |
%       | ---------------|
%       | c1  | d11  d12 |
%
% c2, d21, d22を仮定した場合:
%       | [I] | [0]  [0] |
%       | [0] | [I]  [0] |

%   $Revision: 1.6.2.2 $  $Date: 2004/03/10 21:31:01 $
%   Copyright 1991-2002 by MUSYN Inc. and The MathWorks, Inc. 
