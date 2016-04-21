% FITSREAD    FITSファイルからデータを読み込む
%
% DATA = FITSREAD(FILENAME) は、FITS(Flexible Image Transport System)
% ファイル FILENAME の基本データからデータを読み込みます。識別できない
% データ値は、NaN で置き換えられます。数値データは、勾配とインタセプト
% 値でスケーリングされ、常に倍精度で戻されます。
%   
% DATA = FITSREAD(FILENAME,OPTIONS) は、OPTIONS で指定されたオプ
% ションに従って、FITSファイルからデータを読みます。使用可能なオプションは、
% つぎのものです。
%   
%  EXTNAME      EXTNAME は、基本データ配列、ASCII table extension, 
%               Binary table extension, Image extension, Unknown 
%               extension からデータを読み込むため、'Primary', 'Table',
%               'BinTable', 'Image', 'Unknown' のいずれかを設定します。
%               複数の拡張子を指定した場合は、ファイル内で最初に見つかる
%               ものが読み込まれます。ASCIIと Binary table extension に対する
%               DATA は、フィールド数のセル配列により1になります。
%               FITSファイルの内容は、FITSINFO で出力される構造体の 
%               Content フィールドに位置します。
%   
% EXTNAME,IDX  複数の拡張タイプを指定した場合に IDX 番目のものが読み
%					 込まれることを除いて、EXTNAME と同じです。
%   
% 'Raw'      ファイルから読み込まれる DATA は、スケーリングされず、未定義の
%             値はNaN で置き換えられません。DATA は、ファイルの中に格納
%			  されるものと同じクラスになります。
%
% 参考：FITSINFO.



%   Copyright  1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:42 $
