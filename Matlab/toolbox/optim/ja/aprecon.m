% APRECON   最小二乗問題に対する範囲付き前提条件関数を生成
%
% [RPCMTX,PPVEC] = APRECON(DM,DG,A,UPPERBW) は、行列 M = DM*(A'*A)*DM + DG 
% に対して、RPCMTX'*RPCMTX が前提条件になるようなスパースな特異でない
% 上三角行列 RPCMTX を作成します。ここで、DM は、正の対角行列、DG は、
% 非負の対角行列、A は、列数よりも行数のほうが多いスパース長方形行列です。
% PPVEC は、関連した置換(行)ベクトルで、UPPERBW は、RPCMTX の上限帯域幅
% を設定します。


%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7 $  $Date: 2003/05/01 13:00:35 $
