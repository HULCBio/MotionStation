% SV = DSIGMA(A, B, C, D, TY, W, T)、または、
% SV = DSIGMA(SS_,TY,W,Ts) は、TY の値に依存して、つぎのシステムの離散時間
% 特異値周波数応答を含む行列 SV を出力します。
% 
%      TY = 1   ----   G(exp(jwT))
%      TY = 2   ----   inv(G(exp(jwT))
%      TY = 3   ----   I + G(exp(jwT))
%      TY = 4   ----   I + inv(G(exp(jwT)))
% ここで、G(z) は、離散時間システムの周波数応答です。
%            x[n+1] = Ax[n] + Bu[n]
%              y[n] = Cx[n] + Du[n].
%
% SS_ は、コマンド SS_=MKSYS(A,B,C,D) で作成される状態空間システムです。W 
% は特異値を計算する実数周波数を要素とするベクトルで、T はサンプリング間隔
% です。
%
% 前のシンタックスは、ROBUST CONTROL TOOLBOX がインストールされている場合
% に使用可能になります。そして、関数 DSIGMA のドキュメントに説明されている
% 別のシンタックスも使用可能です。%
% 
% 参考： DSIGMA, RSIGMA, SIGMA

% Copyright 1988-2002 The MathWorks, Inc. 
