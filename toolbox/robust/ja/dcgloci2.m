% DCGLOCI2  離散の特性ゲイン/位相周波数応答
%
% [CG,PH] = DCGLOCI2(SS_, CGTYPE, W, Ts) 、または、
% [CG,PH] = DCGLOCI2(A, B, C, D, CGTYPE, W, Ts) は、
%                           -1
% 周波数応答 G(z) = C(zI - A)  B + D をもつ Ts 秒でサンプリングされた離
% 散システム
% 
%                x(k+1) = Ax(k) + Bu(k)
%                y(k) = Cx(k) + Du(k)
% 
% に対する特性ゲイン/位相値を含む行列 G とPH を計算します。
% 
% DCGLOCI は、"cgtype" の値に依存して、固有値の計算を行ないます。
%
%     cgtype = 1   ----   char( G(z) )
%     cgtype = 2   ----   char( inv( G(z) ) )
%     cgtype = 3   ----   char( I + G(z) )
%     cgtype = 4   ----   char( I + inv( G(z) )
%
% ベクトル W は、周波数応答を計算する周波数を設定するものです。行列 CG 
% と PH の行は、降順に特性ゲイン/位相に対応します。
%

% Copyright 1988-2002 The MathWorks, Inc. 
