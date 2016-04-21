% MEMBRANE   MATLABのロゴの出力
%
% L = MEMBRANE(k)は、k < =  12のとき、L型の膜のk次の固有関数です。最初の
% 3個の固有関数は、MathWorksの種々の出版物の表示になっています。
%
% MEMBRANE(k)は、出力パラメータなしでは、k次の固有関数をプロットします。
% 
% MEMBRANEは、入力および出力パラメータなしでは、MEMBRANE(1)をプロットし
% ます。
%
% L = MEMBRANE(k,m,n,np)は、メッシュと精度のパラメータも設定します。
%
%   kは、固有関数のインデックスで、デフォルトは1です。
%   mは、境界の1/3にある点の数です。出力のサイズは、2*m+1行2*m+1列です。
%         デフォルトは、m = 15です。
%   nは、和を計算する項数です。デフォルトは、n = min(m,9)です。
%   npは、部分和を計算する項数です。デフォルトは、np = min(n,2)です。
%   np = nのとき、固有関数は境界でゼロに近付きます。
%   np = 2のように、np < nのときは、境界はありません。
%



%   Out-of-date reference:
%       Fox, Henrici & Moler, SIAM J. Numer. Anal. 4, 1967, pp. 89-102.
%   Cleve Moler 4-21-85, 7-21-87, 6-30-91, 6-17-92;
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:49:03 $