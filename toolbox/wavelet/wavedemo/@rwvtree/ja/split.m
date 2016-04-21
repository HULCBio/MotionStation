%SPLIT   終点のノードデータを分離します(分解します)
%   TNDATA = SPLIT(T,N,X) は、ウェーブレットツリー T の終点のノード N で%   結合されたデータ X を分解します。
%
%   TNDATA は、TNDATA{k} が N の子オブジェクトで、k 番目に結合されるデー%   タを含むような、(ORDER x 1) のセル配列です。
%
%   この手法は、1次元(あるいは2次元)データに対する DWT(あるいは DWT2) を%   用いています。
%
%   この手法は、WTREE メソッド で多重定義されています。

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 09-Sep-1999.


%   Copyright 1995-2002 The MathWorks, Inc.
