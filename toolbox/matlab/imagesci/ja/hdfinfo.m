% HDFINFO HDF 4 または HDF-EOS 2 ファイルに関する情報
%
% FILEINFO = HDFINFO(FILENAME) は、HDFファイルまたはHDF-EOSファイ
% ルの内容に関する情報を含む構造体のフィールドを出力します。FILENAME は
% HDFファイルの名前を指定する文字列です。HDF-EOSファイルは、HDFファイ
% ルとして記述されます。
%
% FILEINFO = HDFINFO(FILENAME,MODE) は、MODE 'hdf'の場合はHDFファ
% イルとして読み込み、MODE が 'eos'の場合はHDF-EOSファイルとしてファ
% イルを読み込みます。MODE が 'eos' の場合は、HDF-EOSデータオブジェクト
% のみが参照されます。ハイブリッドHDF-EOSファイルのすべての内容に関する
% 情報を読み込むためには、MODE をデフォルトの 'hdf' に設定する必要があり
% ます。
%   
% FILEINFO 内のフィールドの設定は、個々のファイルに依存します。FILEINFO 
% 構造体に存在する可能性のあるフィールドは、つぎのものです。
%
% HDF オブジェクト：
%   
%   Filename   ファイル名を含む文字列
%   
%   Vgroup     Vgroupsを記述する構造体の配列
%   
%   SDS        Scientific Data Setsを記述する構造体配列
%   
%   Vdata      Vdata setsを記述する構造体配列
%   
%   Raster8    8-bit Raster Imagesを記述する構造体配列
%   
%   Raster24   24-bit Raster Imagesを記述する構造体配列
%   
%   HDF-EOSオブジェクト：
%
%   Point      HDF-EOS Point dataを記述する構造体配列
%   
%   Grid       HDF-EOS Grid dataを記述する構造体配列
%   
%   Swath      HDF-EOS Swath dataを記述する構造体配列
%   
%   上のデータセット構造体は、いくつかの共通のフィールドを共有しています
%   (つぎのものですが、すべての構造体がこれらすべてのフィールドをもって
%   いるわけではありません)。
%   
%   Filename          ファイル名を含む文字列
%                     
%   Type              HDFオブジェクトタイプを記述する文字列
%   	              
%   Name              データセット名を含む文字列
%                     
%   Attributes        データセットの属性名と値を記述するフィールド 'Name'
%                     と 'Value' をもつ構造体配列
%                     
%   Rank              データセットの次元数を設定する数
%
%   Ref               データセットの参照番号
%
%   Label             Annotationラベルを含むセル配列
%
%   Description       Annotation記述を含むセル配列
%
%   各構造体固有のフィールド：
%   
%   Vgroup:
%   
%      Class      データセットのクラス名を含む文字列
%
%      Vgroup     Vgroupsを記述する構造体配列
%                 
%      SDS        Scientific Data setsを記述する構造体配列
%                 
%      Vdata      Vdata setsを記述する構造体配列
%                 
%      Raster24   24-bit raster imagesを記述する構造体配列 
%                 
%      Raster8    8-bit raster imagesを記述する構造体配列
%                 
%      Tag        このVgroupsのタグ
%                 
%   SDS:
%              
%      Dims       フィールド 'Name', 'DataType', 'Size', 'Scale', 'Attributes' 
%                 をもつ構造体配列。データセットの次元を記述します。
%                 'Scale' は、データセットの中の分割間隔や次元に沿って
%                 配置する数の配列です。
%              
%      DataType   データの精度を指定する文字列
%              
%
%      Index      SDSのインデックスを示す数値
%   
%   Vdata:
%   
%      DataAttributes    データセット全体の属性名と値を記述するフィールド
%                        'Name' と 'Value' をもつ構造体配列
%   
%      Class             データセットのクラス名を含む文字列
%		      
%      Fields            Vdataのフィールドを記述するフィールド 'Name' 
%                        と 'Attributes'をもつ構造体配列
%                        
%      NumRecords        データセットのレコード数を指定する数
%                        
%      IsAttribute       Vdataが属性の場合1、その他の場合0
%      
%   Raster8 と Raster24：
%
%      Name           イメージ名を含む文字列
%   
%      Width          ピクセル単位で表わしたイメージの幅を指定する整数
%      
%      Height         ピクセル単位で表わしたイメージの高さを指定する整数
%      
%      HasPalette     イメージがパレットに関連している場合1、その他の場合0
%      					(8ビットのみ)
%
%      Interlace      イメージのインタレースモードを記述する文字列
%                     (24ビットのみ)
%
%   Point:
%
%      Level          フィールド 'Name', 'NumRecords', 'FieldNames', 
%                     'DataType', 'Index' をもつ構造体。この構造体は、
%                     Point の各レベルを記述します。
%      
%   Grid:
%     
%      UpperLeft      メートル単位で、左上隅の位置を指定する数
%      
%      LowerRight     メートル単位で、右下隅の位置を指定する数
%      
%      Rows           Grid内の行数を指定する整数
%      
%      Columns        Grid内の列数を指定する整数
%      
%      DataFields     フィールド 'Name', 'Rank', 'Dims', 'NumberType', 
%                     'FillValue', 'TileDims' をもつ構造体配列。各構造
%                     体は、Grid の中の Grid フィールドのデータフィール
%                     ドを記述します。
%      
%      Projection     フィールド 'ProjCode', 'ZoneCode', 'SphereCode', 
%                     'ProjParam' をもつ構造体配列。Grid の Projection 
%                      Code, Zone Code, Sphere Code や投影パラメータを
%                      記述します。
%      
%      Origin Code    Grid に対するオリジナルコードを指定する数値
%      
%      PixRegCode     ピクセルのレジストレーションコードを指定する数値
%      
%   Swath:
%		       
%      DataFields     フィールド'Name', 'Rank', 'Dims', 'NumberType', 
%                     'FillValue' をもつ構造体の配列。各構造体は、
%                      Swath の中のData フィールドを記述します。
%
%      GeolocationFields  フィールド 'Name', 'Rank', 'Dims', 'Number-
%                         Type', 'FillValue' をもつ構造体の配列。各構
%                         造体は、Swath の中の Geolocation フィールド
%                         を記述します。
%   
%      MapInfo            データと geolocation フィールド間の関係を記述
%                         するフィールド 'Map', 'Offset', 'Increment' を
%                         もつ構造体。
%   
%      IdxMapInfo         geolocation マッピングのインデックス付き要素間
%                         の関連を記述する 'Map' と 'Size' をもつ構造体
%   
% 
% 例題：  
%             % example.hdf に関する情報の読み込み
%             fileinfo = hdfinfo('example.hdf');
%             % 例題の Scientific Data Set に関する情報の読み込み
%             data_set_info = fileinfo.SDS;
%	     
% 参考 : HDFTOOL, HDFREAD, HDF.  


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:55 $    

