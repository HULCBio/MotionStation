% HDFSW   HDF-EOS SwathオブジェクトのMATLABインタフェース
%
% HDFSWは、HDF-EOS SwathオブジェクトのMATLABインタフェースです。
% HDF-EOSは、NCSA(National Center for Supercomputing Applications) HDF 
% (Hierarchical Data Format)の拡張です。HDF-EOSは、EOS (Earth Observing 
% System)に対するベースライン標準としてNASAが選択する科学データフォーマット
% 標準です。
% 
% HDFSWは、HDF-EOS CライブラリのSwath関数のゲートウェイで、EOSDIS 
% (Earth Observing System Data and Information System)によって開発され維持
% されています。swathデータセットは、データフィールド、geolocationフィールド
% 次元、次元マップで構成されます。データフィールドは、ファイルの生データ
% です。geolocationフィールドは、swathと地球の表面の特定の地点を結び付け
% るために使用されます。次元は、データの軸と地理的な位置フィールドを定義
% し、次元を表わすマップはデータの次元と地理的な位置フィールドの間の関係
% を定義します。ファイルは、swath全体で地理的な位置の情報が一定の間隔で
% 繰り返さない場合に、インデックスと言われる5番目の部分をオプションでも
% つことがあります(インデックスは、Landsat 7 data productsに対して設計さ
% れました)。
% 
% ここで述べた情報に加えて、つぎのドキュメントを参照することをお勧めしま
% す。
% 
%     HDF-EOS Library User's Guide for the ECS Project,
%     Volume 1: Overview and Examples; Volume 2: Function
%     Reference Guide 
% 
% このドキュメントは、つぎのwebから入手可能です。
% 
%     http://hdfeos.gsfc.nasa.gov
% 
% ここからドキュメントを入手できない場合は、MathWorks Technical Support
% に、お問い合わせください(support@mathworks.com)。
% 
% シンタックスの使い方
% --------------------
% HDF-EOS CライブラリのSwitch関数とHDFSWのシンタックスには、1対1の写像
% 関係があります。たとえば、Cライブラリは、特定の次元のサイズを得るための
% 関数を含みます。
% 
%     int32 SWdiminfo(int32 swathid、char *dimname)
% 
% 等価なMATLABの用法は、つぎの通りです。
% 
%     DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
% 
% SWATH_ID は、特定のswathデータセットの識別子(またはハンドル)です。
% DIMNAMEは、指定した次元名を含む文字列です。DIMSIZE は、指定した次元
% のサイズか、あるいは操作が失敗した場合は-1になります。
%
% Cライブラリ関数の中には、Cマクロで定義された入力値を受け入れるものが
% あります。たとえば、Cの関数 SWopen() は、DFACC_READ、DFACC_RDWR、
% DFACC_CREATEのいずれかであるアクセスモード入力を必要とします。ここで、
% これらのシンボルは、適切なCのヘッダファイルで定義されています。マクロの
% 定義がCライブラリで使用されているとき、等価なMATLABシンタックスは、マク
% ロ名から得られる文字列を使います。マクロ名全体を含む文字列を使用するこ
% とも、または共通の接頭語を省略することができます。大文字も小文字も使用
% することができます。たとえば、つぎのC関数呼び出し
% 
%     status = SWopen("SwathFile.hdf",DFACC_CREATE)
% 
% は、つぎのMATLAB関数呼び出しと等価です。
% 
%     status = hdfsw('open','SwathFile.hdf','DFACC_CREATE')
%     status = hdfsw('open','SwathFile.hdf','dfacc_create')
%     status = hdfsw('open','SwathFile.hdf','CREATE')
%     status = hdfsw('open','SwathFile.hdf','create')
% 
% C関数がマクロ定義からの値を出力する場合は、等価なMATLAB関数はマクロ
% を小文字で表わした短縮形を含む文字列として値を出力します。
%
% HDF 数値タイプは、つぎの文字列で指定されます。
% 
%    'uchar8'、'uchar'、'char8'、'char'、'double'、'uint8'、'uint16'、
%    'uint32'、'float'、'int8'、'int16'、'int32'.
%
% HDF-EOSライブラリがNULLを受け入れる場合は、空行列([])が使われます。
% 
% ほとんどのルーチンは、ルーチンが成功した場合0、失敗した場合-1を、フラ
% グ STATUS に出力します。STATUS を含まないシンタックスをもつルーチンは
% 以下の関数のシンタックスでの記述で行っているように、出力のうちの1つに、
% 失敗を意味する情報を出力します。
% 
% プログラミングモデル
% --------------------
% HDFSWを使ったswathデータセットへのアクセスのプログラミングモデルは、つぎ
% のようになります。
% 
% 1. ファイルをオープンし、ファイル名からファイルidを得ることでSWインタ
%    フェースを初期化します。
% 2. swath名からswath idを得ることによって、swathデータセットをオープン
%    または作成します。
% 3. データセットで希望する操作を行います。
% 4. swath idを破棄することによって、swathデータセットをクローズします。
% 5. ファイルidを破棄することによって、ファイルへのswathアクセスを終了し
%    ます。 
% 
% HDF-EOSファイル内の既存の単一のswathデータセットにアクセスするには、つ
% ぎのMATLABコマンドを使用します。
% 
%     fileid = hdfsw('open',filename,access);
%     swathid = hdfsw('attach',fileid,swathname);
% 
%     % データセットへのオプションの操作
% 
%     status = hdfsw('detach',swathid);
%     status = hdfsw('close',fileid);
% 
% 同時に複数のファイルにアクセスするためには、オープンする各ファイルの
% ファイル識別子を個々に取得します。複数のswathデータセットにアクセスする
% ためには、各データセットに対する個々のswath識別子を取得します。
% 
% バッファ化された操作がディスクに完全に書き込まれるように、swath idとファイ
% ルidを適切に破棄することが重要です。MATLABを終了するか、オープンし
% たままのSW識別子をもつすべてのMEX-ファイルを消去すると、MATLABはワー
% ニングを表示し、自動的にそれらを破棄します。
%
% HDFSWで出力されるファイル識別子は、他のHDFまたはHDF関数で出力さ
% れるファイル識別子と互換性がないことに注意してください。
% 
% 関数のカテゴリ
% --------------
% Swathデータセットのルーチンは、つぎのカテゴリに分類されます。
% 
% - アクセスルーチンは、SWインタフェースとswathデータセットへのアクセス
%   (ファイルのオープンとクローズを含む)を初期化および終了します。
% 
% - 定義ルーチンは、swathデータセットの主な機能を設定します。  
% 
% - 基本I/Oルーチンは、swathデータセットのデータやメタデータの読み込み
%   および書き出しを行います。
% 
% - 質問(Inquiry)ルーチンは、swathデータセット内に含まれるデータに関する情報
%   を出力します。
% 
% - サブセットルーチンは、指定した地理領域からデータの読み込みができます。
% 
% アクセスルーチン
% ----------------
% SWopen
%     FILE_ID = HDFSW('open',FILENAME,ACCESS)
%     FILENAME と希望するアクセスモードを与えて、swathデータセットの作成、
%     読み込み、書き出しのためにHDFファイルをオープンまたは作成します。
%     ACCESSは、'read'、'rdwr'、'create' のいずれかです。FILE_ID は、
%     操作が失敗した場合は-1です。
% 
% SWcreate
%     SWATH_ID = HDFSW('create',FILE_ID,SWATHNAME)
%     ファイル内にswathデータセットを作成します。SWATHNAME は、swathデータ
%     セット名を含む文字列です。SWATH_ID は、操作が失敗した場合は-1です。
%
% SWattach
%     SWATH_ID = HDFSW('attach',FILE_ID,SWATHNAME)
%     ファイル内の既存のswathデータセットにidを付けます。SWATH_IDは、操作が
%     失敗した場合は-1です。
%
% SWdetach
%     STATUS = HDFSW('detach',SWATH_ID)
%     swathデータセットからidを除去します。
%
% SWclose
%     STATUS = HDFSW('close',FILE_ID)
%     ファイルをクローズします。
% 
% 定義に関するルーチン
% --------------------
% SWdefdim
%     STATUS = HDFSW('defdim',SWATH_ID,FIELDNAME,DIM)
%     swath内の新規の次元を定義します。FIELDNAME は、定義される次元名を指定
%     する文字列です。DIM は、新規の次元のサイズです。制限のない次元を指定
%     するには、DIM は0または Inf のいずれかでなければなりません。
%
% SWdefdimmap
%     STATUS = ....
%       HDFSW('defdimmap',SWATH_ID,GEODIM,DATADIM,OFFSET,INCREMENT);
%     地理的な位置とデータの次元間の単調なマッピングを定義します。GEODIM は
%     地理的な位置の次元名で、DATADIM はデータの次元名です。OFFSET および
%     INCREMENT は、データの次元に対する地理的な位置の次元のオフセットと
%     増分を指定します。
% 
% SWdefidxmap
%     STATUS = HDFSW('defidxmap',SWATH_ID,GEODIM,DATADIM,INDEX)
%     地理的な位置とデータの次元間の不規則なマッピングを定義します。GEODIM 
%     は地理的な位置の次元名で、DATADIM はデータの次元名です。INDEX は、
%     各々の地理的な位置の要素が対応するデータ次元のインデックスを含む
%     配列です。
%
% SWdefgeofield
%  STATUS = HDFSW('defgeofield',SWATH_ID,FIELDNAME,DIMLIST,NTYPE,MERGE)
%     swath内の新規のgeolocationフィールドを定義します。FIELDNAME は、定義さ
%     れるフィールド名を含む文字列です。DIMLIST は、フィールドを定義する地理
%     的な位置の次元のカンマで区切られたリストを含む文字列です。NTYPE は、
%     フィールドのHDF 数値タイプを含む文字列です。MERGE はマージコードで、
%    'nomerge' または 'automerge' のいずれかです。
% 
% SWdefdatafield
%     STATUS = ....
%       HDFSW('defdatafield',SWATH_ID,FIELDNAME,DIMLIST,NTYPE,MERGE)
%     swath内の新規のデータフィールドを定義します。FIELDNAME は、定義
%     されるフィールド名を含む文字列です。DIMLIST は、フィールドを定義
%     する地理的な位置の次元のカンマで区切られたリストを含む文字列です。
%     NTYPE は、フィールドのHDF数値タイプを含む文字列です。MERGE は
%     マージコードで、'nomerge' または 'automerge' のいずれかです。
% 
% SWdefcomp
%     STATUS = HDFSW('defcomp',SWATH_ID,COMPCODE,COMPPARM) 
%     後に続くすべてのフィールドの定義に対するフィールドの圧縮を設定します。
%     COMPCODE はHDF圧縮コードで、'rle'、'skphuff'、'deflate'、'none' の
%     いずれかです。COMPPARM は、適用される場合は圧縮パラメータの配列です。
%     パラメータが適用されない場合は、COMPPARM は [] です。
% 
% SWwritegeometa
%     STATUS = HDFSW('writegeometa',SWATH_ID,FIELDNAME,DIMLIST,NTYPE)
%     FIELDNAME という既存のswath geolocationフィールドに対するフィールドの
%     メタデータを書き出します。DIMLIST は、フィールドを定義する地理的な
%     位置の次元のカンマで区切られたリストを含む文字列です。NTYPE は、
%     フィールド内に格納されたデータのHDF数値タイプを含む文字列です。
% 
% SWwritedatameta
%     STATUS = HDFSW('writedatameta',SWATH_ID,FIELDNAME,DIMLIST,NTYPE)
%     FIELDNAME という既存のswathデータフィールドに対するフィールドのメタ
%     データを書き出します。DIMLIST は、フィールドを定義する地理的な位置
%     の次元のカンマで区切られたリストを含む文字列です。NTYPE は、
%     フィールド内に格納されたデータのHDF数値タイプを含む文字列です。
%
% 基本 I/O ルーチン
% -----------------
% SWwritefield
%     STATUS = ....
%       HDFSW('writefield',SWATH_ID,FIELDNAME,START,STRIDE,EDGE,DATA)
%     データをswathフィールドに書き出します。FIELDNAME は、書き出される
%     フィールド名を含む文字列です。START は、各々の次元内での開始位置を
%     指定する配列(デフォルトは0)です。STRIDE は、各次元でスキップする
%     値を指定する配列(デフォルトは1)です。EDGE は、各々の次元に書き出す
%     値の個数を指定する配列(デフォルトは {dim - start}/stride)です。
%     start, stride, edge に対してデフォルト値を使用するには、空行列([])
%     を渡してください。  
% 
%     DATA のクラスは、与えられたフィールドに対して定義されたHDF 数値タイプと
%     一致しなければなりません。MATLAB文字列は、任意のHDF charタイプと一致す
%     るように自動的に変換されます。これ以外のデータタイプは、正確に一致しな
%     ければなりません。
%
%     注意: HDFファイルは、多次元配列に対してCスタイルの順番付けを行います
%     が、MATLABはFORTRANスタイルの順番付けを使用します。これは、MATLAB
%     配列の大きさが、HDFデータフィールドの定義された次元の大きさに対して転置
%     されなければならないことを意味します。たとえば、swathフィールドが 
%     3 * 4 * 5 のサイズをもつと定義された場合、DATA のサイズは 5 * 4 * 3 で
%     なければなりません。PERMUTE コマンドは、ここで必要な交換を行うための
%     コマンドです。
%
% SWreadfield
%     [DATA,STATUS] = ....
%       HDFSW('readfield',SWATH_ID,FIELDNAME,START,STRIDE,EDGE)
%     swathフィールドからデータを読み込みます。FIELDNAME は、読み込む
%     フィールド名を含む文字列です。START は、各々の次元内の開始位置を
%     設定する配列(デフォルトは0)です。STRIDE は、各々の次元でスキップ
%     する値を設定する配列(デフォルトは1)です。EDGE は、各々の次元で
%     書き出す値の個数を設定する配列(デフォルトは {dim - start}/stride)
%     です。start、stride、edgeに対してデフォルト値を使用するには、
%     空行列([])を渡してください。データ値は、配列 DATA に出力されます。
% 
%     注意:HDFファイルは、多次元配列に対してCスタイルの順番付けを行いますが、
%     MATLABは、FORTRANスタイルの順番付けを使用します。これは、MATLAB配
%     列の大きさが、HDFデータフィールドの定義された次元のサイズに対して転置さ
%     れなければならないことを意味します。たとえば、グリッドフィールドが 
%     3 * 4 * 5 のサイズをもつと定義された場合、DATA のサイズは 5 * 4 * 3 
%     でなければなりません。PERMUTE コマンドは、ここで必要な交換を行う
%     ためのコマンドです。
%
%     操作が失敗した場合は、DATA は [] で、STATUS は-1です。
%
% SWwriteattr
%     STATUS = HDFSW('writeattr',SWATH_ID,ATTRNAME,DATA)
%     swathの属性の書き出しと更新を行います。ATTRNAME は、属性名を含む文字
%     列です。DATA は、属性値を含む配列です。
% 
% SWreadattr
%     [DATA,STATUS] = HDFSW('readattr',SWATH_ID,ATTRNAME)
%     swathから属性を読み込みます。ATTRNAME は、属性名を含む文字列です。属
%     性値は、配列 DATA に出力されます。操作が失敗した場合は、DATA は [] で、
%     STATUS は-1です。
%
% SWsetfillvalue
%     STATUS = HDFSW('setfillvalue',SWATH_ID,FIELDNAME,FILLVALUE)
%     指定したフィールドについてfill 値を設定します。FILLVALUE は、スカラで、
%     そのクラスは指定したフィールドのHDF 数値タイプと一致しなければなりませ
%     ん。MATLAB文字列は、任意のHDF charタイプに一致するように自動的に変
%     換されます。これ以外のデータタイプは、正確に一致しなければなりません。
%
% SWgetfillvalue
%     [FILLVALUE,STATUS] = HDFSW('getfillvalue',SWATH_ID,...
%                            FIELDNAME)
%     指定したフィールドに対するfill値を取得します。操作が失敗した場合は、
%     FILLVALUE は [] で、STATUS は-1です。
% 
% Inquiry ルーチン
% -----------------
% SWinqdims
%     [NDIMS,DIMNAME,DIMS] = HDFSW('inqdims',SWATH_ID)
%     swath内で定義されたすべての次元に関する情報を取得します。NDIMS は、次
%     元数です。DIMNAME は、次元名のカンマで区切られたリストを含む文字列で
%     す。DIMS は、各々の次元のサイズを含む配列です。ルーチンが失敗すると、
%     NDIMS は-1で、それ以外の出力引数は [] です。
%   
% SWinqmaps
%     [NMAPS,DIMMAP,OFFSET,INCREMENT] = HDFSW('inqmaps',SWATH_ID)
%     swath内で定義されたすべての(インデックスの付いていない)地理的な位置の
%     関係に関する情報を取得します。スカラ NMAPS は、求められた地理的な位置
%     の関係の個数です。DIMMAP は、次元マップ名のカンマで区切られたリストを含
%     む文字列です。各々のマッピング内の2つの次元は、スラッシュ(/)で区切られま
%     す。OFFSET および INCREMENT は、データの次元に対する地理的な位置の次
%     元のオフセットと増分を含む配列です。ルーチンが失敗した場合は、NMAPS は
%     -1で、それ以外の出力引数は [] です。
%
% SWinqidxmaps
%     [NIDXMAPS,IDXMAP,IDXSIZES] = HDFSW('inqidxmaps',SWATH_ID)
%     swath内で定義されたすべてのインデックス付き地理的な位置/データのマッピ
%     ングに関する情報を取得します。NIDXMAPS は、マッピング数です。IDXMAP
%     は、マッピングのカンマで区切られたリストを含む文字列です。IDXSIZES は、対
%     応するインデックス配列のサイズを含む配列です。ルーチンが失敗した場合は、
%     NIDXMAPS は-1で、それ以外の出力引数は [] です。
% 
% SWinqgeofields
%     [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqgeofields',SWATH_ID)
%     swath内で定義されたすべてのgeolocationフィールドの情報を取得します。
%     NFLDS は、求められた地理的な位置フィールド数です。FIELDLIST は、
%     フィールド名をカンマで区切ったリストを含む文字列です。RANK は、
%     各々のフィールドに対するランク(次元数)を含む配列です。NTYPE は、
%     各々のフィールドのnumberタイプを示す文字列のセル配列です。ルーチン
%     が失敗した場合は、NFLDS は-1で、それ以外の出力引数は [] です。
% 
% SWinqdatafields
%     [NFLDS,FIELDLIST,RANK,NTYPE] = HDFSW('inqdatafields',SWATH_ID)
%     swath内で定義されたすべてのデータフィールドに関する情報を取得します。
%     NFLDS は、求められた地理的な位置フィールド数です。FIELDLIST は、
%     フィールド名をカンマで区切ったリストを含む文字列です。RANK は、
%     各々のフィールドに対するランク(次元数)を含む配列です。NTYPEは、
%     各々のフィールドの numberタイプを示す文字列のセル配列です。
%     ルーチンが失敗した場合は、NFLDS は-1で、それ以外の出力引数は [] です。
% 
% SWinqattrs
%     [NATTR,ATTRLIST] = HDFSW('inqattrs',SWATH_ID)
%     swath内で定義された属性に関する情報を取得します。NATTR は、検出される
%     属性数です。ATTRLIST は、属性名をカンマで区切ったリストを含む文字列で
%     す。ルーチンが失敗すると、NATTR は-1で、ATTRLIST は [] です。
% 
% SWnentries
%     [NENTS,STRBUFSIZE] = HDFSW('nentries',SWATH_ID,ENTRYCODE)
%     指定した要素に対するエントリ数と記述された文字列バッファサイズを取得し
%     ます。ENTRYCODE は、'HDFE_NENTDIM'(次元)、'HDFE_NENTMAP'(次元の
%     マッピング)、'HDFE_NENTIMAP'(インデックス付きの次元のマッピング)、
%     'HDFE_NENTGFLD'(地理的な位置フィールド)、'HDFE_NENTDFLD'(データ
%     フィールド)のうちのいずれか1つです。NENTS は、検出されたエントリ数で、
%     STRBUFSIZE は記述された文字列のサイズです。ルーチンが失敗した場合は、
%     NENTS は-1で、STRBUFSIZE は [] です。
%
% SWdiminfo
%     DIMSIZE = HDFSW('diminfo',SWATH_ID,DIMNAME)
%     指定した次元のサイズを取得します。DIMNAME は、次元名です。DIMSIZE は、
%     次元のサイズです。ルーチンが失敗した場合は、DIMSIZE は-1です。
%
% SWmapinfo
%     [OFFSET,INCREMENT,STATUS] = ....
%             HDFSW('mapinfo',SWATH_ID,GEODIM,DATADIM)
%     指定された単調な地理的な位置マッピングのオフセットと増分を取得します。
%     GEODIM は、地理的な位置の次元名です。DATADIM は、データの次元名で
%     す。OFFSET および INCREMENT は、データの次元に対する地理的な位置の次
%     元のオフセットと増分です。操作が失敗した場合は、STATUS は-1で、それ以
%     外の出力は [] です。
%
% SWidxmapinfo
%     [IDXSZ,INDEX] = HDFSW('idxmapinfo',SWATH_ID,GEODIM,DATADIM)
%     指定された地理的な位置マッピングのインデックス付き配列を取得します。
%     GEODIM は、地理的な位置の次元名です。DATADIM は、データの次元名で
%     す。IDXSZ は、インデックス付き配列のサイズです。INDEX は、マッピング
%     のインデックス配列です。ルーチンが失敗した場合は、IDXSZ は-1で、
%     INDEX は [] です。
% 
% SWattrinfo
%     [NTYPE,COUNT,STATUS] = HDFSW('attrinfo',SWATH_ID,ATTRNAME)
%     swathの属性に関する情報を出力します。ATTRNAME は、属性名を含む文字列
%     です。NTYPE は、属性のHDF数値タイプを含む文字列です。COUNT は、
%     ATTRIUTE 内のバイト数です。操作が失敗した場合は、STATUS は-1で、それ
%     以外の出力は[]です。
%
% SWfieldinfo
%     [RANK,DIMS,NTYPE,DIMLIST,STATUS] = ....
%         HDFSW('fieldinfo',SWATH_ID,FIELDNAME)
%     swath内の指定したgeolocatoionフィールドまたはデータフィールドに関する
%     情報を出力します。FIELDNAME は、フィールド名を含む文字列です。RANK は、
%     フィールドのランク(次元の個数)です。DIMS は、フィールドの次元のサイズを
%     含む配列です。NTYPE は、フィールドのHDF数値タイプを含む文字列です。
%     DIMLISTは、フィールド内の次元をカンマで区切ったリストを含む文字列です。
%     操作が失敗した場合は、STATUS は-1で、それ以外の出力は [] です。
%
% SWcompinfo
%     [COMPCODE,COMPPARM,STATUS] = HDFSW('compinfo',SWATH_ID,FIELDNAME)
%     フィールドに関する圧縮情報を取得します。FIELDNAME は、フィールド名を含
%     む文字列です。COMPCODE はHDF圧縮コードで、'rle'、'skphuff'、'deflate'
%     'none' のいずれかです。COMPPARM は、圧縮パラメータの配列です。操作が失
%     敗した場合は、STATUS は-1で、それ以外の出力は [] です。
% 
% SWinqswath
%     [NSWATH,SWATHLIST] = HDFSW('inqswath',FILENAME)
%     HDF-EOSファイル内で定義されたswathの個数と名前を取得します。FILENAME
%     は、ファイル名を含む文字列です。NSWATH は、ファイル内で検出されたswath
%     データセット数です。SWATHLIST は、swath名のカンマで区切られたリストを含
%     む文字列です。ルーチンが失敗した場合は、NSWATH は-1で、SWATHLIST は
%     [] です。
%   
%   SWregionindex
%       [REGIONID, GEODIM, IDXRANGE] = HDFSW('defboxregion',... 
%	        		 SWATHID, CORNERLON, CORNERLAT, MODE); 
%     Swatch 部分に対する緯度、経度による領域を決定します。このルーチンと
%     SWdefboxregion との違いは、地形的な位置の追跡次元とその次元の範囲が付
%     加的に regionID に出力されることです。正しい入力に関する記述は、
%     SWdefboxregion のヘルプを参照してください。
%       
%   SWupdateidxmap
%　     [INDEXOUT, INDICES, IDXSZ] = HDFSW('updateidxmap',SWATHID,...
%					   REGIONID,INDEXIN);
%     指定した領域に対して、指定した地形的なマッピングのインデックス配列
%     を読み込みます。REGIONID は、swatch 領域の識別子です。
%     INDEXIN は、個々の地形的な要素が対応するデータ次元のインデックスを含む
%     配列を出力します。INDEXOUT は、個々の地形が、サブセット領域内に対応す
%     るデータ領域のインデックスを含む配列です。INDICES は、領域のスタートと
%     ストップに対するインデックスを含む配列です。IDXSZ は、INDICES 配列の
%     サイズであるか、失敗を意味する -1 になります。
%
%   SWgeomapinfo
%	    REGMAP = HDFSW('geomapinfo',SWATHID, GEODIM)
%     名前 GEODIM をもつ次元に対して、次元マッピングのタイプを読み込みます。
%     戻り値 REGMAP は、0の場合はマッピングなし、1の場合は通常のマッピング、
%     2の場合はインデックス付きマッピング、3の場合は通常の方法を使ったイン
%     デックス付きマッピング、-1 は失敗を意味します。
% 
% サブセットルーチン
% ------------------
%   SWdefboxregion
%     REGIONID = HDFSW('defboxregion',SWATH_ID,CORNERLON,CORNERLAT,MODE)
%     swathの経度-緯度ボックスの領域を定義します。CORNERLON および
%     CORNERLATは、ボックスの隅の経度と緯度を角度単位で含む2要素配列です。
%     MODE は、航跡の表現モードで、'HDFE_MIDPOINT', 'HDFE_ENDPOINT', 
%     'HDFE_ANYPOINT' のいずれかです。ルーチンが成功した場合は、REGIONID 
%     はswath領域の識別子で、失敗した場合は-1です。
% 
%   SWregioninfo
%     [NTYPE,RANK,DIMS,SIZE,STATUS] = ....
%             HDFSW('regioninfo',SWATH_ID,REGIONID,FIELDNAME)
%     サブセット化された領域に関する情報を取得します。REGIONID は、swathの領
%     域の識別子です。FIELDNAME は、サブセット化されるフィールド名を含む文字
%     列です。NTYPE は、フィールドのHDF数値タイプを含む文字列です。RANK は、
%     フィールドのRANKです。DIMS は、サブセット領域の次元を与える配列です。
%     SIZE は、サブセット領域のバイト単位のサイズです。
%
%   SWextractregion
%     [DATA,STATUS] = HDFSW('extractregion',....
%                 SWATH_ID,REGIONID,FIELDNAME,EXTERNAL_MODE)
%     サブセット化された領域を抽出します(読み込みます)。REGIONID は、swath領
%     域の識別子です。FIELDNAME は、サブセット化されるフィールド名を含む文字
%     列です。EXTERNAL_MODE は、外部の地理的な位置モードを含む文字列で、
%     'external'(データと地理的な位置フィールドが異なるswath内にある)、または
%     'internal'(データと地理的な位置フィールドが同じswath構造体内にある)で
%     す。DATAは、サブセット化された領域に含まれるデータです。
%
%   SWdeftimeperiod
%     PERIODID = HDFSW('deftimeperiod',SWATH_ID,STARTTIME,STOPTIME,MODE)
%     swathの時間区間を定義します。STARTTIME および STOPTIME は、開始時間
%     と終了時間です。MODE は、航跡の表現モードで、'midpoint'、'endpoint'、
%     'anypoint' のいずれかです。PERIODID は、時間区間の識別子です。
%     ルーチンが失敗した場合は、PERIODID は-1です。
% 
%   SWperiodinfo
%     [NTYPE,RANK,DIMS,SIZE,STATUS] = ....
%                      HDFSW('periodinfo',SWATH_ID,PERIODID,FIELDNAME)
%     サブセット化された領域に関する情報を取得します。PERIODID は、区間の
%     識別子で、FIELDNAME はサブセット化されるフィールド名を含む文字列
%     です。NTYPEは、フィールドのHDF数値タイプを含む文字列です。RANK は、
%     フィールドのランクです。DIMS は、サブセット化される領域の次元を
%     含む配列です。SIZE は、サブセット化される領域のバイト単位のサイズ
%     です。操作が失敗した場合は、STATUS は-1で、それ以外の出力は [] です。
%
%   SWextractperiod
%     [DATA,STATUS] = HDFSW('extractperiod',SWATH_ID,....
%                          PERIODID,FIELDNAME,EXTERNAL_MODE)
%     サブセット化された時間区間を抽出します(読み込みます)。PERIODID は、区間
%     の識別子です。FIELDNAME は、サブセット化されるフィールド名を含む文字列
%     です。EXTERNAL_MODE は、外部の地理的な位置モードで、'external'(データと
%     地理的な位置フィールドが異なるswath内にある)、または'internal'(データと
%     地理的な位置フィールドが同じswath構造体内になければならない)です。
%     DATA は、サブセット化された時間区間に含まれるデータです。
%
%   SWdefvrtregion 
%     ID2 = HDFSW('defvrtregion',SWATH_ID,ID,VERTOBJ,RANGE)
%     単調なフィールドまたは次元の連続的な要素についてサブセット化します。ID
%     は、前のサブセット呼び出しの領域または区間識別子、または最初の呼び出し
%     の場合-1です。VERTOBJ は、次元名またはサブセット化されるフィールド名を
%     含む文字列です。RANGE は、サブセット化される領域を含む2要素のベクトルで
%     す。ルーチンが成功した場合は、ID2 は新規の領域または区間の識別子で、失
%     敗した場合は-1です。
%
%   SWdupregion
%     ID2 = HDFSW('dupregion',ID)
%     領域または区間を複製します。ID は領域または区間の識別子です。ID2 は、新
%     規の領域または区間の識別子です。ルーチンが失敗した場合は、ID2 は-1
%     です。
%
% 参考： HDF, HDFPT, HDFGD.


%	Copyright 1984-2003 The MathWorks, Inc. 
