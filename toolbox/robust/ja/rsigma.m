% SV = SIGMA(A, B, C, D, TY, W)、または、
% SV = SIGMA(SS_,TY,W) は、TY の値に依存して、つぎのシステムの特異値周波数
% 応答を含む行列 SV を出力します。
% 
%      TY = 1   ----   G(jw)
%      TY = 2   ----   inv(G(jw))
%      TY = 3   ----   I + G(jw)
%      TY = 4   ----   I + inv(G(jw))
% G(jw) は、システムの周波数応答です。
%                 .
%                 x = Ax + Bu
%                 y = Cx + Du.
%
% SS_ は、コマンド SS_ = MKSYS(A,B,C,D) で作成される状態空間システムです。
% W は実数周波数を要素とするベクトルです。
%
% 前のシンタックスは、ROBUST CONTROL TOOLBOX がインストールされている場合
% に使用可能になります。そして、関数 SIGMA のドキュメントに説明されている
% 別のシンタックスも使用可能です。
%
% 参考： SIGMA, DSIGMA, RDSIGMA

% Copyright 1988-2002 The MathWorks, Inc. 
