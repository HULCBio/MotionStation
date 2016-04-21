% DRMODEL   ランダムな安定離散 n 次のテスト用モデルを作成
% 
% [NUM,DEN] = DRMODEL(N) は、N 次の SISO 伝達関数モデルを作成します。
% [NUM,DEN] = DRMODEL(N,P) は、N 次の単入力、P 個の出力の伝達関数モデル
% を作成します。
% [A,B,C,D] = DRMODEL(N) は、N 次の SISO 状態空間モデルを作成します。
% [A,B,C,D] = DRMODEL(N,P,M) は、N 次で、P 個の出力、M 個の入力をもつ
% 状態空間モデルを作成します。
%    
% 参考：RMODEL.


%   Clay M. Thompson  12-27-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:05 $
