%SPLIT   終点のノードデータを分離します(分解します)
%   TNDATA = SPLIT(T,N,X) は、ウェーブレットツリー T の終点のノード N で%   結合されたデータ X を分解します。
%
%   TNDATA は、TNDATA{k} が N の子オブジェクトで、k 番目に結合されるデー%   タを含むような、(ORDER x 1) のセル配列です。
%
%   1次元(または2次元)データに対する DWT(または DWT2)を用います。
%
%   この手法は、DTREE メソッドで多重定義されています。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Oct-1998.


%   Copyright 1995-2002 The MathWorks, Inc.
