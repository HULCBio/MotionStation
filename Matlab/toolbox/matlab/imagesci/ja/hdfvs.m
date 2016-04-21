% HDFVS   HDF VdataインタフェースのVS関数のMATLABゲートウェイ
% 
% HDFVSは、HDF Vdataインタフェース内のVS関数のゲートウェイです。この関
% 数を使うためには、HDF version 4.1r3のUser's GuideとReference Manualに
% 含まれている、Vdataインタフェースについての情報を知っていなければなりま
% せん。このドキュメントは、National Center for Supercomputing 
% Applications (NCSA、<http://hdf.ncsa.uiuc.edu>)から得ることができます。
%
% HDFVSの一般的なシンタックスは、HDFVS(funcstr,param1,param2,...) です。
% HDFライブラリ内のV関数と、funcstr に対する有効な値は、1対1で対応しま
% す。たとえば、HDFVS('detach',vdata_id) は、Cライブラリコール
% VSdetach(vdata_id) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
%
% アクセスに関する関数
% --------------------
% アクセスに関する関数は、vdataを付け加えたり、アクセスを行います。
% データの転送は、vdataがアクセスされた後でのみ行えます。これらのルーチンは、
% vdataを除去したり、データ転送が終了したときにアクセスを正常に終了します。
%
%   vdata_id = hdfvs('attach',file_id,vdata_ref,access)
%   指定したvdataへのアクセスを行います。access は、'r' または 'w' です。
%
%   status = hdfvs('detach',vdata_id)
%   指定したvdataへのアクセスを終了します。
%
% 読み込みと書き出しに関する関数
% ------------------------------
% 読み込みと書き出しに関する関数は、vdataの内容の読み込みと書き出しを
% 行います。
%
%   status = hdfvs('fdefine',vdata_id,fieldname,data_type,order)
%   新しいvdataのフィールドを定義します。data_type は、HDFの数値タイプを
%   指定する文字列です。つぎの文字列が利用できます。
% 
%     'uchar8'、'uchar'、'char8'、'char'、'double','uint8'、'uint16'、
%     'uint32'、'float'、'int8'、'int16'、'int32'
%
%   status = hdfvs('setclass',vdata_id,class)
%   vdataにクラスを割り当てます。
%
%   status = hdfvs('setfields',vdata_id,fields)
%   書き出されるvdataのフィールドを指定します。
%
%   status = hdfvs('setinterlace',vdata_id,interlace)
%   vdataに対する interlace モードを設定します。interlace は、'full' または
%   'no' です。
% 
%   status = hdfvs('setname',vdata_id,name)
%   vdataに名前を割り当てます。
%
%   count = hdfvs('write', vdata_id, data)
%   vdataに書き出します。data は、nfields行1列のセル配列でなければなり
%   ません。各セルは、data の order(i )行 n 列のベクトルを含まなければ
%   なりません。ここで、order(i)は、各フィールドのスカラ値の個数です。
%   data のタイプは、hdfvs('setfields') で設定されるフィールドタイプ、
%   または既に存在するvdataのフィールドに一致しなければなりません。
%
%   [data,count] = hdfvs('read',vdata_id,n)
%   vdataから読み込みます。データは、nfields行1列のセル配列に出力されま
%   す。各セルは、data の order(i) 行 n列のベクトルを含まなければなりませ
%   ん。ここで、orderは、各フィールドのスカラ値の個数です。フィールドは、
%   hdfvs('setfields',...) で指定された同じ順序で出力されます。
%
%   pos = hdfvs('seek',vdata_id,record)
%   vdata内の指定したレコードを捜します。
%
%   status = hdfvs('setattr',vdata_id,field_index,name,A)
%   vdataのフィールドまたはvdataの属性を設定します。
%
%   status = hdfvs('setexternalfile',vdata_id,filename,offset)
%   vdataの情報を、外部ファイルに格納します。
%
% ファイルの情報に関する関数
% --------------------------
% ファイルの情報に関する関数は、vdataをファイル内に保存する方法に関する
% 情報を提供します。これらは、vdataをファイル内に配置するために、便利な
% 方法です。
%
%   vdata_ref = hdfvs('find',file_id,vdata_name)
%   指定したHDFファイル内で、与えられたvdata名を検索します。
%
%   vdata_ref = hdfvs('findclass',file_id,vdata_class)
%   指定したvdataのクラスに対応する最初のvdataの参照番号を出力します。
%
%   next_ref = hdfvs('getid',file_id,vdata_ref)
%   ファイル内のつぎのvdataの識別子を出力します。
%
%   [refs,count] = hdfvs('lone',file_id,maxsize)
%   vgroupにリンクされていないvdataの参照番号を出力します。
%
% Vdataの情報に関する関数
% -----------------------
% Vdataの情報に関する関数は、与えられたvdataに関する情報を提供します。
% これは、vdataの名前、クラス、フィールド数、レコード数、タグと参照番号の
% 組合わせ、interlaceモード、サイズを含みます。
%
%   status = hdfvs('fexist',vdata_id,fields)
%   指定したvdata内にフィールドが存在するかどうかをテストします。
%
%   [n,interlace,fields,nbytes,vdata_name,status] = ....
%                                   hdfvs('inquire',vdata_id)
%   指定したvdataに関する情報を出力します。
%
%   count = hdfvs('elts',vdata_id)
%   指定したvdata内のレコード数を出力します。
%
%  [class_name,status] = hdfvs('getclass',vdata_id)
%   指定したvdata内のレコード数を出力します。
%
%   [field_names,count] = hdfvs('getfields',vdata_id)
%   指定したvdata内のすべてのフィールド名を出力します。
%
%   [interlace,status] = hdfvs('getinterlace',vdata_id)
%   指定したvdataのinterlaceモードを取得します。
%
%   [vdata_name,status] = hdfvs('getname',vdata_id)
%   指定したvdata名を取得します。
%
%   version = hdfvs('getversion',vdata_id)
%   vdataのバージョン番号を出力します。
%
%   nbytes = hdfvs('sizeof',vdata_id,fields)
%   指定したvdataのフィールドサイズを出力します。
%
%   [fields,status] = hdfvs('Queryfields',vdata_id)
%   指定したvdataのフィールド名を出力します。
% 
%   [name,status] = hdfvs('Queryname',vdata_id)
%   指定したvdata名を出力します。
%
%   ref = hdfvs('Queryref',vdata_id)
%   指定したvdataの参照番号を取得します。
%
%   tag = hdfvs('Querytag',vdata_id)
%   指定したvdataのタグを取得します。
%
%   [count,status] = hdfvs('Querycount',vdata_id)
%   指定したvdata内のレコード数を出力します。
%
%   [interlace,status] = hdfvs('Queryinterlace',vdata_id)
%   指定したvdataのinterlaceモードを出力します。
%
%   vsize = hdfvs('Queryvsize',vdata_id)
%   指定したvdataのレコードのローカルサイズをバイト単位で取得します。
%   
%   [field_index,status] = hdfvs('findex',vdata_id,fieldname)
%   与えられたフィールド名をもつvdataのフィールドのインデックスを確認しま
%   す。
%
%   status = hdfvs('setattr',vdata_id,field_index,name,A)
%   vdataのフィールドまたはvdataの属性を設定します。field_index は、インデ
%   ックス番号または 'vdata' です。
%
%   count = hdfvs('nattrs',vdata_id)
%   指定したvdataとその中に含まれるvdataのフィールドの属性数を出力します。
% 
%   count = hdfvs('fnattrs',vdata_id,field_index)
%   vdataの属性の総数を確認します。
%
%   attr_index = hdfvs('findattr',vdata_id,field_index,attr_name)
%   与えられた属性名をもつ属性のインデックスを取得します。
%
%   tf = hdfvs('isattr',vdata_id)
%   与えられたvdataが属性かどうかを指定します。
%
%   [name,data_type,count,nbytes,status] = .....
%                   hdfvs('attrinfo',vdata_id,field_index,attr_index)
%   指定したvdataのフィールドまたはvdataの指定した属性の名前、データ
%   タイプ、値の個数、値のサイズを出力します。
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH.


%   Copyright 1984-2001 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:57:05 $
