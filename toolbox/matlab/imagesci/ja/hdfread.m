% HDFREAD   HDF ファイルからデータを抽出
%   
% HDFREAD は、HDFまたはHDF-EOS ファイルの中のデータセットからデータ
% を読み込みます。データセットの名前が既知の場合、HDFREAD は、データを含
% むファイルをサーチします。その他の場合、HDFINFO を使って、ファイルの内
% 容を記述する構造体を得ることができます。HDFINFO で出力される構造体のフ
% ィールドは、ファイルの中に含まれるデータセットを記述する構造体です。
% データセットを記述する構造体が抽出され、直接、HDFREAD に渡されます。こ
% れらのオプションは、下に詳細を記しています。
%   
% DATA = HDFREAD(FILENAME,DATASETNAME) は、DATASETNAME と名付け
% たデータセットに対して、ファイル FILENAME から変数 DATA に、すべてのデー
% タを出力します。
%   
% DATA = HDFREAD(HINFO) は、HINFO により記述される特定のデータセットに
% 対して、ファイルから変数 DATA にすべてのデータを出力します。HINFO は、
% HDFINFO の出力構造体から抽出された構造体です。
%   
% DATA = HDFREAD(...,PARAMETER,VALUE,PARAMETER2,VALUE2...) は、サブ
% セットのタイプとその値 VALUE を指定する文字列 PARAMETER に従って、デー
% タを分類します。つぎの表は、データセットの各タイプに対する正しいサブセット
% のパラメータの概要を示したものです。'required' とマークしたパラメータは、
% データセットの中にストアされたデータを読み込むために使われます。
% "exclusive" とマークしたパラメータは、必要なパラメータを除いて、他のサブ
% セットパラメータと共に使うことはありません。パラメータが複数値を必要とす
% る場合、値は、セル配列にストアされる必要があります。パラメータに対して
% 必要な値の数は、データセットのタイプと共に変化します。これらの違いは、
% パラメータの記述の中に記述されています。
%
% [DATA,MAP] = HDFREAD(...) は、8ビットラスタイメージに対して、イメージ
% データとカラーマップを出力します。
%   
% 使用可能なサブセットパラメータの表
%
%
%           データセット      |   サブセットパラメータ
%          ========================================
%           HDF Data          |
%                             |
%             SDS             |   'Index'
%                             |
%             Vdata           |   'Fields'
%                             |   'NumRecords'
%                             |   'FirstRecord'
%          ___________________|____________________
%           HDF-EOS Data      |   
%                             |
%             Grid            |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Tile'           (exclusive)
%                             |   'Interpolate'    (exclusive)
%                             |   'Pixels'         (exclusive)
%                             |   'Box'
%                             |   'Time'
%                             |   'Vertical'
%                             |
%             Swath           |   'Fields'         (required)
%                             |   'Index'          (exclusive)
%                             |   'Time'           (exclusive)
%                             |   'Box'
%                             |   'Vertical'
%                             |   'ExtMode'
%                             |
%             Point           |   'Level'          (required)
%                             |   'Fields'         (required)
%                             |   'RecordNumbers'
%                             |   'Box'
%                             |   'Time'
%
% Raster Image用のサブセットパラメータはありません。
%
%
% 正しいパラメータとその値は、以下の通りです。
%
%   'Index' 
%   'Index'に対する値： START, STRIDE, EDGE
%
% START, STRIDE, EDGE は、次元数と等しいサイズをもつ配列でなければなりま
% せん。START は、データセットの中で、読み始める位置を指定します。START 
% に設定されたそれぞれの数は、対応する次元よりも小さい必要があります。
% STRIDE は、読み込む値の間の間隔を指定する配列です。EDGE は、読み込む
% 各次元の長さを指定する配列です。START, STRIDE, EDGE で指定した領域
% は、データセットの次元に書き込まれます。START, STRIDE, EDGE のいずれか
% が空の場合は、デフォルト値はつぎの仮定のもとで計算されます。各次元の最
% 初の要素でスタートし、1つの STRIDE で、次元のスタート点から終了点までを
% 読むように EDGE を考えます。デフォルトは、START, STRIDE に対してすべて
% 1で、EDGE は対応する次元の長さを含む配列です。START, STRIDE, EDGE 
% は、共に1をベースにしています。START, STRIDE, EDGE ベクトルは、つぎの記
% 法を使って、1つのセルにストアされます。{START,STRIDE,EDGE}
%
%   'FIELDS'
%    'Fields'に対する値： FIELDS
%
% データセットのフィールド FIELDS からデータを読み込みます。FIELDS は、
% 単一の文字列です。複数のフィールド名に対しては、カンマを区切り子として
% 使った一覧を使います。Grid と Swath データセットに対しては、たった1つ
% のフィールドのみの設定で構いません。
%
%   'Box'
%   'Box'に対する値： LONG, LAT, MODE
%
% LONG と LAT は、緯度/経度領域を指定する数値です。MODE は、領域内の
% 交点軌道を含んでいるか否かの基準を定義します。ある領域の中に交点軌道
% が存在するかは、その中間点がボックスの中に含まれる、すなわち、どちらか
% の端点がボックス内に存在するか、または任意の点がボックス内に存在する
% ことです。そのために、MODE は 'midpoint',  'endpoint', 'anypoint' を設定するこ
% とができます。MODE は、Swath データに対してのみ有効で、Grid や Point 
% データセットに対して指定される場合は無視されます。
%
%   'Time'
%   'Time' に対する値： STARTTIME, STOPTIME, MODE
%
% STARTTIME と STOPTIME は、時間領域を指定する数値です。MODE は、領
% 域内の交点軌道を含んでいるか否かの基準を定義します。ある領域の中に交
% 点軌道が存在するかは、その中間点がボックスの中に含まれる、すなわち、ど
% ちらかの端点がボックス内に存在するか、または任意の点がボックス内に存在
% することです。そのために、MODE は、'midpoint', 'endpoint', 'anypoint' を設定す
% ることができます。MODE は、Swath データに対してのみ有効で、Grid や Point 
% データセットに対して指定される場合は無視されます。
%
%   'Vertical'
%   'Vertical'に対する値：DIMENSION, RANGE
%
% RANGE は、サブセットに対して、レンジの最小と最大を指定するベクトルです。
% DIMENSION は、フィールド名またはサブセット毎の次元です。DIMENSION 
% が次元の場合、RANGE は抽出する要素のレンジ(1ベース)を指定します。
% DIMENSION がフィールドの場合は、RANGE は抽出する値のレンジを指定しま
% す。垂直方向のサブセットは、'Box' または'Time' と合わせて利用されます。
% 複数次元に沿った領域のサブセット化を行うため、垂直方向のサブセットは、
% HDFREADへの1回の呼び出しで8回まで使うことができます。
%
%   'ExtMode'
%   'ExtMode'に対する値： EXTMODE
%
% EXTMODE は、'Internal' (デフォルト)または 'External' のいずれかを設定し
% ます。モードが 'Internal' に設定される場合は、geolocation フィールドと
% data フィールドは同じ区間に存在する必要があります。モードが 'External'
% に設定される場合は、geolocation フィールドと data フィールドは異なる区間に
% 存在しても構いません。このパラメータは、時間区間または領域を抽出する
% ときに、Swath に対してのみ使用するものです。
%
%   'Pixels'
%   'Pixels'に対する値： LON, LAT
%
% LON と LAT は、緯度/経度領域を指定する数字です。緯度/経度による領域
% は、グリッドの左上隅を原点としたピクセルの行と列に変換することができます。
% これは、'Box' 領域を設定するものとピクセルで等価になります。
%
%   'RecordNumbers'
%   'RecordNumbers'に対する値：: RecNums
%
% RecNums は、読み込むレコード数を指定するベクトルです。  
%
%   'Level'
%   'Level'に対する値： LVL
%   
% LVL は、HDF-EOS Pointデータセットの中から読み込むレベルを指定する1を
% ベースにした数値です。
%
%   'NumRecords'
%   'NumRecords'に対する値： NumRecs
%
% NumRecs は、読み込むレコード長の総数を指定する数字です。
%
%   'FirstRecord'
%   'FirstRecord'に対して必要な値： FirstRecord
%
% FirstRecord は、読み込みを開始する最初のレコードを指定する1をベースに
% した数字です。
%
%   'Tile'
%   'Tile'に対して必要な値： TileCoords
%
% TileCoords は、読み込むタイル座標を指定するベクトルです。
%
%   'Interpolate'
%   'Interpolate'に対する値： LON, LAT
%
% LON と LAT は、双一次内挿に対して、指定する緯度/経度の点の数です。
%
%    参照： 
%
%    例題 1:
%            
%             % 'Example SDS' と名付けたデータセットを読み込む
%             data = hdfread('example.hdf','Example SDS');
%
%    例題 2:
%
%             % example.hdf に関する情報を読み込む
%             fileinfo = hdfinfo('example.hdf');
%             % example.hdf の中のScientific Data Setに関する情報を
%               読み込む
%             data_set_info = fileinfo.SDS;
%             %  サイズのチェック
%             data_set_info.Dims.Size
%             % info 構造体を使って、データのサブセットを読み込む
%             data = hdfread(data_set_info,...
%                              'Index',{[3 3],[],[10 2 ]});
%
% 参考 : HDFTOOL, HDFINFO, HDF.  


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:58 $
