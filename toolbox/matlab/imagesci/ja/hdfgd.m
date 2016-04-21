% HDFGD   HDF-EOS GridオブジェクトのMATLABインタフェース
%
% HDFGDは、HDF-EOS GridオブジェクトのMATLABインタフェースです。
% HDF-EOSは、NCSA (National Center for Supercomputing Applications) HDF 
% (Hierarchical Data Format)の拡張です。HDF-EOSは、EOS (Earth Observing 
% System)に対するベースライン標準としてNASAが選択する科学データフォー
% マット標準です。
% 
% HDFGDは、HDF-EOS CライブラリのGrid関数のゲートウェイで、EOSDIS (Earth 
% Observing System Data and Information System)によって開発、維持され
% ています。グリッドデータセットは、2次元またはそれ以上の次元の直交
% 線形配列、次元の定義、関連するマップの投影で構成されます。
% 
% ここで述べた情報に加えて、つぎのドキュメントを参照することをおすすめし
% ます。
% 
%     HDF-EOS Library User's Guide for the ECS Project,
%     Volume 1: Overview and Examples; Volume 2: Function
%     Reference Guide 
% 
% このドキュメントは、つぎのwebから入手可能です。
% 
%        http://hdfeos.gsfc.nasa.gov
% 
% このサイトからドキュメントを入手できない場合、MathWorks Technical 
% Support(support@mathworks.com)にご連絡ください。
% 
% シンタックスの使い方
% ------------------
% HDF-EOS CライブラリとHDFGDシンタックスの中でGrid関数間で1対1マッピング
% が存在します。たとえば、Cライブラリは、設定した次元の大きさを得るのに、
% つぎの関数を用意しています。
% 
%       int32 GDdiminfo(int32 gridid, char *dimname)
% 
% 等価なMATLABシンタックスは、つぎのようになります。
% 
%       DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
% 
% GRID_ID は、特定のグリッドデータセットの識別子(またはハンドル)です。
% DIMNAME は、指定した次元の名前を含む文字列です。DIMSIZE は、指定し
% た次元のサイズか、あるいは操作が失敗した場合は-1になります。
% 
% Cライブラリ関数の中には、Cマクロで定義された入力値を受け入れるものが
% あります。たとえば、Cの関数 GDopen() は、DFACC_READ、DFACC_RDWR、
% DFACC_CREATE のいずれかであるアクセスモード入力を必要とします。ここ
% で、これらのシンボルは適切なCヘッダファイルの中に定義されています。
% マクロの定義がCライブラリの中で使われる部分で、等価なMATLABシンタッ
% クスは、マクロ名から得られる文字列を使います。ユーザは、マクロ名全体を
% 含む文字列を使用することも、または共通する接頭語を省略することもできま
% す。また、大文字も小文字も使用することができます。たとえば、つぎのC関数
% コール
% 
%       status = GDopen("GridFile.hdf",DFACC_CREATE)
% 
% は、つぎのMATLAB関数コールと等価です。
% 
%       status = hdfgd('open','GridFile.hdf','DFACC_CREATE')
%       status = hdfgd('open','GridFile.hdf','dfacc_create')
%       status = hdfgd('open','GridFile.hdf','CREATE')
%       status = hdfgd('open','GridFile.hdf','create')   
% 
% C関数がマクロ定義からの値を出力する場合は、等価なMATLAB関数は、
% マクロを小文字で表わした短縮形を含む文字列として値を出力します。   
% 
% HDF番号のタイプは、'uchar8', 'uchar', 'char8', 'char', 'double', 'uint8'
% 'uint16', 'uint32', 'float', 'int8', 'int16', 'int32'を含む文字列で指定されます。
%
% HDF-EOSライブラリがNULLを受け入れる場合、空行列([])が使われます。
% 
% ほとんどのルーチンは、ルーチンが成功した場合0、失敗した場合-1を、フラ
% グ STATUS に出力します。STATUS を含まないシンタックスをもつルーチンは、
% 以下の関数のシンタックスでの記述で行っているように、出力のうちの1つに
% 失敗を意味する情報を出力します。
% 
% プログラミングモデル
% -----------------
% HDFGDを使ったグリッドデータセットへのアクセスのプログラミングモデルは、
% つぎのようになります。
% 
% 1. ファイルをオープンし、ファイル名からファイルidを得ることでGDインタ
%    フェースを初期化します。
% 2. グリッド名からグリッドidを得ることによりグリッドデータセットをオー
%    プンするか、作成します。
% 3. データセットで希望する操作を行います。
% 4. グリッドidを設定して、グリッドデータセットをクローズします。
% 5. ファイルidを設定して、ファイルへのアクセスを終了します。
% 
% HDF-EOSファイル内に既に存在している単一グリッドデータセットにアクセス
% するためには、つぎのMATLABコマンドを使います。
% 
%       fileid = hdfgd('open',filename,access);
%       gridid = hdfgd('attach',fileid,gridname);
% 
%       % データセット上にオプションの演算を適用
% 
%       status = hdfgd('detach',gridid);
%       status = hdfgd('close',fileid);
% 
% 同時に複数のファイルにアクセスするためには、オープンする各ファイルの
% ファイル識別子を個々に取得します。複数のグリッドデータセットにアクセス
% するためには、各データセットに対する個々のグリッドidを取得します。
% 
% バッファされている演算が、ディスクに完全に記述されるようにグリッドidと
% ファイルidを適切に配置することが重要です。MATLABを終了するか、オープン
% したままのGD識別子をもつすべてのMEX-ファイルをクリアすると、MATLABは
% ワーニングを表示し、自動的にこれらを配置します。
% 
% HDFGDで出力されるファイル識別子は、他のHDF-EOSまたはHDF関数で
% 出力されるファイル識別子と互換性がないことに注意してください。
% 
% 関数のカテゴリ
% -------------------
% グリッドデータセットルーチンは、つぎのカテゴリに分類されます。
%
%     - アクセスルーチンは、GDインタフェースやグリッドデータセット(オー
%       プンしているファイルやクローズしているファイルを含む)を初期化し
%       アクセスを終了します。
%
%     - 定義ルーチンは、グリッドデータセットの主要部分を設定します。
%
%     - 基本I/Oルーチンは、グリッドデータセットのデータやメタデータを読み
%		 込んだり書き出します。
%
%     - 質問(Inquiry)ルーチンは、グリッドデータセット内に含まれるデータ
%       に関する情報を出力します。
%
%     - サブセットルーチンは、指定した幾何的な領域からデータを読み込みま
%       す。
% 
% アクセスルーチン
% ---------------
% GDopen
%     FILE_ID = HDFGD('open',FILENAME,ACCESS)
%     ファイル名と希望するアクセスモードを与えて、グリッドデータセットを作成
%     読み込み、書き出しを行うためにHDFファイルをオープンまたは作成します。
%     ACCESSには、'read', 'rdwr', 'create' のいずれかを使用できます。
%     FILE_IDは、演算が失敗した場合は-1になります。
% 
% GDcreate
%     GRID_ID = HDFGD('create',FILE_ID,GRIDNAME,...
%                         XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT)
%     グリッドデータセットの作成。GRIDNAME は、グリッドデータセットの名前を含
%     む文字列です。XDIMSIZE と YDIMSIZE は、代表する次元の大きさを示す
%     スカラです。UPLEFT は、グリッドの左上隅のピクセルを表わすX座標とY座
%     標を含む2要素ベクトルです。LOWRIGHT は、グリッドの右下隅のピクセル
%     のX座標とY座標を含む2要素ベクトルです。GRID_ID は、演算が失敗した場
%     合には-1になります。
%   
% GDattach
%     GRID_ID = HDFGD('attach',FILE_ID,GRIDNAME)
%     ファイル内に存在するグリッドデータセットにアタッチします。GRID_ID は、
%     演算が失敗した場合には-1になります。
% 
% GDdetach
%     STATUS = HDFGD('detach',GRID_ID)
%     グリッドデータセットから切り取ります。
% 
% GDclose
%     STATUS = HDFGD('close', FILE_ID)
%     ファイルをクローズ
%   
% 定義に関するシンタックス
% -------------------
% GDdeforigin
%     STATUS = HDFGD('deforigin',GRID_ID,ORIGIN)
%     グリッドのどの隅を原点にするかを定義します。
%     ORIGIN は、'ul', 'ur', 'll', 'lr' のいずれかを設定できます。
%
% GDdefdim
%     STATUS = HDFGD('defdim',GRID_ID,DIMNAME,DIM)
%     グリッドデータセット内の新しい次元を定義します。DIMNAME は新しい
%     次元の名前を含む文字列で、DIM は新しい次元の大きさを表わす
%     スカラです。
%
% GDdefproj
%     STATUS = HDFGD('defproj',GRID_ID,PROJCODE,...
%               ZONECODE,SPHERECODE,PROJPARM)
%     グリッドデータセットに対する射影法を定義します。PROJCODE は、'geo', 
%     'utm', 'lamcc', 'ps', 'polyc', 'tm', 'lamaz', 'hom', 'som', 'good','isinus' 
%     のいずれかを設定できます。ZONECODE は、UTM図法コードです。他の
%     投影法を使うには、[] または0を設定します。SPHERECODE は、スカラの
%     球面コードです。PROJPARM は、最大13要素をもつベクトルで、投影法
%     固有のパラメータを含みます。PROJCODE, ZONECODE, SPHERECODE, 
%     PROJPARMの詳細については、 ECS Project, Volume 1のHDF-EOS 
%     Library Users Guideの6章を参照してください。
%
% GDdefpixreg
%     STATUS = HDFGD('defpixreg',GRID_ID,PIXREG)
%     グリッドセル内に位置するピクセルを定義します。PIXREG は、'center' 
%     または 'corner' のいずれかを設定できます。
% 
% GDdeffield
%     STATUS = HDFGD('deffield',GRID_ID,FIELDNAME,...
%                      DIMLIST,NUMBERTYPE,MERGE)
%     グリッド内に格納されるデータフィールドを定義します。FIELDNAME は、
%     定義される次元名を含む文字列です。DIMLIST は、次元を表わす
%     カンマで区切られた文字列です。NUMBERTYPE は、HDF番号タイプを
%     指定する文字列です。MERGEは、'nomerge'、 'automerge' のいずれか
%     です。
%
% GDdefcomp
%     STATUS = HDFGD('defcomp',GRID_ID,COMPCODE,COMPPARM)
%     すべての連続的なフィールド定義に対するフィールド圧縮を設定します。
%     COMPCODEは、'rle','skphuff', 'deflate', 'none' のいずれかを設定できます。
%     Deflate圧縮は、COMPPARM が1から9までの整数であることを要求します。
%     ここで、整数値が大きい方がより高い圧縮になります。他の圧縮法を使用
%     する場合は、COMPPARM に0または [] を設定してください。
%
% GDwritefieldmeta
%     STATUS = HDFGD('writefieldmeta',GRID_ID,...
%                FIELDNAME,DIMLIST,NUMBERTYPE)
%     Grid APIを使って定義していない既存のグリッドフィールドに対する
%     フィールドメタデータを記述します。FIELDNAME は、フィールド名を含む文
%     字列です。DIMLIST は、カンマで区切られた次元名を含む文字列です。
%     NUMBERTYPEは、HDF番号タイプを指定する文字列です。
%
% GDblkSOMoffset
%     STATUS = HDFGD('blksomoffset',GRID_ID,OFFSET)
%     標準のブロックSOMオフセット値をSOM投影法からピクセル単位で書き
%     込みます。OFFSET は、SOM投影データに対するオフセット値のベクトル
%     です。このルーチンは、SOM投影を使用するグリッドと共にのみ使われ
%     ます。
%
% GDsettilecomp
%     STATUS = HDFGD('settilecomp',GRIDID,FIELDNAME,...
%                   TILEDIMS,COMPCODE,COMPPARM)
%     設定値をもつフィールドに対して、タイリングパラメータと圧縮パラメータを
%     設定します。このルーチンは、HDF-EOS 2.3 のバグフィックスを行うため、
%     HDF-EOS 2.5 で導入されています。FIELDNAME は、指定したグリッドの
%     名前です。TIELDIMS は、タイリングの次元を含むベクトルです。
%     COMPCODE は、'rle', 'skphuff'、'deflate'、'none' のいずれかを設定でき
%     ます。deflate圧縮では、COMP PARM が1から9の間の整数であることが
%     必要になります。そして、大きい値は、より高い圧縮に対応します。
%     COMPPARM に 0 または[]を指定すると、他の圧縮方法が採用されます。
%     この関数が呼び出される順番を示します。
%
%		   hdfgd('gddeffield'... 
%                  hdfgd('gdsetfillvalue'...
%		   hdfgd('gdsettilecomp'...
%	
% 基本的な I/O に関するシンタックス
% ------------------
% GDwritefield
%     STATUS = HDFGD('writefield',GRID_ID,FIELDNAME,...
%                 START,STRIDE,EDGE,DATA)
%     グリッドデータセットの指定したフィールドにデータを書き込みます。
%     FIELDNAMEは、指定されたグリッドの名前です。STARTは、各次元内で、
%     (ゼロをベースにした)開始点を指定する位置を表わすベクトルです。
%     STRIDE は、各次元に沿ってスキップされる値を指定するベクトルです。
%     EDGE は、各次元に沿って書き込まれる値の数です。DATA は、書き込ま
%     れる値の配列です。STARTに [] を指定することは、ZEROS(1,NUMDIMS) 
%     を指定することと等価です。EDGE に [] を指定することは、
%     FLIPLR(SIZE(DATA)) を指定することと等価です。
% 
%     DATA のクラスは、与えられたフィールドに設定されているHDF番号タイプ
%     と一致しなければなりません。MATLAB文字列は、HDF charタイプのいず
%     れかと一致するように自動的に変換されます。他のデータタイプは、厳密な
%     意味で一致しなければなりません。
%
%     注意：HDFファイルは、多次元配列に対してCスタイルの順番付けを使い
%     ます。一方、MATLABはFORTRANスタイルの順番付けを使います。これは、
%     MATLAB配列の大きさが、HDFデータフィールドの定義された次元の大き
%     さに対して、転置されなければならないことを意味しています。たとえば、
%     グリッドフィールドが、3 x 4 x 5で定義されている場合は、DATAは5 x 4 x 3
%     の大きさでなければなりません。PERMUTE コマンドは、ここで必要な変換
%     を行うためのコマンドです。
%
% GDreadfield
%     [DATA,STATUS] = HDFGD('readfield',GRID_ID,...
%                      FIELDNAME,START,STRIDE,EDGE)
%     指定したグリッドフィールドからデータを読み込みます。FIELDNAME は、
%     読み込むフィールド名です。STARTは、各次元内で(ゼロをベースにした)
%     開始点を指定する位置を表わすベクトルです。STRIDE は、各次元に沿っ
%     て、スキップされる値を指定するベクトルです。EDGE は、各次元に沿って
%     書き込まれる値の数です。DATA は、書き込まれる値の配列です。START 
%     に [] を指定することは、ZEROS(1,NUMDIMS) を指定することと等価です。
%     STRIDE に [] を指定することは、ONES(1,NUMDIMS) を指定することと等価
%     です。EDGE に [] を指定すると、フィールド全体が読み込まれます。
%
%     注意：HDFファイルは、多次元配列に対してCスタイルの順番付けを使い
%     ます。一方、MATLABはFORTRANスタイルの順番付けを使います。これは、
%     MATLAB配列の大きさが、HDFデータフィールドの定義された次元の大き
%     さに対して、転置されなければならないことを意味しています。たとえば、
%     グリッドフィールドが3 x 4 x 5で定義されている場合は、DATA は、5 x 4 x 3
%     の大きさでなければなりません。PERMUTE コマンドは、ここで必要な変換
%     を行うためのコマンドです。
% 
%     操作が失敗した場合は、DATAは [] で、STATUS は-1になります。
% 
% GDwriteattr
%     STATUS = HDFGD('writeattr',GRID_ID,ATTRNAME,DATA)
%     指定した名前の属性をもつグリッドデータを書き込むか、または更新します。
%     属性が既に存在しているものでない場合は、作成します。
% 
% GDreadattr
%     [DATA,STATUS] = HDFGD('readattr',GRID_ID,ATTRNAME)
%     指定した属性から、その属性のデータを読み込みます。演算が失敗した場
%     合は、DATA は [] で、STATUS は-1になります。
% 
% GDsetfillvalue
%     STATUS = HDFGD('setfillvalue',GRID_ID,...
%                              FIELDNAME,FILLVALUE)
%     指定されたフィールドに対する値を設定します。FILLVALUEは、スカラ量
%     で、そのクラスが指定したフィールドのHDF数字タイプに一致しているもの
%     です。MATLAB文字列は、HDF charタイプのいずれかと一致するように
%     自動的に変換されます。他のデータタイプは、厳密な意味で一致しなけ
%     ればなりません。
% 
% GDgetfillvalue
%     [FILLVALUE,STATUS] = HDFGD('getfillvalue',GRID_ID, ...
%                          FIELDNAME)
%     指定されたフィールドに対して設定値を読み込みます。演算が失敗した場合
%     は、FILLVALUE は [] で、STATUS は-1になります。
%
% Inquiry ルーチン
% ----------------
% GDinqdims
%     [NDIMS,DIMNAME,DIMS] = HDFGD('inqdims',GRID_ID)
%     グリッドデータセットの中で定義されているすべての次元に関する情報を
%     取得します。NDIMS は、次元数です。DIMNAME は、カンマで区切られた
%     次元名のリストを含む文字列です。DIMSは、各次元の大きさを含むベク
%     トルです。演算が失敗した場合は、NDIMSは-1で、DIMNAME と DIMS は
%     [] になります。
%
% GDinqfields
%     [NFIELDS,FIELDLIST,RANK,NUMBERTYPE] = HDFGD( ...
%              'inqfields', GRID_ID)
%     グリッドデータセット内に定義されたすべてのフィールドに関する情報を取
%     得します。NFILEDS は、フィールドの数です。FILEDLIST は、カンマで区
%     切られたフィールド名のリストを含む文字列です。RANK は、各フィールド
%     のランクを含むベクトルです。NUMBERTYPE は、各フィールドのHDF番号
%     タイプを含む文字列のセル配列です。
%
% GDinqattrs
%     [NATTRS,ATTRLIST] = HDFGD('inqattrs',GRID_ID)
%     グリッド内に定義されたすべての属性に関する情報を取得します。NATTRS 
%     は､属性の数です。ATTRLIST は、カンマで区切られた属性名のリストを
%     含む文字列です。演算が失敗した場合は、NATTRS は-1で、ATTRLIST は 
%     [] になります。
%
% GDnentries
%     [NENTRIES,STRBUFSIZE] = HDFGD('nentries',GRID_ID,...
%               ENTRYCODE)
%     指定した対象物に対する要素数を取得します。ENTRYCODE は、次元数
%     を求めるには 'nentdim' を、フィールド数を求めるには 'nestdfld' を設定し
%     ます。STRBUFSIZE は、カンマで区切られたフィールド名の次元のリストの
%     長さになります。
%
% GDgridinfo
%     [XDIMSIZE,YDIMSIZE,UPLEFT,LOWRIGHT,STATUS] = ...
%              HDFGD('gridinfo',GRID_ID)
%     グリッドデータセットの位置と大きさを出力します。XDIMSIZE と YDIMSIZE 
%     は、それぞれ、次元の大きさを含むスカラです。UPLEFT は、グリッドの左上
%     隅のX座標とY座標を含む2要素ベクトルです。LOWRIGHT は、グリッドの
%     右下隅のX座標とY座標を含む2要素ベクトルです。演算が失敗した場合は、
%     STATUS は-1で、他のすべての出力は [] になります。
%
% GDprojinfo
%     [PROJCODE,ZONECODE,SPHERECODE,PROJPARM,STATUS] = ...
%               HDFGD('projinfo',GRID_ID)
%     グリッドデータセットに関する投影情報を取得します。出力パラメータの記述
%     については、GDdefproj を参照してください。演算が失敗した場合は、
%     STATUS は-1で、他のすべての出力は [] になります。
% 
% GDdiminfo
%     DIMSIZE = HDFGD('diminfo',GRID_ID,DIMNAME)
%     指定した次元の大きさを取得します。DIMNAME は、次元名を含む文字列
%     です。演算が失敗すると、DIMSIZE は-1になります。
%
% GDcompinfo
%     [COMPCODE,COMPPARM,STATUS] = HDFGD('compinfo',...
%                        GRID_ID,FIELDNAME)
%     指定したフィールドに関する圧縮情報を取得します。出力パラメータの記述
%     に関しては、GDdefcomp を参照してください。演算が失敗した場合は、
%     STATUS は-1で、他のすべての出力は [] になります。
% 
% GDfieldinfo
%     [RANK,DIMS,NUMBERTYPE,DIMLIST,STATUS] = ...
%           HDFGD('fieldinfo',GRID_ID,FIELDNAME)
%     指定したフィールドに関する情報を取得します。RANK は、フィールドの
%     ランクです。DIMS は、フィールドの次元の大きさを含むベクトルです。
%     NUMBERTYPEは、フィールドのHDF番号タイプを含む文字列です。
%     DIMLIST は、カンマで区切られた次元名のリストを含む文字列です。
%     演算が失敗した場合は、STATUS は-1で、他のすべての出力は [] になり
%     ます。
%
% GDinqgrid
%     [NGRID,GRIDLIST] = HDFGD('inqgrid',FILENAME)
%     HDF-EOSファイル内のグリッドデータセットに関する情報を取得します。
%     NGRID はグリッド数で、GRIDLIST はカンマで区切られたグリッドデータ
%     セット名のリストを含む文字列です。演算が失敗した場合は、NGRID は-1
%     で、他のすべての出力は [] になります。
%
% GDattrinfo
%     [NUMBERTYPE,COUNT,STATUS] = HDFGD('attrinfo',...
%                 GRID_ID,ATTRNAME)
%     指定した属性のサイズ(バイト単位)と番号タイプを出力します。ATTRNAME 
%     は、属性名です。NUMBERTYPE は、属性のHDF番号タイプに対応した文字
%     列です。COUNT は、属性データにより使用されるバイト数です。演算が失
%     敗した場合は、STATUS は-1で、NUMBERTYPE と COUNT は [] になり
%     ます。
%
% GDorigininfo
%     ORIGINCODE = HDFGD('origininfo',GRID_ID)
%     グリッドデータセットに関する原点コードを出力します。ORIGINCODE は、
%     'ul', 'ur', 'll', 'lr' のいずれかを使用できます。
%
% GDpixreginfo
%     PIXREGCODE = HDFGD('pixreginfo',GRID_ID)
%     グリッドデータセットに関するpixregコードを出力します。PIXREGCODE は、
%     'center' または 'corner' のいずれかです。
%
% サブセットルーチン
% ---------------
% GDdefboxregion
%     REGION_ID = HDFGD('defboxregion',GRID_ID,...
%                          CORNERLON,CORNERLAT)
%     グリッドデータセットに対する経度-緯度で囲まれたボックス領域を定義し
%     ます。CORNERLON は、ボックスの反対側の隅の経度を含む2要素ベク
%     トルです。CORNERLAT は、ボックスの反対側の隅の緯度を含む2要素ベ
%     クトルです。演算が失敗した場合は、REGION_ID は-1になります。
% 
% GDregioninfo
%      [NUMBERTYPE,RANK,DIMS,BYTESIZE,UPLEFT,LOWRIGHT, ...
%           STATUS] = HDFGD('regioninfo',GRID_ID,...
%                              REGION_ID,FIELDNAME)
%     サブセット化された領域に関する情報を取得します。NUMBERTYPE は、
%     フィールドのHDF番号タイプです。RANK は、フィールドのランクです。
%     DIMS は、サブセット化された次元の大きさを含むベクトルです。
%     BYTESIZE は、サブセット化された領域内のデータの大きさ(バイト単位)を
%     表わします。UPLEFT は、グリッドの左上隅のX座標とY座標を含む2要素
%     ベクトルです。LOWRIGHT は、グリッドの右下隅のX座標とY座標を含む
%     2要素ベクトルです。演算が失敗した場合は、STATUSは-1で、他のすべて
%     の出力は [] になります。
% 
% GDextractregion
%     [DATA,STATUS] = HDFGD('extractregion',GRID_ID,...
%                REGION_ID,FIELDNAME)
%     指定したフィールドのサブセット化された領域からデータを読み込みます。
%     演算が失敗した場合は、STATUS は-1で、DATA は [] になります。
% 
%     注意：HDFファイルは、多次元配列に対してCスタイルの順番付けを使い
%     ます。一方、MATLABはFORTRANスタイルの順番付けを使います。これは、
%     MATLAB配列の大きさが、HDFデータフィールドの定義された次元の大き
%     さに対して、転置されなければならないことを意味しています。たとえば、
%     グリッドフィールドが3 x 4 x 5で定義されている場合は、DATA は5 x 4 x 3
%     の大きさでなければなりません。PERMUTE コマンドは、ここで必要な変換
%     を行うためのコマンドです。
%
% GDdeftimeperiod
%     PERIOD_ID2 = HDFGD('deftimeperiod',GRID_ID,...
%                 PERIOD_ID,STARTTIME,STOPID)
%     グリッドデータセットに対する時間周期を定義します。PERIOD_ID は、前の
%     呼び出しからの出力 PERIOD_ID か -1のいずれかです。STARTTIME や 
%     STOPTIMEは、周期の開始時間と終了時間を指定するスカラです。演算が
%     失敗した場合は、出力 PERIOD_ID2 は-1です。
%
% GDdefvrtregion
%     REGION_ID2 = HDFGD('defvrtregion',GRID_ID,...
%                 REGION_ID,VERTOBJ,RANGE)
%     単一フィールドまたは次元の連続する要素に関してサブセット化します。
%     REGION_ID は、前のサブセット呼び出しからの周期 ID の領域か、または
%     -1のいずれかになります。VERTOBJ は、サブセット化されたフィールドまた
%     は次元の名前を含む文字列です。RANGE は、サブセットに対する最小範囲
%     と最大範囲を含む2要素ベクトルです、演算に失敗した場合は、REGION_ID2 
%     は-1になります。
%
% GDgetpixels
%     [ROW,COL,STATUS] = HDFGD('getpixels',GRID_ID,...
%                          LON,LAT)
%     緯度と経度に対応するピクセル座標を取得します。LON と LAT は、
%     度単位で表わした経度と緯度の座標を含むベクトルです。ROW と COL は、
%     対応するゼロベースの行と列の座標を含むベクトルです。演算が失敗した
%     場合は、STATUS は-1で、ROW と COL は [] になります。
%
% GDgetpixvalues
%     [DATA,BYTESIZE] = HDFGD('getpixvalues',GRID_ID, ...
%                 ROW,COL,FIELDNAME)
%     指定した行と列の座標で指定したフィールドからデータを読み込みます。
%     ROW と COL は、ゼロベースの行座標と列座標を含むベクトルです。
%     非幾何学的な次元(すなわち、XDimやYDimでない)に沿ったすべての要素
%     は、単一の列ベクトルとして出力されます。演算が失敗した場合は、
%     DATA は [] で、BYTESIZE は-1になります。
%
% GDinterpolate
%     [DATA,BYTESIZE] = HDFGD('interpolate',GRID_ID,...
%                 LON,LAT,FIELDNAME)
%     フィールドグリッド上の双一次内挿を行います。LON と LAT は、経度と緯度
%     座標を含むベクトルです。非幾何学的な次元(すなわち、XDimやYDimでな
%     い)に沿ったすべての要素が内挿されます。結果の値は、倍精度列ベクトル
%     として出力されます。演算が失敗した場合は、DATA は [] で、BYTESIZE は
%     -1になります。
%
% GDdupregion
%     REGION_ID2 = HDFGD('dupregion',REGION_ID)
%     領域を複製します。このルーチンは、カレント領域内に格納されている情報
%     をコピーし、新しい識別子を作成します。ユーザが領域や周期をさらに複数
%     の方法で設定したい場合に役立ちます。演算が失敗した場合は、
%     REGION_ID2 は-1になります。
% 
% Tiling ルーチン
% ---------------
% GDdeftile
%     STATUS = HDFGD('deftile',GRID_ID,TILECODE,TILEDIMS)
%     後に続くフィールド定義に対してtilingの次元を定義します。
%     tileの次元数とその後のフィールドの次元数は、同じでなければなりません。
%     そして、tile次元は、対応するフィールド次元を分解したものです。
%     TILECODEは、'tile' または 'notile' のいずれかです。TILEDIMS は、tileの
%     次元を含むベクトルです。
%
% GDtileinfo
%     [TILECODE,TILEDIMS,TILERANK,STATUS] = HDFGD( ...
%               'tileinfo',GRID_ID,FIELDNAME)
%     フィールドに関するtiling情報を取得します。演算が失敗した場合は、出力
%     STUTAS は-1で、他の出力は [] になります。
%
% GDsettilecache
%     STATUS = HDFGD('settilecache',GRID_ID,FIELDNAME,...
%                    MAXCACHE)
%     tileキャッシュパラメータを設定します。MAXCACHE は、メモリ内でキャッシュ
%     を行うtileの最大数を示すスカラです。
%
% GDreadtile
%     [DATA,STATUS] = HDFGD('readtile',GRID_ID, ...
%              FIELDNAME,TILECOORDS)
%     指定したフィールドの中のtileから読み込みます。TILECOORDS は、読み
%     込まれるtileのゼロベースの座標を指定するベクトルです。座標は、tileに
%     よって表わされ、データ要素では表されません。演算が失敗した場合は、
%     STATUS は-1で、他のすべての出力は [] になります。
% 
%     注意：HDFファイルは、多次元配列に対するCスタイルの順番付けを使い
%     ます。一方、MATLABはFORTRANスタイルの順番付けを使います。これ
%     は、MATLAB配列の大きさが、tileの次元の大きさに対して、入れ替えら
%     れることを意味しています。たとえば、tileが3行4列の次元をもつ場合は、
%     DATA は4行3列の大きさになります。PERMUTE コマンドは、必要な変換
%     を行うために役立つコマンドです。
%
% GDwritetile
%     STATUS = HDFGD('writetile',GRID_ID,FIELDNAME, ...
%                  TILECOORDS,DATA)
%     フィールド内のtileに書き込みます。TILECOORDS は、書き込まれる
%     フィールドのゼロベースの座標を指定するベクトルです。座標は、tileによっ
%     て指定し、データ要素では指定しません。DATAのクラスは、指定する
%     フィールドのHDF番号タイプと一致していなければなりません。MATLAB
%     文字列は、HDF charタイプのいずれかと一致するように自動的に変換され
%     ます。他のデータタイプは、厳密に一致しなければなりません。
% 
%     注意：HDFファイルは、多次元配列に対してCスタイルの順番付けを使い
%     ます。一方、MATLABはFORTRANスタイルの順番付けを使います。これ
%     は、MATLAB配列の大きさが、tileの次元の大きさに対して、入れ替えら
%     れることを意味しています。たとえば、tileが3行4列の次元をもつ場合は、
%     DATA は4行3列の大きさになります。PERMUTE コマンドは、必要な変換
%     を行うために役立つコマンドです。
% 
% 実際に作業を行うには、HDF.MEXをコールします。
% 
% 参考：HDF, HDFSW, HDFPT.


%   Copyright 1984-2003 The MathWorks, Inc. 
