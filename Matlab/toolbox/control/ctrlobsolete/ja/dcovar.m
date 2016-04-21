% DCOVAR   白色ノイズに対する離散システムの共分散応答
%
% [P,Q] = DCOVAR(A,B,C,D,W) は、離散状態空間システム (A, B, C, D)へ 強度 
% W のGauss白色ノイズを入力した場合の共分散応答を計算します。
%
%    E[w(k)w(n)'] = W delta(k,n)
%
% ここで、delta(k, n) は、Kronecker デルタです。P は出力、Q は、状態
% 共分散応答です。
%
%    P = E[yy'];  Q = E[xx'];
%
% P = DCOVAR(NUM,DEN,W) は、多項式伝達関数システムの出力共分散応答を
% 計算します。W は、入力ノイズの強度です。
%
% 参考 : COVAR, LYAP, DLYAP.


%   Clay M. Thompson  7-5-90
%       Revised by Wes Wang 8-5-92
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/06/26 16:07:36 $
