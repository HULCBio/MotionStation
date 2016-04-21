% IM2FRAME   インデックス付きイメージをムービーフレームへ変換
% 
% F = IM2FRAME(X,MAP) は、インデックス付きイメージXと関連するカラーマップ
% MAP を、ムービーフレーム F に変換します。X がTrueColor (MxNx3)イメージの
% 場合、MAP はオプションになり、影響を与えません。
%
%     M(1) = im2frame(X1,map);
%     M(2) = im2frame(X2,map);
%      ...
%     M(n) = im2frame(Xn,map);
%     movie(M)
%
% F = IM2FRAME(X) は、インデックス付きイメージ X を、現在のカラーマップを
% 使ってムービーフレーム F に変換します。
%     
% 参考：FRAME2IM, MOVIE, CAPTURE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2004/04/28 02:05:12 $
%   Built-in function.
