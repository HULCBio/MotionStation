% HDFSD   
% HDFマルチファイル科学技術データセットインタフェースのMATLABゲートウェイ
% 
% HDFSDは、HDFマルチファイル科学技術データセットインタフェース(SD)の
% ゲートウェイです。この関数を使うためには、HDF version 4.1r3のUser's Guide
% とReference Manualに含まれている、SDインタフェースに関する情報について
% 知っていなければなりません。このドキュメントは、National Center for 
% Supercomputing Applications (NCSA、<http://hdf.ncsa.uiuc.edu>)から得る
% ことができます。
%
% HDFSDに対する一般的なシンタックスは、HDFSD(funcstr,param1,param2,...)
% です。HDFライブラリ内のSD関数と、funcstrに対する有効な値は、1対1で対応
% します。たとえば、HDFSD('endaccess',sds_id) は、Cライブラリコール
% SDendaccess(sds_id) に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% SD_id は、マルチファイル科学技術データセットインタフェースの識別子を参
% 照します。sds_id は、個々のデータセットの識別子を参照します。
% hdfsd('end',SD_id) または hdfsd('endaccess',sds_id) を使って、すべてのオープ
% ンしている識別子へのアクセスを終了しなければなりません。そうでなければ、
% HDFライブラリは、すべてのデータを正常にファイルに書き出しません。 
% 
% HDFファイルは、多次元配列に対するCスタイルの順序付けを用います。一方、
% MATLABはFORTRANスタイルの順序付けを用います。これは、HDFデータ
% フィールドの定義された次元の大きさに対して、MATLAB配列の大きさが、転置
% されなければならないことを意味しています。たとえば、グリッドフィールドが、
% 3 x 4 x 5 で定義されている場合は、DATAは 5 x 4 x 3 の大きさでなければな
% りません。PERMUTE コマンドは、ここで必要な変換を行うためのコマンドです。
% 
% ある入力に対して、NULLを受け入れるHDF Cライブラリでは、空行列([])が使
% われます。
% 
% アクセスに関する関数
% --------------------
% アクセスに関する関数は、HDFファイルとデータセットのアクセスを初期化し、
% 終了します。
%
%   status = hdfsd('end',SD_id)
%   対応するファイルへのアクセスを終了します。
%
%   status = hdfsd('endaccess',sds_id)
%   対応するデータセットへのアクセスを終了します。
%
%   sds_id = hdfsd('select',SD_id、sds_index)
%   指定したインデックスをもつデータセットの識別子を出力します。
%
%   SD_id = hdfsd('start',filename,access_mode)
%   特定のファイルに対するSDインタフェースを初期化します。
%   access_mode は、'read', 'write', 'create', 'rdwr', 'rdonly' の
%   いずれかです。
% 
% 読み込みと書き出しに関する関数
% ------------------------------
% 読み込みと書き出しに関する関数は、次元、ランク、データタイプを操作して、
% データセットの読み込みと書き出しを行います。
%
%   sds_id = hdfsd('create',SD_id,name,data_type,rank,dimsizes)
%   新しいデータセットを作成します。
%
%   [data,status] = hdfsd('readdata',sds_id,start,stride,edge)
%   チャンク化されたデータセットまたはチャンク化されていないデータセット
%   から、データを読み込みます。注意：ベクトルの始点の座標は、1ベースでは
%   なく、0ベースでなければなりません。
% 
%   status = hdfsd('setexternalfile', sds_id, filename, offset)
%   外部ファイルに保存されるデータタイプを定義します。
%
%   status = hdfsd('writedata',sds_id, start, stride, edge, data)
%   チャンク化されたデータセットまたはチャンク化されていないデータセットに、
%   データを書き出します。
%   注意：データのクラスは、HDFデータセットに対して、定義されるHDFの数値タ
%   イプと一致しなければなりません。MATLAB文字列は、自動的に、HDF charタ
%   イプのいずれかに一致するように変換されます。そして、他のデータタイプは、
%   厳密な意味で一致しなければなりません。
% 
% 注意：
% ベクトルの始点の座標は、1ベースではなく、0ベースでなければなりません。
% 
% 一般情報に関する関数
% --------------------
% 一般情報に関する関数は、HDFファイル内の科学技術データの位置、内容、
% 記述に関する情報を出力します。
%
%   [ndatasets,nglobal_attr,status] = hdfsd('fileinfo',SD_id)
%   ファイルの内容に関する情報を出力します。
%
%   [name,rank,dimsizes,data_type,nattrs,status] = hdfsd('getinfo',...
%                   sds_id)
%   データセットに関する情報を出力します。
%
%  ref = hdfsd('idtoref',sds_id)
%   指定したデータセットに対応する参照番号を出力します。
%
%   tf = hdfsd('iscoordvar',sds_id)
%   データセットと次元のスケールを区別します。
%
%   idx = hdfsd('nametoindex',SD_id,name)
%   名前付けられたデータセットのインデックスの値を出力します。
%
%   sds_index = hdfsd('reftoindex',SD_id,ref)
%   与えられた参照番号に対応する、データセットのインデックスを出力します。
% 
% 次元のスケールに関する関数
% --------------------------
% 次元のスケールに関する関数は、データセット内で次元のスケールを定義し、
% アクセスします。
%
%   [name,count,data_type,nattrs,status] = hdfsd('diminfo',dim_id)
%   次元に関する情報を取得します。
%
%   dim_id = hdfsd('getdimid',sds_id,dim_number)
%   次元の識別子を取得します。
%
%   status = hdfsd('setdimname',dim_id,name)
%   名前と次元を対応付けます。
%
%   [scale,status] = hdfsd('getdimscale',dim_id)
%   次元に対するスケール値を出力します。
%
%   status = hdfsd('setdimscale',dim_id,scale)
%   次元の値を定義します。
%
% ユーザ定義の属性に関する関数
% ----------------------------
% ユーザ定義の属性に関する関数は、HDFユーザが定義したHDFファイル、
% データセット、次元の特性を記述し、アクセスします。
%
%   [name,data_type,count,status] = hdfsd('attrinfo',id,attr_idx)
%  属性に関する情報を取得します。id は、SD_id、sds_id、dim_id のいずれかです。
% 
%   attr_index = hdfsd('findattr',id,name)
%   指定したインデックスを出力します。id は、SD_id、sds_id、dim_id の
%   いずれかです。
%
%   [data,status] = hdfsd('readattr',id,attr_index)
%   指定した属性の値を読み込みます。id は、SD_id、sds_id、dim_id の
%   いずれかです。
%
%   status = hdfsd('setattr',id,name,A)
%   新たな属性を作成し、定義します。id は、SD_id、sds_id、dim_id の
%   いずれかです。
%
% 既に定義された属性に関する関数
% ------------------------------
% 既に定義された属性に関する関数は、既に定義したHDFファイル、データセッ
% ト、次元の特性にアクセスします。
%
%   [cal,cal_err,offset,offset_err,data_type,status] = .....
%              hdfsd('getcal',sds_id)
%   キャリブレーションの情報を出力します。
%
%   [label,unit,format,coordsys,status] = ....
%                  hdfsd('getdatastrs',sds_id,maxlen)
%   データセットのラベル、範囲、書式、座標系を出力します。
%
%   [label,unit,format,status] = hdfsd('getdimstrs',dim_id)
%   指定した次元についての属性の文字列を出力します。
%
%   [fill,status] = hdfsd('getfillvalue',sds_id)
%   fillが存在すればその値を読み込みます。
%
%   [rmax,rmin,status] = hdfsd('getrange',sds_id)
%   指定したデータセットの値の範囲を出力します。
%
%   status = ....
%    hdfsd('setcal',sds_id,cal,cal_err,offset,offset_err,data_type)
%   キャリブレーションの情報を定義します。
%
%   status = hdfsd('setdatastrs',sds_id,label,unit,format,coordsys)
%   指定したデータセットの属性の文字列を定義します。
%
%   status = hdfsd('setdimstrs',dim_id,label,unit,format)
%   指定した次元の属性の文字列を定義します。
%
%   status = hdfsd('setfillvalue',sds_id,value)
%   指定したデータセットのfillの値を定義します。
%
%   status = hdfsd('setfillmode',SD_id,mode)
%   指定したファイルの、すべての科学技術データセットに適用されるfillモード
%   を定義します。
%
%   status = hdfsd('setrange',sds_id,max,min)
%   有効な範囲の最大値と最小値を定義します。
%
% 圧縮関数
% --------
% 圧縮関数は、科学技術データセットの圧縮方法を指定します。
%
%   status = hdfsd('setcompress',SD_id,comp_type,...)
%   データセットに適用される圧縮方法を定義します。comp_type は、'none',
%   'jpeg', 'rle', 'deflate', 'skphuff' のいずれかです。
%
%   圧縮方法の中には、追加のパラメータと値の組合わせを与えなければならな
%    い方法があります。このルーチンは、つぎのパラメータと値の組合わせを解釈
%    します。
% 
%       'jpeg_quality'        、整数
%       'jpeg_force_baseline' 、整数
%       'skphuff_skp_size'    、整数
%       'deflate_level'       、整数
%
% チャンクとタイルに関する関数
% ----------------------------
% チャンクとタイルに関する関数は、SDSデータに対するチャンクの構成を指定
% します。
%
%   [chunk_lengths,chunked,compressed,status] = ....
%                           hdfsd('getchunkinfo',sds_id)
%   チャンク化されている科学技術データセットに関する情報を取得します。SDS
%   がチャンク化または圧縮されている場合、チャンク化または圧縮は1(真)です。
%
%   status = hdfsd('setchunkcache',sds_id,maxcache,flags)
%   チャンクキャッシュのサイズを設定します。
%
%   status = hdfsd('setchunk',sds_id,chunk_lengths,comp_type,...)
%   チャンク化されていない科学技術データセットを、チャンク化された科学技術
%   データセットに変更します。
%
%   comp_type は、'none', 'jpeg', 'rle', 'deflate', 'skphuff' のいずれかです。
%   'none' は、HDF_CHUNK を、他の値は HDF_CHUNK | HDF_COMP を示しま
%   す。この方法の中には、追加のパラメータと値の組合わせを与えなければなら
%   ない方法があります。このルーチンは、つぎのパラメータと値の組合わせを解
%   釈します。 
%       'jpeg_quality'        、整数
%       'jpeg_force_baseline' 、整数
%       'skphuff_skp_size'    、整数
%       'deflate_level'       、整数
%
%   status = hdfsd('writechunk',sds_id,origin,data)
%   データをチャンク化された科学技術データセットに書き出します。
%
%   [data,status] = hdfsd('readchunk',sds_id,origin)
%   データをチャンク化された科学技術データセットから読み込みます。
%
% Nビットデータセットに関する関数
% -------------------------------
% Nビットデータセットに関する関数は、科学技術データセットのデータに対す
% る、非標準データビット長を指定します。
%
%   status = ....
%    hdfsd('setnbitdataset',sds_id,start_bit,bit_len,sign_ext,fill_one)
%   データセットのデータの非標準ビット長を定義します。
%
% 参考：HDF, HDFAN, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:59 $
