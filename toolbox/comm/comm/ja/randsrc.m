% RANDSRC   前もって設定したアルファベットを使って、ランダム行列を作成
%
% OUT = RANDSRC は、"-1"と"1"を同じ確率で作成します。
%
% OUT = RANDSRC(M) は、M 行 M 列のランダム双極行列を作成します。"-1"と
% "1"は同じ確率で発生します。
%    
% OUT = RANDSRC(M,N) は、M 行 N 列のランダム双極行列を作成します。"-1"と
% "1"は同じ確率で発生します。
%
% OUT = RANDSRC(M,N,ALPHABET) は、ALPHABET で指定されるアルファベットを
% 使って、M 行 N 列のランダム行列を作成します。
%
% ALPHABET は、行ベクトル、または、2行の行列のいずれかです。:
% 行ベクトル：ALPHABET が行ベクトルの場合、ALHABET の内容に従って、出力
%             可能な要素 RANDSRC を定義します。ALPHABET の要素は、実数
%             でも複素数でも構いません。ALPHABET のすべての要素が同じ値の
%             場合、確率分布は一様になります。
% 2行行列   ：ALPHABET が2行の行列の場合、1行目は（上のような）可能な
%             出力を定義します。ALPHABET の2行目は、各々対応する要素の
%             確率を指定します。2行目の要素全ての和は、1にならなければ
%             なりません。
%
% OUT = RANDSRC(M,N,ALPHABET,STATE) は RAND の状態を STATE にリセットします。
%
%   例題:
%   >> out = randsrc(2,3)              >> out = randsrc(2,3,[3 4])
%   out =                              out =
%        1    -1    -1                      4     4     3
%       -1    -1     1                      3     3     4
%
%   >> out = randsrc(2,3,[3 4;0 1])    >> out = randsrc(2,3,[3 4;0.8 0.2])
%   out =                              out =
%        4     4     4                      3     3     3
%        4     4     4                      3     4     3
%
% 参考:   RAND, RANDINT, RANDERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.5.4.1 $  $Date: 2003/06/23 04:35:07 $
