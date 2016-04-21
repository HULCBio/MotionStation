% CGLOCI2   連続系の特性ゲイン/位相周波数応答
%
% [CG,PH] = CGLOCI2(SS_,cgtype,W)、または、
% [CG,PH] = CGLOCI2(A, B, C, D, CGTYPE, W) は、周波数応答
%                          -1
%      G(jw) = C(jwI - A)  B + D.
% 
% をもつ、つぎのシステム
%                .
%                x = Ax + Bu
%                y = Cx + Du
% 
% の特性ゲイン/位相値を含む行列 CG と PH を計算します。
%
% CGLOCI は、"cgtype"の値に依存して、つぎのいずれかの固有値を計算します。
%
%     cgtype = 1   ----   G(jw)
%     cgtype = 2   ----   inv(G(jw))
%     cgtype = 3   ----   I + G(jw)
%     cgtype = 4   ----   I + inv(G(jw))
%
% ベクトル W は、周波数応答を計算する周波数点からなります。行列 CG と 
% PH は、降順に、特性ゲインと位相を行に出力します。

% Copyright 1988-2002 The MathWorks, Inc. 
