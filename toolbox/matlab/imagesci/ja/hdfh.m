% HDFH   HDF HインタフェースのMATLABゲートウェイ
% 
% HDFHは、HDF Hインタフェースのゲートウェイです。この関数を使うためには
% HDF version 4.1r3のUser's GuideとReference Manualに含まれている、Vdata
% インタフェースについての情報を知っていなければなりません。このドキュメ
% ントは、National Center for Supercomputing Applications (NCSA、<http:
% //hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFHに対する一般的なシンタックスは、HDFH(funcstr,param1,param2,...)で
% す。HDFライブラリ内のH関数と、funcstr に対する有効な値は、1対1で対応し
% ます。たとえば、HDFH('close',file_id) は、Cライブラリコール 
% Hclose(file_d) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
%   status = hdfh('appendable',access_id)
%   要素が付加可能であることを指定します。
%
%   status = hdfh('close',file_id)
%   ファイルへのアクセスパスをクローズします。
%
%   status = hdfh('deldd',file_id,tag,ref)
%   データの記述子リストからタグと参照番号を削除します。
%
%   status = hdfh('dupdd',file_id,tag,ref,old_tag,old_ref)
%
%   status = hdfh('endaccess',access_id)
%   アクセスの識別子を除去して、データオブジェクトのアクセスを終了します。
% 
%   [filename,access_mode,attach,status] = hdfh('fidinquire',file_id)
%   指定したファイルに関する情報を出力します。
%
%   [tag,ref,offset,length,status] = hdfh('find',file_id,...
%               search_tag,search_ref,search_type,dir)
%   HDFファイル内で検索されるつぎのオブジェクトの位置を指定します。
%   sea rch_type は、'new' または 'continue' です。dir は、'forward' 
%   または'backward' です。
%
%   [data,status] = hdfh('getelement',file_id,tag,ref)
%   指定したタグと参照番号に対するデータの要素を読み込みます。
%
%   [major,minor,release,info,status] = hdfh('getfileversion',file_id)
%   HDFファイルに対するバージョン情報を出力します。
%
%   [major,minor,release,info,status] = hdfh('getlibversion')
%   カレントのHDFライブラリに対するバージョン情報を出力します。
%
%   [file_id,tag,ref,length,offset,position,access,special,...
%                               status] = hdfh('inquire',access_id)
%   データの要素に関するアクセス情報を出力します。
%
%   tf = hdfh('ishdf',filename)
%   ファイルがHDFファイルかどうかを指定します。
%
%   length = hdfh('length',file_id,tag,ref)
%   タグと参照番号で指定されたデータオブジェクトの長さを出力します。
%
%   ref = hdfh('newref',file_id)
%   一意的なタグと参照番号の組合わせを出力するために、タグと共に使用され
%   る参照番号を出力します。
%
%   status = hdfh('nextread',access_id,tag,ref,origin)
%   指定したタグと参照番号が一致する、つぎのデータの記述子を検索します。
%   origin は、'start' または 'current' です。
%
%   num = hdfh('number',file_id,tag)
%   ファイル内のタグの個数を出力します。
%
%   offset = hdfh('offset',file_id,tag,ref)
%   ファイル内のデータの要素のオフセットを出力します。
%
%   file_id = hdfh('open',filename,access,n_dds)
%   すべてのデータの記述子ブロックをメモリに読み込んで、HDFファイルのアクセ
%   スパスを出力します。
%
%   count = hdfh('putelement',file_id,tag,ref,X)
%   データ要素を書き出すか、HDFファイル内の既存のデータ要素を置き換え
%   ます。X は、uint8の配列でなければなりません。
%
%   X = hdfh('read',access_id,length)
%   データ要素内のつぎのセグメントを読み込みます。
%
%   status = hdfh('seek',access_id,offset,origin)
%   アクセスポインタを、データ要素内のオフセットに設定します。originは、
%   'start' または 'current' です。
%
%   access_id = hdfh('startread',file_id,tag,ref)
%
%   access_id = hdfh('startwrite',file_id,tag,ref,length)
%
%   status = hdfh('sync',file_id)
%
%   length = hdfh('trunc',access_id,trunc_len)
%   指定したデータオブジェクトを、与えられた長さで打ち切ります。
%
%   count = hdfh('write',access_id,X)
%   つぎのデータセグメントを、指定したデータの要素に書き出します。Xは、
%   uint8の配列でなければなりません。
%
% サポートされていない関数
% ---------------------
% NCSA Hインタフェース内のつぎの関数は、現在HDFHではサポートされてい
% ません：Hcache、Hendbitaccess、Hexist、Hflushdd、Hgetbit、Hputbit、Hsetl-
% ength、Hshutdown、Htagnewref.
% 
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:51 $
