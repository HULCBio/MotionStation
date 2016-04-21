% [mu,D,G]=mubnd(M,delta,target)
%
% 行列Mとノルム有界不確かさDELTAに対して、混合μ構造化特異値に対する上界
% を計算します。
%
% DELTAの各々のブロックDjが、djで与えられるノルムに近づいても、
% 
%              MU * || Dj ||  <  dj
% 
% である限りは、行列I - M * DELTAは、逆数が存在します。
%
% TARGETが設定された場合、MUの最小化は、MU <= TARGET(デフォルト = 1e-3)
% となると、すぐに終了します。MUBNDは、最適D,Gスケーリング行列も出力しま
% す。
%
% 参考：    MUSTAB, MUPERF.



% Copyright 1995-2002 The MathWorks, Inc. 
