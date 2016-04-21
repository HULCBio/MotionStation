% HDFHX   HDF外部データインタフェースへのMATLABゲートウェイ
%
% HDFHX は、リンクしたデータ要素や外部データ要素を取り扱うためのHDF
% インタフェースへのゲートウェイです。この関数を使うためには、HDF version 
% 4.1r3のUser'sGuideとReference Manualに含まれている、HXインタフェースに
% ついての情報を知っていなければなりません。このドキュメントは、National 
% Center for Supercomputing Applications(NCSA <http://hdf.ncsa.uiuc.edu>)
% から得ることができます。 
% 
% HDFHX に対する一般的なシンタックスは、HDFHX(funcstr,param1,param2,...) 
% です。HDF ライブラリ内のHX関数と funcstr に対する有効な値は、1対1で
% 対応します。たとえば、HDFHX('setdir',pathname); は、Cライブラリコール 
% HXsetdir(pathname) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
%
% HDF Cライブラリが､ある入力に対してNULLを受け入れる場合は、空行列([] 
% または '')が使われます。
%
% シンタックス
% ------------
%  access_id = hdf('HX', 'create', file_id, tag, ref, extern_name,
% 		   offset, length)
% 新しい外部ファイルの特定のデータ要素を作成します。
% 
%  status = hdf('HX','setcreatedir',pathname);
%  書き込み用外部ファイルのディレクトリの位置を設定します。
%
%  status = hdf('HX','setdir',pathname);
%  外部ファイルを配置するためにディレクトリを設定します。PATHNAME は、
%  | で分離した複数のディレクトリを含むこともできます。
%
% 参考：HDF, HDFSD, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:54 $
