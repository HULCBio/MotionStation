% 読み込み可能なファイル書式
%
% データフォーマット                コマンド   戻り値
%   MAT  - MATLAB workspace         load       ファイルの中の変数
%   CSV  - Comma separated numbers  csvread    Double 配列
%   DAT  - Formatted text           importdata Double 配列
%   DLM  - Delimited text           dlmread    Double 配列
%   TAB  - Tab separated text       dlmread    Double 配列
%
% スプレットシートフォーマット
%   XLS  - Excel worksheet          xlsread   Double 配列とセル配列
%   WK1  - Lotus 123 worksheet      wk1read   Double 配列とセル配列
%
% 科学的なデータフォーマット
%   CDF  - Common Data Format               cdfread  CDFレコードのセル配列
%   FITS - Flexible Image Transport System  fitsread 基本的または拡張
%                                                    テーブルデータ
%   HDF  - Hierarchical Data Format         hdfread  HDFまたHDF-EOS
%                                                    データセット
%
% ムービーフォーマット
%   AVI  - Movie                    aviread   MATLABムービー
%
% イメージフォーマット                    
%   TIFF - TIFF image               imread    トゥルーカラー, グレイスケール,
%                                             インデックス付きイメージ
%   PNG  - PNG image                imread    トゥルーカラー, グレイスケール,
%                                             インデックス付きイメージ
%   HDF  - HDF image                imread    トゥルーカラー,
%                                             インデックス付きイメージ
%   BMP  - BMP image                imread    トゥルーカラー,
%                                             インデックス付きイメージ
%   JPEG - JPEG image               imread    トゥルーカラー, 
%                                             グレイスケールイメージ 
%   GIF  - GIF image                imread    インデックス付きイメージ
%   PCX  - PCX image                imread    インデックス付きイメージ
%   XWD  - XWD image                imread    インデックス付きイメージ
%   CUR  - Cursor image             imread    インデックス付きイメージ
%   ICO  - Icon image               imread    インデックス付きイメージ
%   RAS  - Sun raster image         imread    トゥルーカラー, インデックス付き
%   PBM  - PBM image                imread     グレイスケールイメージ
%   PGM  - PGM image                imread     グレイスケールイメージ
%   PPM  - PPM image                imread     トゥルーカラーイメージ
% 
% オーディオフォーマット
%   AU   - NeXT/Sun sound           auread    音声データとサンプルレート
%   SND  - NeXT/Sun sound           auread    音声データとサンプルレート
%   WAV  - Microsoft Wave sound     wavread   音声データとサンプルレート
%
% 参考： IOFUN


%   Copyright 1984-2002 The MathWorks, Inc.
