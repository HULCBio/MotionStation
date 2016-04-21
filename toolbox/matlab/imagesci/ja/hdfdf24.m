% HDFDF24   HDF 24ビットラスタイメージインタフェースのMATLABゲートウェイ
%
% HDFDFR8 は、HDF24ビットラスタイメージインタフェース(DF24)のゲートウェイ
% です。この関数を使うためには、HDF version 4.1r3のUser'sGuideと
% Reference Manualに含まれている、DF24インタフェースについての情報を
% 知っていなければなりません。このドキュメントは、National Center for 
% Supercomputing Applications (NCSA、<http://hdf.ncsa.uiuc.edu>から得る
% ことができます。
%
% HDFDF24に対する一般的なシンタックスは、HDFDF24(funcstr,param1,param2,...)
% です。HDFライブラリ内のDF24関数と、funcstr に対する有効な値は、1対1で
% 対応します。たとえば、HDFDF24('lastref') は、Cライブラリコール
% DF24lastref() に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% HDFは、最後の次元の要素が最高速になるようなCスタイルの要素の順番を
% 用います。MATLABは、FORTRANスタイルを使っているので、最初の次元の
% 要素が最高速になります。HDFDF24は、Cスタイルの順番からMATLABスタ
% イルの順番に自動的に変換しません。これは、HDFDF24の使用時に、HDF
% ファイルから読み込んだり、書き出すためには、MATLABのイメージ配列を置
% 換する必要があることを意味しています。厳密な置換は、HDFDF24('setil',...)
% のような使用するinterlaceフォーマットに依存します。つぎのPERMUTEの使い
% 方は、指定したinterlaceフォーマットに従ってHDF配列をMATLAB配列に変換
% します。
% 
% 　　　RGB = permute(RGB,[3 2 1]);  'pixel' interlace
%       RGB = permute(RGB,[3 1 2]);  'line' interlace
%       RGB = permute(RGB,[2 1 3]);  'component' interlace
% 
% 書き出し関数
% ------------
% 書き出し関数は、ラスタイメージセットを作成し、それらを新しいファイルに
% 保存するか、既存のファイルに付け加えます。
%
%   status = hdfdf24('addimage',filename,RGB)
%   ファイルに24ビットラスタイメージを付け加えます。
%
%   status = hdfdf24('putimage',filename,RGB)
%   すべての既存のデータを上書きして、ファイルに24ビットラスタイメージを
%   書き出します。
%
%   status = hdfdf24('setcompress',compress_type,...)
%   ファイルに書き出されるつぎのラスタイメージの圧縮方法を設定します。
%   compress_type は、'none', 'rle', 'jpeg', 'imcomp' のいずれかです。
%   compress_type が 'jpeg' の場合は、2つの追加のパラメータを与えなけ
%   ればなりません。それらは、quality (0と100の間のスカラ)と force_baseline
%   (0と1のいずれか)です。他の圧縮タイプでは、追加のパラメータはありません。
%
%   status = hdfdf24('setdims',width,height)
%   ファイルに書き出されるつぎのラスタイメージに対する次元を設定します。
%
%   status = hdfdf24('setil',interlace)
%   ファイルに書き出されるつぎのラスタイメージのinterlace形式を設定します。
%   interlace は、'pixel', 'line', 'component' のいずれかです。
%
%   ref = hdfdf24('lastref')
%   24ビットラスタイメージに割り当てられる最後の参照番号を出力します。
%
% 読み込み関数
% ------------
% 読み込み関数は、イメージの次元とインタフェースフォーマットを決定し、ラスタ
% イメージセットへの連続的なあるいはランダムなアクセスを提供します。
%
%   [width,height,interlace,status] = hdfdf24('getdims',filename)
%   つぎのラスタイメージを読み込む前に次元を取得します。interlace は、
%   'pixel', 'line', 'component' のいずれかです。
%
%   [RGB,status] = hdfdf24('getimage',filename)
%     つぎの24ビットラスタイメージを読み込みます。
%
%   status = hdfdf24('reqil',interlace)
%   つぎのラスタイメージを読み込む前にインタフェースフォーマットを取得します。
%   interlace は、'pixel', 'line', 'component' のいずれかです。
%
%   status = hdfdf24('readref',filename,ref)
%   指定したラスタイメージ番号をもつ24ビットラスタイメージを読み込みます。
%
%   status = hdfdf24('restart')
%   ファイル内の最初の24ビットラスタイメージに戻ります。
%
%   num_images = hdfdf24('nimages',filename)
%   ファイル内の24ビットラスタイメージの数を出力します。
%
%   参考 HDF, HDFAN, HDFDFR8, HDFH, HDFHD, HDFHE,
%        HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:48 $

