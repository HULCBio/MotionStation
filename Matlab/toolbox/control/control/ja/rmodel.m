% RMODEL   ランダムで安定な連続 n 次元テストモデルを作成
%
% [NUM,DEN] = RMODEL(N) は、N 次の SISO 伝達関数モデルを作成します。
% [NUM,DEN] = RMODEL(N,P) は、N 次の単入力、P 出力の伝達関数モデルを
% 作成します。
% 
% [A,B,C,D] = RMODEL(N) は、N 次の SISO 状態空間モデルを作成します。
% [A,B,C,D] = RMODEL(N,P,M) は、N 次の P 出力、M 入力の状態空間モデルを
% 作成します。
%
% 参考：   DRMODEL.


%   Clay M. Thompson 1-22-91
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:04:47 $
