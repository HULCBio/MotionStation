% HDFVH   HDF VdataインタフェースのVH関数のMATLABゲートウェイ
% 
% HDFVFは、HDF Vdataインタフェース内のVH関数のゲートウェイです。この関
% 数を使うためには、HDF version 4.1r3のUser's GuideとReference Manualに
% 含まれている、Vdataインタフェースについての情報を知っていなければなりま
% せん。このドキュメントは、National Center for Supercomputing 
% Applications (NCSA、<http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFVHに対する一般的なシンタックスは、HDFVH(funcstr,param1,param2,...)
% です。HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応
% します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
%
% 入力vdata_classは、HDF数値タイプを定義する文字列です。つぎのものが使
% 用できます。
% 
%    'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8', 'uint16', 
%    'uint32', 'float', 'int8', 'int16', 'int32'
% 
% 高水準Vdataに関する関数
% -----------------------
% 高水準Vdataに関する関数は、データを単一のフィールドのvdataに書き出しま
% す。
%
%   vgroup_ref = ....
%      hdfvh('makegroup',file_id,tags,refs,vgroup_name,vgroup_class)
%   vgroup内のデータオブジェクトの集合をグループ化します。
%
%   count = ....
%     hdfvh('storedata',file_id,fieldname,data,vdata_name,vdata_class)
%   1つのフィールドのみをもつレコードを含むvdataを作成します。フィールド毎
%   に1つの要素を含みます。
%   注意：データのクラスは、HDF数値タイプvdata_classと一致しなければなりま
%   せん。MATLAB文字列は、HDF charタイプのいずれかに一致するように自動
%   的に変換されます。他のデータタイプは厳密な意味で、一致しなければなり
%   ません。
%
%   count = ....
%     hdfvh('storedatam',file_id,filename,data,vdata_name,vdata_class)
%   1つのフィールドをもつレコードを含むvdataを作成します。フィールドは、単
%   数または複数の要素を含みます。注意：データのクラスは、HDF数値タイ
%   プvdata_classと一致しなければなりません。MATLABの文字列は、HDF char
%   タイプのいずれかに一致するように自動的に変換されます。他のデータタイプ
%   は厳密な意味で、一致しなければなりません。
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:04 $
