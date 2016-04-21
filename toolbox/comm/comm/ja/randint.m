% RANDINT   一様分布する乱数整数の行列の作成
%
% OUT = RANDINT は、等しい確率で、"0"、または、"1"を生成します。
%
% OUT = RANDINT(M) は、M 行 M 列のランダムなバイナリ行列を作成します。
% "0" と "1" は、同じ確率で生じます。
%
% OUT = RANDINT(M,N) は、M 行 N 列のランダムなバイナリ行列を作成します。
% "0" と "1" は、同じ確率で生じます。
%
% OUT = RANDINT(M,N,RANGE) は、M 行 N 列のランダムな整数を作成します。
%
% RANGE は、スカラ、または、2要素ベクトルのいずれかです。:
% スカラ   : RANGE が正の整数の場合、出力整数の範囲は [0, RANGE-1] と
%            なります。RANGE が負の整数の場合、出力整数の範囲は 
%            [RANGE+1, 0] になります。
% ベクトル : RANGE が2要素ベクトルの場合、出力整数範囲は
%            [RANGE(1), RANGE(2)]になります。
%
% OUT = RANDINT(M,N,RANGE,STATE) は、RAND の状態を STATE にリセットします。
%
% 例題：
%    >> out = randint(2,3)               >> out = randint(2,3,4)  
%    out =                              out =                 
%         0     0     1                      1     0     3
%         1     0     1                      2     3     1
%                                                                  
%    >> out = randint(2,3,-4)            >> out = randint(2,3,[-2 2])  
%    out =                              out =                   
%        -3    -1    -2                     -1     0    -2
%        -2     0     0                      1     2     1
%
% 参考： RAND, RANDSRC, RANDERR.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.6.4.1 $  $Date: 2003/06/23 04:35:06 $
