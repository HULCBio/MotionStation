% HDFV   HDF VgroupインタフェースのMATLABゲートウェイ
% 
% HDFVは、HDF Vgroup(V)インタフェースのゲートウェイです。この関数を使う
% ためには、HDF version 4.1r3のUser's GuideとReference Manualに含まれて
% いる、ANインタフェースについての情報を知っていなければなりません。この
% ドキュメントは、National Center for Supercomputing Applications (NCSA、
% <http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFVに対する一般的なシンタックスは、HDFV(funcstr,param1,param2,...) で
% す。HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応し
% ます。たとえば、HDFV('nattrs',vgroup_id) は、Cライブラリコール 
% Vnattrs(vgroup_id) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% アクセスに関する関数
% --------------------
% アクセスに関する関数は、ファイルをオープンし、Vgroupインタフェースを
% 初期化し、個々のグループにアクセスします。これらは、vgroupとVgroup
% インタフェースへのアクセスを終了し、HDFファイルをクローズします。
%
%   status = hdfv('start',file_id)
%   Vインタフェースを初期化します。
%
%   vgroup_id = hdfv('attach',file_id,vgroup_ref,access)
%   vgroupへのアクセスを行います。accessは、'r' または 'w' です。
%
%   status = hdfv('detach',vgroup_id)
%   vgroupへのアクセスを終了します。
%
%   status = hdfv('end',file_id)
%   Vインタフェースへのアクセスを終了します。
%
% 作成に関する関数
% ----------------
% 作成に関する関数は、vgroupにデータグループを組織し、ラベルを付け、
% データオブジェクトを追加します。
%
%   status = hdfv('setclass',vgroup_id,class)
%   vgroupにクラスを割り当てます。
%
%   status = hdfv('setname',vgroup_id,name)
%   vgroupに名前を割り当てます。
%
%   ref = hdfv('insert',vgroup_id、id)
%   既存のグループにvgroupまたはvdataを追加します。id は、vdataのid
%   またはvgroupのidです。
%
%   status = hdfv('addtagref',vgroup_id,tag,ref)
%   既存のvgroupにHDFデータオブジェクトを追加します。
%
%  status = hdfv('setattr',vgroup_id,name,A)
%   vgroupの属性を設定します。
%
% ファイルの情報に関する関数
% --------------------------
% ファイルの情報に関する関数は、vgroupのファイルへの保存方法に関する
% 情報を出力します。これらは、vgroupをファイルに配置するために便利な
% 方法です。
%
%   [refs,count] = hdfv('lone',file_id,maxsize)
%   他のvgroupに含まれていないvgroupの参照番号を出力します。
%
%   next_ref = hdfv('getid',file_id,vgroup_ref)
%   HDFファイル内のつぎのvgroupに対する参照番号を出力します。
%
%   vgroup_ref = hdfv('findclass',file_id,class)
%   指定したクラスをもつVgroupの参照番号を出力します。
%
% Vgroupの情報に関する関数
% ------------------------
% Vgroupの情報に関する関数は、特定のvgroupに関して指定した情報を提供
% します。この情報は、クラス、名前、メンバ数、付加的なメンバの情報を
% 含みます。
%
%   [class_name,status] = hdfv('getclass',vgroup_id)
%   指定したグループのクラスを出力します。
%
%   [vgroup_name,status] = hdfv('getname',vgroup_id)
%   指定したグループ名を出力します。
%
%   status = hdfv('isvg',vgroup_id,ref)
%   vgroupの識別子が、vgroup内のvgroupに属するかどうかをチェックします。
%   ref は、vdataまたはvgroupの参照番号です。
%
%   status = hdfv('isvs',vgroup_id,vdata_ref)
%   vdataの識別子が、vgroup内のvdataに属するかどうかをチェックします。
%
%   [tag,ref,status] = hdfv('gettagref',vgroup_id,index)
%   指定したvgroup内のデータオブジェクトに対する、タグと参照番号の組合わせ
%   を取得します。
%
%   count = hdfv('ntagrefs',vgroup_id)
%   指定したvgroup内に含まれるタグと参照番号の組合わせを出力します。
%
%   [tag,refs,count] = hdfv('gettagrefs',vgroup_id,maxsize)
%   vgroup内のすべてのデータオブジェクトの、タグと参照番号の組合わせを
%   取得します。
% 
%   tf = hdfv('inqtagref',vgroup_id,tag,ref)
%   オブジェクトが、vgroupに属するかどうかをチェックします。
%
%   version = hdfv('getversion',vgroup_id)
%   与えられたvgroupのバージョンを確認します。
%
%   count = hdfv('nattrs',vgroup_id)
%   vgroupの属性の総数を確認します。
%
%   [name,data_type,count,nbytes,status] = ....
%                hdfv('attrinfo',vgroup_id,attr_index)
%   与えられたvgroupの属性に関する情報を確認します。
%
%   [values,status] = hdfv('getattr',vgroup_id,attr_index)
%   与えられた属性の値を確認します。
%
%   ref = hdfv('Queryref',vgroup_id)
%   指定したvgroupの参照番号を出力します。
%
%   tag = hdfv('Querytag',vgroup_id)
%   指定したvgroupのタグを出力します。
%
%   vdata_ref = hdfv('flocate',vgroup_id,field)
%   指定したvgroup内で指定したフィールド名を含むvdataの参照番号を出力
%   します。
%
%   count = hdfv('nrefs',vgroup_id,tag)
%   指定したvgroup内で指定したタグをもつデータオブジェクト数を出力します。
% 
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:02 $
