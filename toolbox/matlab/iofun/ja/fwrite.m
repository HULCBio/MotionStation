% FWRITE   バイナリデータをファイルに書き出します。
% 
% COUNT = FWRITE(FID,A,PRECISION) は、行列 A の要素を指定したファイ
% ルに、MATLAB値の指定した精度で変換して書き出します。データは、列順
% に書き出されます。COUNTは、正常に書き出された要素数です。
%
% FID は、FOPEN から得られる整数のファイル識別子で、標準出力に対して
% は1、標準エラーに対しては2です。
% 
% PRECISION は、結果の型とサイズを制御します。FREAD で使用できる精度
% のリストを参照してください。'bitN' または 'ubitN' のどちらかが PRECISION 
% に対して使われた場合は、A の範囲外の値は、すべてのビットがオンである
% 状態の値として表されます。
%
% COUNT = FWRITE(FID,A,PRECISION,SKIP) は、各 PRECISION 値が書かれ
% る前にスキップするバイト数を設定するオプションの SKIP 引数を含んで
% います。SKIP引数が設定されている場合は、FWRITE は、A の要素すべてが
% 書かれるまでスキップして値を書き、またスキップして他の値を書く、等々に
% なります。PRECISION が 'bitN' または 'ubitN' のようなビットフォーマット
% の場合は、SKIP はビット単位で設定されます。これは、固定長のレコード
% から非連続のフィールドにデータを挿入するのに有効です。
%
% たとえば、
%
%     fid = fopen('magic5.bin','wb')
%     fwrite(fid,magic(5),'integer*4')
%
% は、4バイトの整数として格納された、5行5列の魔方陣行列の25要素を含む、
% 100バイトのバイナリファイルを作成します。
%
% 参考：FREAD, FPRINTF, SAVE, DIARY.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:58:16 $
%   Built-in function.
