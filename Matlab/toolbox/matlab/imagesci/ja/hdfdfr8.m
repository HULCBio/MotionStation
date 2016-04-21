% HDFDFR8   HDF 8ビットラスタイメージインタフェースのMATLABゲートウェイ
% 
% HDFDFR8は、HDF 8ビットラスタイメージインタフェース(DFR8)のゲートウェイ
% です。この関数を使うためには、HDF version 4.1r3のUser's Guideと
% Reference Manualに含まれている、DFR8インタフェースについての情報を
% 知っていなければなりません。このドキュメントは、National Center for 
% Supercomputing Applications (NCSA、<http://hdf.ncsa.uiuc.edu>)から得る
% ことができます。
%
% HDFDFR8に対する一般的なシンタックスは、HDFDFR8(funcstr,param1,
% param2,...)です。HDFライブラリ内のDFR8関数と、funcstr に対する有効な値は、
% 1対1で対応します。たとえば、HDFDFR8('setpalette',map) は、Cライブラリコー
% ル DFR8setpalette(map) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% HDFは、最後の次元の要素が最高速になるようなCスタイルの要素の順番を
% 用います。MATLABは、FORTRANスタイルを使っているので、最初の次元の
% 要素が最高速になります。HDFDFR8は、Cスタイルの順番からMATLABスタ
% イルの順番に自動的に変換しません。これは、HDFDF24の使用時に、HDF
% ファイルから読み込んだり、書き出すためには、MATLABのMATLABイメージ
% 行列やカラーマップ行列を置換する必要があることを意味しています。
% 
% パレット情報を読み込んだり、書き出すHDFDFR8内の関数は、範囲が
% [0,255] のuint8タイプのデータを使い、MATLABでは範囲 [0,1] の倍精度値
% を使っています。そのため、HDFパレットは、MATLABのカラーマップとして
% 利用できるように倍精度に変換し、スケーリングする必要があります。
% 
% 書き出し関数
% ------------
% 書き出し関数は、ラスタイメージセットを作成し、それらを新しいファイルに
% 保存するか、既存のファイルに付け加えます。
%
%   status = hdfdfr8('writeref',filename,ref)
%   指定した参照番号を使って、ラスタイメージを保存します。
%
%   status = hdfdfr8('setpalette',colormap)
%   複数の8ビットラスタイメージに対するパレットを設定します。
%
%   status = hdfdfr8('addimage',filename,X,compress)
%   8ビットラスタイメージをファイルに付け加えます。compress は、'none'、
%   'rle', 'jpeg', 'imcomp' のいずれかです。
%
%   status = hdfdfr8('putimage',filename,X,compress)
%   8ビットラスタイメージを既存のファイルに書き出すか、ファイルを作成しま
%   す。compress は、'none', 'rle', 'jpeg', 'imcomp' のいずれかです。
%
%   status = hdfdfr8('setcompress',compress_type,...)
%   圧縮のタイプを設定します。compress_type は、'none', 'rle', 'jpeg', 
%   'imcomp' のいずれかです。compress_type が 'jpeg' の場合は、2つの追加
%   のパラメータを与えなければなりません。それらは、quality (0と100の
%   間のスカラ)と force_baseline (0と1のいずれか)です。他の圧縮のタイプは、
%   追加のパラメータはありません。
%
% 読み込み関数
% ------------
% 読み込み関数は、イメージの集合に対する次元とパレットの割り当てを指定し、
% 実際のイメージデータを読み込み、任意のラスタイメージセットへの連続的な
% あるいはランダムなアクセスを提供します。
%
%   [width,height,hasmap,status] = hdfdfr8('getdims',filename)
%   8ビットラスタイメージに対する次元を取得します。
%  
%   [X,map,status] = hdfdfr8('getimage',filename)
%   8ビットラスタイメージとそのパレットを取得します。
%
%   status = hdfdfr8('readref',filename,ref)
%   指定した参照番号をもつつぎのラスタイメージを取得します。
%
%   status = hdfdfr8('restart')
%   最後にアクセスしたファイルに関する情報を無視し、最初からリスタート
%   します。
%
%   num_images = hdfdfr8('nimages',filename)
%    ファイル内のラスタイメージ数を出力します。
%
%   ref = hdfdfr8('lastref')
%   最後にアクセスした要素の参照番号を出力します。
%
% 参考：HDF, HDFAN, HDFDF24, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:49 $
