% HDFVF   HDF Vdataインタフェース内のVF関数のMATLABゲートウェイ
% 
% HDFVFは、HDF Vdataインタフェース内のVF関数のゲートウェイです。この関
% 数を使うためには、HDF version 4.1r3のUser's GuideとReferenceManualに含
% まれている、Vdataインタフェースについての情報を知っていなければなりませ
% ん。このドキュメントは、National Center for Supercomputing Applications 
% (NCSA、<http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFVFに対する一般的なシンタックスは、HDFVF(funcstr,param1,param2,...)
% です。HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応
% します。たとえば、HDFVF('nfields',vdata_id) は、Cライブラリコール
% VFnfields(vdata_id) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% フィールドの情報に関する関数
% ----------------------------
% フィールドの情報に関する関数は、与えられたvdata内のフィールドに関する
% 情報を提供します。これは、vdata内のフィールドのサイズ、フィールド名、
% 順序、タイプ、フィールドの個数を含みます。
%
%   fsize = hdfvf('fieldesize',vdata_id,field_index)
%   指定したフィールドのフィールドサイズ(ファイルに格納されています)を
%   取得します。
% 
%   fsize = hdfvf('fieldisize',vdata_id,field_index)
%   指定したフィールドのフィールドサイズ(メモリに格納されています)を取得
%   します。
%
%   name = hdfvf('fieldname',vdata_id,field_index)
%   与えられたvdata内の指定したフィールド名を取得します。
%
%   order = hdfvf('fieldorder',vdata_id,field_index)
%   与えられたvdata内の指定したフィールドの順番を取得します。
%
%   data_type = hdfvf('fieldtype',vdata_id,field_index)
%   与えられたvdata内の指定したフィールドのデータタイプを取得します。
%
%   count = hdfvf('nfields',vdata_id)
%   指定したvdata内のフィールドの総数を取得します。
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:03 $
