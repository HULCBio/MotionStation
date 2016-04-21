%SPLIT   終点のノードデータを分離します(分解します)
%   TNDATA = SPLIT(T,N,X) は、ウェーブレットツリー T の末端ノード N に関%   連するデータ X を分解します。
%
%   TNDATA は、TDATA{k} が N の k 番目の関連データを含むような 
%   (ORDER x 1) のセル配列です。
%
%   1次元データに対する DWT を用いています。
%
%   この手法は、DTREE メソッド で多重定義されています。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.



%   Copyright 1995-2002 The MathWorks, Inc.
