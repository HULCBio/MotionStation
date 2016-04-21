% HDFPT   HDF-EOS PointオブジェクトへのMATLABインタフェース
%
% HDFPTは、HDF-EOS PointオブジェクトへのMATLABインタフェースです。HDF-
% EOSは、NCSA(National Center for Supercomputing Applications) HDF (Hi-
% erarchical Data Format)の拡張です。HDF-EOSは、EOS (Earth Observing 
% System)に対するベースライン標準としてNASAが選択する科学データフォーマ
% ット標準です。
% 
% HDFPTは、HDF-EOS CライブラリのPoint関数のゲートウェイで、EOSDIS (Earth
% Observing System Data and Information System)によって開発され維持され
% ています。Pointデータセットは、(もしかしたら)不規則な時間間隔や、散在
% する地理的な位置で得られたデータレコードを含みます。各データレコードは、
% 時間または空間でのある点の状態を表わす1つまたは複数のデータ値の集合で
% 構成されます。
% 
% このヘルプの情報に加え、ユーザはつぎのドキュメントを参考にしてください。
% 
%       HDF-EOS Library User's Guide for the ECS Project,
%       Volume 1: Overview and Examples; Volume 2: Function
%       Reference Guide 
% 
% このドキュメントは、つぎのwebから利用できます。
%   
%       http://hdfeos.gsfc.nasa.gov
%   
% このサイトからドキュメントを取得できない場合、MathWorks Technical Su-
% pport(support@mathworks.com)にご連絡ください。
% 
% シンタックスの使い方
% ------------------
% HDF-EOS CライブラリとHDFPT シンタックスの中でPoint関数間で1対1マッピン
% グが存在します。たとえば、Cライブラリは、与えたレベルインデックスに対
% 応したレベル名を得るために、つぎの関数を用意しています。
% 
%       intn PTgetlevelname(int32 pointid, int32 level, 
%                           char *levelname, int32 *strbufsize)
% 
% 等価なMATLABシンタックスは、つぎのようになります。
% 
%       [LEVELNAME,STATUS] = HDFPT('getlevelname',POINTID,LEVEL)
% 
% LEVELNAMEは、文字列です。STATUSは(成功の場合)0、(失敗の場合)-1のいずれ
% かになります。
% 
% いくつかのCライブラリ関数は、Cマクロで定義された入力値を受け入れます。
% たとえば、C PTopen()関数は、DFACC_READ、DFACC_RDWR、または
% DFACC_CREATEになるアクセスモード入力を必要とします。ここで、これらのシ
% ンボルは、適切なCヘッダファイルの中に定義されています。マクロの定義が
% Cライブラリの中で使われる部分で、等価なMATLABシンタックスは、マクロ名
% から得られる文字列を使います。ユーザは、マクロ名全体を含む文字列を使用
% したり、あるいは共通する接頭語を省略することもできます。また、大文字も
% 小文字も使用することができます。たとえば、つぎのC関数の呼び出し
% 
%       status = PTopen("PointFile.hdf",DFACC_CREATE)
% 
% は、つぎのMATLAB関数呼び出しと等価です。  
% 
%       status = hdfpt('open','PointFile.hdf','DFACC_CREATE')
%       status = hdfpt('open','PointFile.hdf','dfacc_create')
%       status = hdfpt('open','PointFile.hdf','CREATE')
%       status = hdfpt('open','PointFile.hdf','create')
% 
% C関数がマクロ定義からの値を出力する場合、等価なMATLAB関数は、マクロ
% を小文字で表わした短縮形を含む文字列として値を出力します。
% 
% HDF番号のタイプは、'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8','uint16', 
% 'uint32', 'float', 'int8', 'int16', 'int32'を含む文字列で定義されます。
%
% HDF-EOSライブラリがNULLを受け入れる場合、空行列([])が使われます。
% 
% ほとんどのルーチンは、ルーチンが成功した場合は0、失敗した場合-1を、フ
% ラグ STATUS に出力します。STATUS を含まないシンタックスをもつルーチン
% は、つぎの関数のシンタックスでの記述で行っているような、出力の中に失敗を
% 意味する情報を出力します。
% 
% プログラミングモデル
% -----------------
% 
% HDFPTを使ったポイントデータセットをアクセスするプログラミングモデルは、
% つぎのようになります。
% 
% 1. ファイルをオープンし、ファイル名からファイルidを得ることで、PTイン
%    タフェースを初期化します。
% 2. ポイント名からポイントidを得ることによりポイントデータセットをオー
%    プンするか、作成します。
% 3. データセット上で希望する演算を実行します。
% 4. ポイントidを設定して、ポイントデータセットをクローズします。
% 5. ファイルidを設定して、ファイルへのアクセスを終了します。
% 
% HDF-EOSファイル内に既に存在している単一のポイントデータセットにアクセス
% するため、つぎのMATLABコマンドを使います。
% 
%       fileid = hdfgd('open',filename,access);
%       pointid = hdfgd('attach',fileid,pointname);
% 
%       % データセット上にオプションの演算を適用
% 
%       status = hdfgd('detach',pointid);
%       status = hdfgd('close',fileid);
% 
% 同時に複数のファイルにアクセスするためには、オープンする各ファイルの
% ファイル識別子を個々に取得します。複数のポイントデータセットにアクセス
% するためには、各データセットに対する個々のポイントidを取得します。
% 
% バッファされた操作がディスクに完全に書き込まれるように、ポイントidと
% ファイルidを適切に破棄することが重要です。MATLABを終了するか、オープン
% したままのPT識別子をもつすべてのMEX-ファイルを消去すると、MATLABはワ
% ーニングを表示し、自動的にこれらを破棄します。
% 
% HDFPTで出力されるファイル識別子は、他のHDF-EOSまたはHDF関数で出力
% されるファイル識別子と互換性がないことに注意してください。
% 
% 関数のカテゴリ
% -------------------
% ポイントデータセットルーチンは、つぎのカテゴリに分類されます。
% 
%     - アクセスルーチンは、PTインタフェースやポイントデータセットへのアクセス
%        (ファイルのオープンとクローズを含む)を初期化および終了します。
% 
%     - 定義ルーチンは、ポイントデータセットの主要部分を設定します。
% 
%     - 基本I/Oルーチンは、ポイントデータセットのデータやメタデータの読み込み
%       および書き出しを行います。
% 
%     - Index I/O ルーチンは、あるポイントデータセットの中に2つのテーブ
%       ルをリンクする情報を読み込んだり書き出します。
% 
%     - 質問(Inquiry)ルーチンは、ポイントデータセット内に含まれるデータ
%       に関する情報を出力します。
% 
%     - サブセットルーチンは、設定した幾何的な領域からデータを読み取りま
%       す。
% 
% アクセスルーチン
% ---------------
% PTopen
%      FILE_ID = HDFPT('open',FILENAME,ACCESS)
%      ファイル名と希望するアクセスモードを与えて、ポイントを作成、読み込み、
%      書き出しを行うためにHDFファイルをオープンまたは作成します。ACCESS
%      には、'read', 'readwrite', 'create' のいずれかを使用できます。FILE_IDは、
%      操作が失敗すると-1になります。
% 
% PTcreate
%      POINT_ID = HDFPT('create',FILE_ID,POINTNAME)
%      指定した名前をもつポイントデータセットの作成。POINTNAME は、ポイント
%      データセットの名前を含む文字列です。POINT_ID は、操作が失敗した場
%      合は-1です。
% 
% PTattach
%      POINT_ID = HDFPT('attach',FILE_ID,POINTNAME)
%      ファイル内に存在するポイントデータセットにアタッチします。POINT_ID は、
%      演算が失敗した場合は-1です。
% 
% PTdetach
%      STATUS = HDFPT('detach',POINT_ID)
%      ポイントデータセットから切り取ります。
% 
% PTclose
%      STATUS = HDFPT('close', FILE_ID)
%      ファイルをクローズします。
% 
% 定義に関するルーチン
% -------------------
% PTdeflevel
%    STATUS = HDFPT('deflevel',POINT_ID,LEVELNAME,...
%                  FIELDLIST,FIELDTYPES,FIELDORDERS)
%    ポイントデータセット内で新しいレベルを定義します。LEVELNAMEは、定義す
%    るレベルの名前です。FIELDLISTは、新しいレベルの中で、カンマで区切られ
%    たフィールド名のリストを含む文字列です。FIELDTYPESは、各フィールドに対
%    する数字タイプ文字列を含むセル配列です。使用できる数字タイプは、
%    'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8', 'uint16', 'uint32', 'float', 
%    'int8', 'int16', 'int32'を含む文字列です。FIELDORDERS は、各フィールドに対
%    する順番を含むベクトルです。
% 
% PTdeflinkage
%     STATUS = HDFPT('deflinkage',POINT_ID,PARENT,...
%                         CHILD,LINKFIELD)
%     2つの隣り合ったレベル間のリンクフィールドを定義します。PARENT は、親
%     レベルの名前です。CHILD は、子レベルの名前です。LINKFILED は、2つ
%     のレベルで定義されたフィールドの名前です。
% 
% 基本的な I/O ルーチン
% ------------------
% PTwritelevel
%     STATUS = HDFPT('writelevel',POINT_ID,LEVEL,DATA)
%     ポイントデータセットの中に指定したレベルに新しいレコードを付加します。
%     LEVEL は、希望するレベルインデックス(ゼロベース)です。DATA は、P行1
%     列のセル配列で、P は指定したレベルに対して定義されたフィールド数で
%     す。DATA の各々のセルは、データの M(k) 行 N 列の行列を含んでいます。
%     ここで、M(k) は k 番目のフィールドの次数(フィールド内のスカラ値の数)で、
%     N はレコード数です。セルのMATLABクラスは、対応するフィールドに対して
%     定義されたHDFデータタイプに一致していなければなりません。MATLAB文
%     字列は、HDF charタイプのいずれかに一致するように自動的に変換されま
%     す。他のデータタイプは、厳密な意味で一致していなければなりません。
%   
% PTreadlevel
%     [DATA,STATUS] = HDFPT('readlevel',POINT_ID,LEVEL,FIELDLIST,RECORDS)
% 
%     ポイントデータセット内に与えられたレベルからデータを読みます。LEVEL
%     は、希望するレベルの(ゼロベースの)インデックスです。FIELDLISTは、読み
%     込むフィールドをカンマの区切りを使ったリストを含む文字列です。
%      RECORDS は、読み込まれるレコードの(ゼロベースの)インデックスを含む
%     ベクトルです。DATAは、P行1列のセル配列で、P は要求されるフィールド数
%     です。DATA の各々のセルは、データの M(k) 行 N 列の行列を含んでいま
%     す。ここで、M(k) は k 番目のフィールドの次数で、N はレコード数かまたは
%     LENGTH(RECORDS) のいずれかです。
% 
% PTupdatelevel
%      STATUS = HDFPT('updatelevel',POINT_ID,LEVEL,...
%                         FIELDLIST,RECORDS,DATA)
%      ポイントデータセットの特定のレベルの中のデータを更新(正しく)します。
%      LEVEL は、希望するレベルの(ゼロベースの)インデックスです。FIELDLIST
%      は、更新するフィールドのカンマで区切られたリストを含む文字列です。
%      DATA は、P行1列のセル配列で、P は指定したフィールドの数です。DATA
%      の各々のセルは、データの M(k) 行 N 列の行列を含んでいます。ここで、
%      M(k) は k 番目のフィールドの次数で、N はレコード数かまたは
%      LENGTH(RECORDS) のいずれかです。セルのMATLABクラスは、対応する
%      フィールドに対して定義されたHDFデータタイプと一致していなければなりま
%      せん。MATLAB文字列は、HDFcharタイプのいずれかに一致するように自動
%      的に変換されます。他のデータタイプは、厳密な意味で一致していなければ
%      なりません。
% 
% PTwriteattr
%      STATUS = HDFPT('writeattr',POINT_ID,ATTRNAME,DATA)
%      指定した名前の属性をもつポイントデータを書き込むか、または更新しま
%      す。属性が既に存在していない場合は、作成します。
% 
% PTreadattr
%      [DATA,STATUS] = HDFPT('readattr',POINT_ID,ATTRNAME)
%      設定した属性から、それに帰属するデータを読み込みます。
% 
% Inquiry ルーチン
% ----------------
% PTnlevels
%      NLEVELS = HDFPT('nlevels',POINT_ID)
%      ポイントデータセットの中のレベル数を出力します。演算に失敗した場合、
%      NLEVELS は-1になります。
% 
% PTnrecs
%      NRECS = HDFPT('nrecs',POINT_ID,LEVEL)
%      指定したレベルの中のレコード数を出力します。演算に失敗した場合、
%      NRECS は-1になります。
% 
% PNnfields
%      [NUMFIELDS,STRBUFSIZE] = HDFPT('nfields',POINT_ID,LEVEL)
%      指定したレベルの中のフィールド数を出力します。STRBUFSIZE は、カンマ
%      で区切られたフィールド名の文字列の長さです。演算に失敗した場合、
%      NUMFIELDS は-1、STRBUFSIZE は [] になります。
% 
% PTlevelinfo
%      [NUMFIELDS,FIELDLIST,FIELDTYPE,FIELDORDER] = ...
%                        HDFPT('levelinfo',POINT_ID,LEVEL)
%      指定したレベルに対するフィールドに関する情報を出力します。FIELDLIST
%      は、更新するフィールドのカンマで区切られたリストを含む文字列です。
%      FIELDTYPE は、各々のフィールドと関連する(スカラ値の数)次数を含むベク
%      トルです。演算に失敗した場合、NUMFIELDS は-1、他の出力は空になりま
%      す。
% 
% PTlevelindx
%      LEVEL = HDFPT('levelindx',POINT_ID,LEVELNAME)
%      指定した名前をもつレベルの(ゼロベースの)レベルインデックスを出力しま
%      す。演算に失敗した場合、LEVEL は-1になります。
% 
% PTbcklinkinfo
%      [LINKFIELD,STATUS] = HDFPT('bcklinkinfo',POINT_ID,LEVEL)
%     前のレベルへのリンクフィールドを出力します。演算に失敗した場合、
%     STATUS は-1、LINKFIELD は [] になります。
% 
% PTfwdlinkinfo
%      [LINKFIELD,STATUS] = HDFPT('fwdlinkinfo',POINT_ID,LEVEL)
%     つぎのレベルへのリンクフィールドを出力します。演算に失敗した場合、
%     STATUS は-1、LINKFIELD は [] になります。
% 
% PTgetlevelname
%      [LEVELNAME,STATUS] = HDFPT('getlevelname',POINT_ID,LEVEL)
%     レベルインデックスを与えて、レベルの名前を出力します。演算に失敗した
%     場合、STATUS は-1、LEVELNAME は [] になります。
% 
%   PTsizeof
%      [BYTESIZE,FIELDLEVELS] = HDF('sizeof',POINT_ID,FIELDLIST)
%     指定したフィールドのフィールドレベルとバイト数を出力します。FIELDLIST
%     は、カンマで区切られたフィールド名を含む文字列です。BYTESIZE は指
%     定したフィールドのバイト数の総数で、FIELDLEVELS は各フィールドに対応
%     したレベルインデックスを含むベクトルです。演算が失敗した場合、
%     BYTESIZE は-1で、FIELDLEVELS は [] になります。
% 
% PTattrinfo
%      [NUMBERTYPE,COUNT,STATUS] = HDFPT('attrinfo',POINT_ID,ATTRNAME)
%     指定した属性のバイト数で表わした大きさと数値タイプを出力します。
%     ATTRNAME は、属性の名前です。NUMBERTYPE は、属性のHDFデータタ
%     イプに対応する文字列です。COUNT は、属性データで使われるバイト数で
%     す。演算が失敗した場合、STATUS は-1で、NUMBERTYPE と COUNT は
%     [] になります。
% 
% PTinqattrs
%      [NATTRS,ATTRNAMES] = HDFPT('inqattrs',POINT_ID)
%      ポイントデータセットの中に定義している属性に関する情報を出力します。
%      NATTRS と ATTRNAMES は、定義されたすべての属性の数と名前をそれ
%      ぞれ示します。演算が失敗した場合、NUMPOINTS は-1で、ATTRNAMES
%      は [] です。
% 
% PTinqpoint
%      [NUMPOINTS,POINTNAMES] = HDFPT('inqpoint',FILENAME)
%      HDF-EOSファイル内に定義されているポイントデータセットの数と名前を出
%      力します。POINTNAMES は、カンマで区切られたポイント名を含む文字列
%      です。演算が失敗した場合、NUMPOINTS は-1で、POINTNAMES は [] で
%      す。
% 
% ユーティリティルーチン
% ----------------
% PTgetrecnums
%      [OUTRECORDS,STATUS] = HDFPT('getrecnums',...
%                           POINT_ID,INLEVEL,OUTLEVEL,INRECORDS)
%      レベル INLEVEL 内の INRECORDS により指定されるレコード群に対応す
%      る OUTLEVEL 内のレコード数を出力します。INLEVEL や OUTLEVEL は、
%      ゼロベースのレベルインデックスです。INRECORDS は、ゼロベースのレ
%      コードインデックスのベクトルです。演算が失敗した場合、STATUS は-1
%      で、OUTRECORDS は [] になります。
% 
% サブセットルーチン
% ---------------
% PTdefboxregion
%      REGION_ID = HDFPT('defboxregion',POINT_ID,...
%                            CORNERLON,CORNERLAT)
%      あるポイントに対する経度-緯度ボックス領域を定義します。CORNERLON
%      は、ボックスの反対側の隅の経度を含む2要素ベクトルです。CORNERLAT
%      は、ボックスの反対側の隅の緯度を含む2要素ベクトルです。演算が失敗し
%      た場合、REGION_ID は-1になります。
% 
% PTdefvrtregion
%      PERIOD_ID = HDFPT('defvrtregion',POINT_ID,REGION_ID,,...
%                            VERT_FIELD,RANGE)
%      ポイントに対する垂直領域を定義します。VERT_FIELD は、サブセット化した
%      フィールド名です。RANGE は、垂直値の最小値と最大値を含む2要素ベクト
%      ルです。演算が失敗した場合、PERIOD_ID は-1になります。
% 
% PTregioninfo
%      [BYTESIZE,STATUS] = HDFPT('regioninfo',POINT_ID,...
%                           REGION_ID,LEVEL,FIELDLIST)
%     指定したレベルのサブセット化された領域のデータサイズをバイト単位で出
%     力します。FIELDLIST は、カンマで区切られた抽出されるフィールドを含む文
%     字列です。演算が失敗した場合、STATUS と BYTESIZE は-1になります。
% 
% PTregionrecs
%      [NUMREC,RECNUMBERS,STATUS] = HDFPT('regionrecs',...
%                                     POINT_ID,REGION_ID,LEVEL)
%     指定したレベルのサブセット化された領域内のレコード番号を出力します。
%     演算が失敗した場合、STATUS と NUMREC は-1で、RECNUMBERS は []
%     になります。
% 
% PTextractregion
%      [DATA,STATUS] = HDFPT('extractregion',POINT_ID,...
%                                REGION_ID,LEVEL,FIELDLIST)
%     指定したサブセット領域からデータを読み込みます。FIELDLIST は、要求さ
%     れるフィールドのカンマで区切られたリストを含む文字列です。DATA は、P
%     行1列のセル配列で、P は要求されるフィールド数です。DATA の各セル
%     は、データの M(k) 行 N 列の行列を含んでいます。ここで、M(k) は k 番目
%     のフィールドの次数で、N はレコード数です。演算が失敗した場合、
%     STATUS が-1で、DATA は [] になります。
% 
% PTdeftimeperiod
%      PERIOD_ID = HDFPT('deftimeperiod',POINT_ID,...
%                            STARTTIME,STOPTIME)
%      ポイントデータセットに対する時間周期を定義します。演算が失敗した場
%      合、PERIOD_ID は-1になります。
% 
% PTperiodinfo
%      [BYTESIZE,STATUS] = HDFPT('periodinfo',POINT_ID,...
%                           PERIOD_ID,LEVEL,FIELDLIST)
%     サブセット化された周期をバイト数で表わした大きさを出力します。
%     FIELDLISTは、カンマで区切られた希望するフィールド名のリストを含む文字
%     列です。演算が失敗した場合、BYTESIZE と STATUS は-1になります。
% 
% PTperiodrecs
%      [NUMREC,RECNUMBERS,STATUS] = HDFPT('periodrecs',...
%                             POINT_ID,PERIOD_ID,LEVEL)
%     指定したレベルのサブセット化された時間周期内でのレコード数を出力しま
%     す。演算が失敗した場合、NUMREC と STATUS は-1になります。
% 
% PTextractperiod
%      [DATA,STATUS] = HDFPT('extractregion',...
%                       POINT_ID,REGION_ID,LEVEL,FIELDLIST)
%     指定したサブセット化された時間周期からデータを読みます。FIELDLIST 
%     は、カンマで区切られた要求されたフィールドリストを含む文字列です。
%     DATA は、P行1列のセル配列で、P は要求されるフィールドの数です。
%     DATA の各々のセルは、データの M(k) 行 N 列の行列を含み、M(k) は k 
%     番目の次数、N はレコード数です。演算が失敗した場合、STATUS は-1で、
%     DATA は [] になります。
% 
% 実際の処理は、HDF.MEXをコールします。
%   
% 参考：HDF, HDFSW, HDFGD.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:57 $
% 

