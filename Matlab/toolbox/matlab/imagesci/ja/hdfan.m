% HDFAN   HDFマルチファイルアノテーションインタフェースのMATLABゲート
%         ウェイ
% 
% HDFAN は、HDFマルチファイルアノテーション(AN)インタフェースのゲート
% ウェイです。この関数を使うためには、HDF version 4.1r3のUser's Guideと
% Reference Manualに含まれている、ANインタフェースについての情報について
% 知っていなければなりません。このドキュメントは、National Center for 
% Supercomputing Applications (NCSA,<http://hdf.ncsa.uiuc.edu>)から得る
% ことができます。
%
% HDFAN に対する一般的なシンタックスは、HDFAN(funcstr,param1,param2,...)
% です。HDFライブラリ内のAN関数と、funcstr に対する有効な値は、1対1で
% 対応します。たとえば、HDFAN('endaccess',annot_id) は、Cライブラリコール
% ANendaccess(annot_id)に対応します。
%
% シンタックスの使い方
% --------------------
% ステータスまたは識別子の出力が-1のとき、操作が失敗したことを示します。
% 
% 入力変数 annot_type は、一般的につぎの文字列のうちのいずれかです。
% 
%   'file_label'、'file_desc'、'data_label'、'data_desc'.
%
% AN_id は、マルチファイルアノテーションインタフェースの識別子を参照します。
% annot_id は、個々のアノテーションの識別子を参照します。hdfan('end',AN_id)
% または hdfan('endaccess',annot_id)を使って、すべてのオープンしている
% 識別子へのアクセスの終了を確認しなければなりません。そうでなければ、
% HDFライブラリはすべてのデータを正常にファイルに書き出しません。
% 
% アクセス関数
% ------------
% アクセス関数は、インタフェースを初期化し、アノテーションへのアクセスを
% 終了します。ANのアクセス関数に対するHDFANのシンタックスは、つぎの
% ようになります。
%
%     AN_id = hdfan('start'、file_id)
%     マルチファイルアノテーションインタフェースを初期化します。
%
%     annot_id = hdfan('select'、AN_id、index、annot_type)
%     与えられたインデックス値とアノテーションのタイプによって識別される
%     アノテーションに対する識別子を選択し、出力します。
%
%     status = hdfan('end'、AN_id)
%     マルチファイルアノテーションインタフェースへのアクセスを終了します。
%
%     annot_id = hdfan('create'、AN_id、tag、ref、annot_type)
%     指定したタグと参照番号で識別されるオブジェクトに対するデータの
%     アノテーションを作成します。annot_type は、'data_label' または 
%     'data_desc' です。 
%
%     annot_id = hdfan('createf'、AN_id、annot_type)
%     ファイルのラベルまたはファイルの説明のアノテーションを作成します。
%     annot_type は、'file_label' または 'file_desc' です。
%
%     status = hdfan('endaccess'、annot_id)
%     アノテーションへのアクセスを終了します。
%
% 読み出しと書き込みに関する関数
% ------------------------------
% 読み込みと書き出しに関する関数は、ファイルまたはオブジェクトのアノ
% テーションの読み込みと書き出しを行います。ANの読み込みと書き出し関数に
% 対する HDFAN のシンタックスは、つぎのようになります。
%
%     status = hdfan('writeann'、annot_id、annot_string)
%     与えられたアノテーション識別子に対応するアノテーションを書き出します。
%
%     [annot_string, status] = hdfan('readann', annot_id)
%     [annot_string、status] = hdfan('readann'、annot_id、max_str_length)
%    与えられたアノテーション識別子に対応するアノテーションを読み込みます。
%     max_str_length はオプションです。max_str_length が与えられた場合は、
%     annot_string は、max_str_lengthより長くてはいけません。
%
% 一般情報に関する関数
% --------------------
% 一般情報に関する関数は、ファイル内のアノテーションに関する情報を出力し
% ます。ANの一般情報関数に対するHDFANのシンタックスは、つぎのように
% なります。
%
%     num_annot = hdfan('numann'、AN_id、annot_type、tag、ref)
%     与えられたタグと参照番号の組合わせに対応する、指定したタイプのアノ
%     テーションの数を取得します。
%
%     [ann_list、status] = hdfan('annlist'、AN_id、annot_type、tag、ref)
%     与えられたタグと参照番号の組合わせに対応する、ファイル内の与えられた
%     タイプのアノテーションのリストを取得します。
%
%     length = hdfan('annlen'、annot_id)
%     与えられたアノテーションの識別子に対応する、アノテーションの長さを取得
%     します。
% 
%     [nfl、nfd、ndl、ndd、status] = hdfan('fileinfo'、AN_id)
%     AN_idに対応するファイル内の、ファイルラベル、ファイルの説明、データラ
%     ベル、データの説明のアノテーションを取得します。
%
%     [tag、ref、status] = hdfan('get_tagref'、AN_id、index、annot_type)
%     指定したアノテーションのタイプとインデックスに対する、タグと参照番号の
%     組合わせを取得します。
%
%     [tag、ref、status] = hdfan('id2tagref'、annot_id)
%     指定したアノテーションの識別子に対応する、タグと参照番号の組合わせを
%     取得します。
%
%     annot_id = hdfan('tagref2id'、AN_id、tag、ref)
%     指定したタグと参照番号の組合わせに対応する、アノテーションの識別子を
%     取得します。
%
%     tag = hdfan('atype2tag'、annot_type)
%     指定したアノテーションタイプに対応する、タグを取得します。
%
%     annot_type = hdfan('tag2atype'、tag)
%     指定したタグに対応する、アノテーションのタイプを取得します。
%
% 参考：HDF, HDFDF24, HDFDFR8, HDFH, HDFHD, HDFHE,
%       HDFML, HDFSD, HDFV, HDFVF, HDFVH, HDFVS.


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:47 $
