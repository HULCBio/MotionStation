% RANDN   正規分布の乱数
% 
% RANDN(N)は、平均が0で分散が1、標準偏差が1の正規分布をする乱数を要素と
% するN行N列の行列を出力します。
% RANDN(M,N)とRANDN([M,N])は、乱数を要素とするM行N列の行列を出力します。
% RANDN(M,N,P,...)またはRANDN([M,N,P...])は、乱数を要素とする配列を出力
% します。
% RANDN自身では、実行するたびに異なるスカラ値を出力します。RANDN(SIZE(A))
% は、Aと同じサイズです。
%
% RANDNは、疑似乱数を生成します。生成された数列は、発生器の状態で決定さ
% れます。MATLABは、起動時に状態をリセットするので、生成した数列は、状態
% を変更しない限り同じである可能性があります。
% 
% S = RANDN('state')は、正規分布乱数発生器の現在の状態を含む2要素のベク
% トルを出力します。RANDN('state',S)は、状態をSにリセットします。
% RANDN('state',0)は、発生器を初期状態にリセットします。
% 整数Jに対し、RANDN('state',J)は、発生器をJ番目の状態にリセットします。
% RANDN('state',sum(100*clock))は、実行ごとに異なる状態にリセットします。
%
% MATLAB Version 4.xは、シングルシードの乱数発生器を使っていました。
% RANDN('seed',0)とRANDN('seed',J)は、MATLAB 4の発生器を使います。
% RANDN('seed')は、MATLAB 4の正規分布乱数発生器の現在のシードを出力し
% ます。
% RANDN('state',J)とRANDN('state',S)は、MATLAB 5の発生器を使います。
% 
% 参考：RAND, SPRAND, SPRANDN, RANDPERM.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:51:42 $
%   Built-in function.
