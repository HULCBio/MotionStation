% RSS   ランダムで、安定な連続時間状態空間モデルを作成
%
%
% SYS = RSS(N) は、N 次の SISO 状態空間モデル SYS を作成します。
%
% SYS = RSS(N,P) は、P 出力、単入力をもつ N 次のモデルを作成します。
%
% SYS = RSS(N,P,M) は、P 出力、M 入力をもつ N 次のモデルを作成します。
%
% SYS = RSS(N,P,M,S1,...,Sk) は、N 状態数、P 出力、M 入力をもつ状態空間モデル
% の S1 X S2 X ... X Sk 配列を作成します。
%
% ランダムな TF または ZPK モデルを作成する場合、結果の SYS を関数 TFまたは
% ZPK で使用する適切なモデル型に変換します。
%
% 参考 : DRSS, TF, ZPK.


% Copyright 1986-2002 The MathWorks, Inc.
