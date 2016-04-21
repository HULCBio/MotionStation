% MULTIBANDREAD   バイナリファイルからband-interleavedデータの読み込み
%
% X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,
%                  OFFSET,INTERLEAVE,BYTEORDER) 
% は、バイナリファイル FILENAME から band-sequential (BSQ)、
% band-interleaved-by-line (BIL)、またはband-interleaved-by-pixel (BIP)
%  データを読み込みます。X は、1つのバンドのみ読み込む場合は2次元で、
% それ以外は3次元になります。X は、デフォルトで倍精度のデータタイプの
% 配列として出力されます。異なるデータタイプにデータを写像するために、
% PRECISION 引数を使ってください。
%
% X = MULTIBANDREAD(FILENAME,SIZE,PRECISION,OFFSET,INTERLEAVE,
%                  BYTEORDER,SUBSET,SUBSET,SUBSET)
% は、ファイル内のデータのサブセットを読み込みます。最大で3つのサブ
% セットのパラメータが独立して行、列、バンドの次元に応じて使用されます。
%
% パラメータ:
%
%   FILENAME: 読み込むためのファイル名を含む文字列
%
%   SIZE: [HEIGHT, WIDTH, N] の3要素の整数ベクトル。HEIGHT は行の総数で、
%         WIDTH は各列の行の各行の総数、また N はバンドの総数です。
%         すべてを読み込む場合、これはデータの次元になります。
%
%   PRECISION: 読み込むためのデータの書式を指定する文字列。例えば、
%              'uint8'、'double'、'integer*4'です。デフォルトにより、
%              X は倍精度のクラスの配列として出力されます。異なるクラス
%              の書式を設定するにはPRECISIONパラメータを用いてください。
%              例えば、'uint8=>uint8'(または'*uint8') の精度は、UNIT8
%              配列としてデータを出力します。'uint8=>single' は、それぞれ
%              8ビットピクセルとして読み込み、単精度としてMATLABに格納
%              します。PRECISION のより完全な詳細については FREAD の
%              ヘルプを参照してください。
%
%   OFFSET: ファイル内の最初のデータ要素のゼロを基準とした位置。
%           この値はファイルの開始からデータの先頭となる位置までの
%           バイト数を示します。
%
%   INTERLEAVE: 格納されたデータの書式。これは Band-Seqential、
%               Band-Interleaved-by-Line、Band-Interleaved-by-Pixel に
%               対してそれぞれ 'bsq'、'bil'、または 'bip' のどちらかに
%               なります。
%
%   BYTEORDER: 格納されたデータ内のバイト命令(マシンフォーマット)。
%              これは little-endian に対して 'ieee-le' か、または
%              big-endian に対して 'ieee-be' になります。FOPEN の help
%              に記述された他のマシンフォーマットは、BYTEORDER に対して
%              も有効な値です。
%
%   SUBSET: (オプション) {DIM,INDEX} か {DIM,METHOD,INDEX} を含むセル配列。
%           DIM は、独立したサブセットの次元を指定する 'Column'、'Row'、
%           'Band' の3つの文字列の1つです。METHOD は、'Direct' または 
%           'Range' です。METHOD が省略される場合、デフォルトは 'Direct'
%           です。'Direct' のサブセット化を使用する場合、INDEX は独立
%           したバンド次元を読み込むために指定されるインデックスのベクトル
%           です。METHOD が 'Range' の場合、INDEX は範囲とステップサイズと
%           独立した次元で読み込むために指定する [START, INCREMENT, STOP] 
%           の2または3要素のベクトルです。INDEX が2要素の場合、INCREMENT 
%           は1つであると仮定されます。
%
% 例題
% ----
%
%   864×702×3の uint8 の行列内にすべてのデータを読み込みます。
%          im = multibandread('bipdata.img',...
%                            [864,702,3],'uint8=>uint8',0,'bip','ieee-le');
%
%   3、4、6のバンドを除くすべての行と列を読み込みます。
%          im = multibandread('bsqdata.img',...
%                            [512,512,6],'uint8',0,'bsq','ieee-le',...
%                            {'Band','Direct',[3 4 6]});
%
%   すべてのバンドと行と列が独立したサブセットを読み込みます。
%          im = multibandread('bildata.int',...
%                            [350,400,50],'uint16',0,'bil','ieee-le',...
%                            {'Row','Range',[2 2 350]},...
%                            {'Column','Range',[1 4 350]});
%
% 参考 : FREAD, FOPEN. 



%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:09 $
%   $Revision.1 $  $Date: 2004/04/28 01:57:09 $

