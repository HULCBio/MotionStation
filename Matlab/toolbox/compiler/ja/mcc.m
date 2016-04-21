% MCC   MATLAB から C/C++ Compiler (Version 3.0)へ
%
% MCC [-options] fun [fun2 ...] [mexfile1 ...] [mlibfile1 ...]
%
% fun.mをfun.cまたはfun.cppに変換し、オプションとしてサポートされている
% バイナリファイルを作成します。デフォルトでは、生成ファイルをカレント
% ディレクトリに保存します。
%
% 複数のM-ファイルが指定された場合は、CまたはC++ファイルは、各々の
% M-ファイルに対して生成されます。
%
% Cまたはオブジェクトファイルが指定された場合は、それらは生成された
% Cファイルと共にMEXまたはMBUILDに渡されます。
%
% MEX-ファイルが指定された場合は、MCCはラッパーコードを作成し、コンパイル
% されたM-ファイルから指定されたMEX-ファイルを作成します。また、同じ
% 名前のMEX-ファイルとM-ファイルが同じディレクトリにある場合、MEX-ファイル
% を指定すれば、MCCはM-ファイルの代わりにMEX-ファイルを利用しますが、
% それ以外では、MEX-ファイルよりも、M-ファイルが優先されます。
%
% MLIBファイルは、MCCによって作成される共有ライブラリ内のファンクション
% を記述します(後述の-W libを参照)。MLIBファイルを指定すると、その
% ライブラリ内にあるファンクションを利用する必要があれば常にMLIBファイル
% の対応する共有ライブラリとリンクするようにMCCに伝えます。
% MLIBファイルと対応する共有ライブラリファイルは、同一ディレクトリ内に
% なければなりません。
%
% もしコンフリクトしたオプションがMCCに渡された場合は、コンフリクトした
% オプションの一番右のものが利用されます。
%
% オプション:
%
% A <option> 注釈を設定します。つぎの表は、使用可能な <option>文字列
% とその効果をまとめています。
%
%       annotation:all (*)  - ソースM-ファイル内の全ての行は、作成される
%                             出力ファイルにコメントとして記述されます。
%
%       annotation:comments - ソースM-ファイル内のコメントは、作成される
%                             出力ファイルにコメントとして記述されます。
%
%       annotation:none     - ソースM-ファイル内のテキストは、作成される
%                             出力ファイルには記述されません。
%
%       line:on             - 生成された出力ファイルの各行に、
%                             対応するM-ファイルの行番号が追加されます。
%
%       line:off (*)        - #line命令は生成されません。
%
%       debugline:on        - 実行時エラーメッセージは、ソースファイル名
%                             とエラーが生じた行番号をレポートします。
%
%       debugline:off (*)    - 実行時エラーメッセージは、エラーが生じた
%                              ソースに関する情報をレポートしません。
%
%       (*) は、デフォルトの設定を示します。
%
%   b  M-ファイルの与えられたリストに対して、MS Excel 互換表現の関数
%      を作成します。
%
%   B <filename>  バンドルファイルを指定します。<filename> は、Compiler
%       のコマンドラインオプションを含むテキストファイルです。Compilerは
%       "-B <filename>" がバンドルファイルの内容で置き換わったかのように
%       動作します。これらのファイル内の新しい行が許可され、空白として扱わ
%       れます。
%       The MathWorksは、以下に対してオプションファイルを用意しています。
%
%           ccom      Windows上で、C COM と互換性のあるオブジェクトを
%                     ビルドする場合に使用します。(COM Builderが必要です)
%
%           cexcel    Windows上で、C MS Excel Compatable COM をビルドする
%                     場合に使用します。(Excel用のMATLAB Add-In Builderが
%                     必要です)
%
%           csglcom   Windows上で、C Graphics Libraryを使用して、C COM 
%                     と互換性のあるオブジェクトをビルドする場合に使用
%                     します。(COM Builderが必要です)  
%
%           csglexcel Windows上で、C Graphics Libraryを使用して、C MS 
%                     Excel と互換性のあるオブジェクトをビルドする場合に
%                     使用します。(Excel用のMATLAB Add-In Builderが必要です)
%
%           csglsharedlib
%                     C Graphics Library共有ライブラリをビルドする場合に使用
%                     します。
%
%           cppcom    Windows上で、C++ COM と互換性のあるオブジェクトをビルド
%                     する場合に使用します。(COM Builderが必要です) 
%
%           cppexcel  Windows上で、C++ MS Excel Compatiable COM オブジェクト
%                     をビルドする場合に使用します。
%                     (Excel用のMATLAB Add-In Builderが必要です)  
%
%           cppsglcom Windows上で、Graphics Libraryを使用して、C++ COMと
%                     互換性のあるオブジェクト(COM Builderが必要です)
%
%           cppsglexcel
%                     Windows上で、Graphics Libraryを使用して、C++ MS 
%                     Excel と互換性のあるオブジェクトをビルドする場合に
%                     使用します。(Excel用のMATLAB Add-In Builder が必要です)
%
%           cpplib    C++ ライブラリをビルドする場合に使用します。
%
%           csharedlib
%                     C 共有ライブラリをビルドする場合に使用します。
%
%           csglsharedlib
%                     C Graphics共有ライブラリをビルドする場合に使用します。
%
%           pcode     MATLAB P-Code ファイルをビルドする場合に使用します。
%
%           sgl       スタンドアロンC Graphics Libraryアプリケーションを
%                     作成する場合に使用します。
%
%           sglcpp    スタンドアロンC++ Graphics Libraryアプリケーション
%                     を作成する場合に使用します。
%
%   c  Cコードのみ。M-ファイルをCに変換しますが、MEX-ファイル、またはス
%       タンドアロンアプリケーションを生成しません。これは、コマンドライ
%       ンで一番右の引数として、"-T codegen"を用いる場合と等価です。
%
%   d <directory>  出力ディレクトリ。全ての生成ファイルは、<directory> 
%       に置かれます。
%
%   F list  カレントの値と簡単な説明を共に、次のコマンド形式で利用可能な
%       <option>の一覧を表示します。
%
%   F <option>:<number>  設定フォーマットオプション。フォーマットオプ
%       ション<option>に、値<value>を割り当てます。<option>については、
%       "F list"を参照して下さい。
%
%   f <filename>  MEXやMBUILDをコールする時、指定されたオプションファイ
%       ルを使用します。これで他のANSIコンパイラを利用できます。このオプ
%       ションは、MEXやMBUILDスクリプトに直接渡します。詳細の情報につい
%       ては、"External Interfaces/API"を参照して下さい。
%
%   G   デバッグのみ行ないます。単にdebugging onを返すので、デバッグシン
%       ボル情報が含まれます。
%
%   g   デバッグ。デバッグシンボル情報を含みます。このオプションでは、
%       -A debugline:on スイッチも含みます。これは、生成コードの性能に影
%       響を与えるでしょう。例えデバッグ情報を要求しても、デバッグライン
%       情報の利用 -g -A debugline:off で関連する性能の低下はありません。
%       このオプションには、-O none スイッチもも含まれます。そのスイッチ
%       で、全てのコンパイラの最適化は止められます。もし幾つかの最適化を
%       オンとしたい場合は、デバッグのスイッチの後で指定します。
%
%   h   補助関数をコンパイルします。コールされる全てのM-ファンクションは
%       作成されるMEX-ファイルやスタンドアロンアプリケーションにコンパイ
%       ルされます。
%
%   i   ライブラリを作成する場合、エクスポートされるシンボルのリストの
%       コマンドラインで述べられたエントリーポイントのみ含みます。
%
%   I <path>  インクルードパス。M-ファイルを検索するパスのリストを<path>
%       に追加します。MATLABのパスは、MATLAB実行時に自動的に読み込まれま
%       すが、DOSやUnixシェルからの実行時には読み込まれません。
%       "help mccsavepath"を参照して下さい。
%
%   L <option>  言語。ターゲット言語を設定します。<option>はCに対しては
%       "C"、C++に対しては"Cpp"、MATLAB P-コードに対しては"P"となります。
%
%   l   行。実行時エラーが発生したファイル名と行番号をレポートするコード
%       を生成します。(-A debugline:on と等価です)
%
%   m   Cスタンドアロンアプリケーションを作成するマクロ。これは、オプ
%       ション"-t -W main -L C -h -T link:exe libmmfile.mlib"と等価です。
%       このオプションは、次のファイル内にあります。
%       <MATLAB>/toolbox/compiler/bundles/macro_option_m
%       注意: "-h"は、補助関数が含まれることを意味します。
%
%   M "<string>"  実行ファイルを作成するために利用されるMBUILDやMEXスク
%       リプトに<string>を渡します。-Mが数回使用されると、一番右のものが
%       利用されます。
%
%   o <outputfilename>  出力名。(MEXやスタンドアロンアプリケーションなど)
%       最終的な実行可能な出力ファイル名を<outputfilename>と設定します。
%       適当な、あるいはプラットフォーム依存の拡張子が<outputfilename>に
%       追加されます。(例えば、PCスタンドアロンアプリケーションに対しては
%       ".exe"、SolarisのMEX-ファイルに対しては".mexsol")
%
%   O <optimization>   最適化。3つの可能なことがあります。
%
%       <optimization class>:[on|off] - クラスのオンオフ。
%       例:  -O fold_scalar_mxarrays:on
%
%       list - 有効な最適化クラスをリストします。
%
%       <optimization level> - 最適化のオンオフを決定するための
%       opt_bundle_<level>がコールされるバンドルファイルを利用します。
%       例えば、"-O all"はopt_bundle_allがコールされるバンドルファイルを
%       探し、その時のスイッチを利用します。通常の最適化のレベルは"all"
%       あるいは"none"です。デフォルトでは、全ての最適化がオンとなってい
%       ます。
%
%   p   C++スタンドアロンアプリケーションを生成するマクロ。これは、
%       "-t -W main -L Cpp -h -T link:exe libmmfile.mlib"と等価です。
%       このオプションは、次のファイル内にあります。
%       <MATLAB>/toolbox/compiler/bundles/macro_option_p
%       注意: "-h"は、補助関数が含まれることを意味します。
%
%   S   Simulink C-MEX S-functionを生成するマクロ。これは、
%       "-t -W simulink -L C -T link:mex libmatlbmx.mlib"と等価です。
%       このオプションは、次のファイル内にあります。
%       <MATLAB>/toolbox/compiler/bundles/macro_option_S
%       注意: "-h"がないのは、補助関数が含まれないことを意味します。
%
%   t   Mコードをターゲット言語に変換。コマンドラインで指定されたM-ファ
%       ンクションをCまたはC++関数に変換します。このオプションは、全ての
%       マクロオプション内に含まれます。省略すると、M-ファイルに対応する
%       C/C++ファイルを生成せずにラッパーC/C++ファイルを生成することがで
%       きます。
%
%   T <option>  ターゲットの段階とタイプを指定します。次の表に、有効な
%   <option>の文字列とそれらの効果を示します。
%
%       codegen            - M-ファイルをC/C++ファイルに変換し、ラッパー
%                            ファイルを作成します。(これは-Tのデフォルト
%                            設定です。)
%       compile:mex        - codegenと同じですが、更にC/C++ファイルを
%                            Simulink S-Fuction MEX-ファイルへのリンク
%                            可能なオブジェクト形式にコンパイルします。
%       compile:mexlibrary - codegenと同じですが、更にC/C++ファイルを
%                            通常の(非S-Fuction) MEX-ファイルへのリンク
%                            可能なオブジェクト形式にコンパイルします。
%       compile:exe        - codegenと同じですが、更にC/C++ファイルを
%                            スタンドアロンの実行ファイルへのリンク可能な
%                            オブジェクト形式にコンパイルします。
%       compile:lib        - codegenと同じですが、C/C++ファイルを共有
%                            ライブラリ/DLLへのリンク可能なオブジェクト
%                            形式にコンパイルします。
%       link:mex           - compile:mexと同じですが、Simulink S-fuction
%                            Mex-ファイルにオブジェクトファイルをリンク
%                            します。
%       link:mexlibrary    - compile:mexlibraryと同じですが、通常の
%                            (非S-Fuction) MEX-ファイルにオブジェクト
%                            ファイルをリンクします。
%       link:exe           - compile:exeと同じですが、スタンドアロン実行
%                            ファイルにオブジェクトファイルをリンクします。
%       link:lib           - compile:libと同じですが、共有ライブラリ/DLL
%                            にオブジェクトファイルをリンクします。
%
%   u <number>  生成されるSimulink S-Fuctionへの入力数が、<number>である
%       ことを指定します。"-S"もしくは"-W simulink"オプションの一方が指
%       定されている場合にのみ有効です。
%
%   v   冗長。コンパイルステップを表示します。
%
%   w list   次のコマンドで利用可能な<msg>文字列と共に、それらが対応する
%       ワーニングメッセージのフルテキストで表示します。
%
%   w <option>[:<msg>] ワーニング。利用可能なオプションは、"enable"や
%       <disable>、<error>です。"enable:<msg>"あるいは"disable:<msg>"が
%       指定されると、<msg>に関連するワーニングを表示あるいは非表示にし
%       ます。"error:<msg>"が指定されると、<msg>に関連するワーニングを
%       表示させ、エラーとしてそのワーニングの例として扱います。":<msg>"
%       がない<option>が指定されると、Compilerはその働きを全ワーニング
%       メッセージに適用します。前Compilerバージョンとの後退互換性として、
%       (optionを付けない)"-w"は、"-w enable"と同じです。
%
%   W <option>  ラッパー関数。Compilerによって生成されるラッパーファイル
%       のタイプを指定します。<option>は、"mex", "main", "simulink", 
%       "lib:<string>", "none" (デフォルト)の中の1つとなります。libラッパー
%       では、<string>は作成される共有ライブラリ名と同じです。"lib"ラッパー
%       作成時に、MCCは共有ライブラリ内の関数を記述したMLIBファイルも
%       作成します。
%
%   x   MEX-ファイルを生成するマクロ。これはオプション
%       "-t -W mex -L C -T link:mex libmatlbmx.mlib"と等価です。この
%       オプションは、次のファイル内にあります。
%       <MATLAB>/toolbox/compiler/bundles/macro_option_x
%       注意: "-h"がないのは、補助関数が含まれないことを意味します。
%
%   y <number>  生成されるSimulink S-Fuctionからの出力数が、<number>で
%       あることを指定します。"-S"もしくは"-W simulink"オプションの一方が
%       指定されている場合にのみ有効です。
%
%   Y <license.dat file>  デフォルトのlicense.datを指定された引数で置き
%       換えます。
%
%   z <path>  ライブラリとインクルードファイルに対して利用するパスを指定
%       します。このオプションは、MATLABROOTの代わりにCompilerのライブラリ
%       に対して指定したパスを使用します。
%
%   ?   ヘルプ。このヘルプメッセージを表示します。
%
% 例:
%
% myfun.mをCに変換し、MEX-ファイルを作成します。
%       mcc -x myfun
%
% myfun.mをCに変換し、スタンドアロン実行ファイルを作成します。
%       mcc -m myfun
%
% myfun.mをC++に変換し、スタンドアロン実行ファイルを作成します。
%       mcc -p myfun
%
% myfun.mをCに変換し、Simulink S-Fuctionを作成します。
% (可変サイズの入出力を利用):
%       mcc -S myfun
%
% myfun.mをCに変換し、Simulink S-Fuctionを作成します。
% (1入力2出力でのコールを明示):
%       mcc -S -u 1 -y 2 myfun
%
% myfun.mをCに変換しスタンドアロン実行ファイルを作成します。/files/source
% ディレクトリ内でmyfun.mを検索し、/files/targetディレクトリ内に生成
% されるCファイルと実行ファイルを置きます。
%       mcc -m -I /files/source -d /files/target myfun
%
% myfun.mをCに変換しMEX-ファイルを作成します。またmyfun.mにより直接あ
% るいは間接的にコールされた全てのM-ファンクションを変換し、インクルード
% します。オリジナルのM-ファイルのフルテキストをCのコメントとして対応
% するCファイルに組み込みます。
%       mcc -x -h -A annotation:all myfun
%
% myfun.mを一般的なCに変換します。
%       mcc -t -L C myfun
%
% myfun.mを一般的なC++に変換します。
%       mcc -t -L Cpp myfun
%
% myfun1.mとmyfun2.mからC MEXラッパーファイルを作成します。
%       mcc -W mex -L C libmatlbmx.mlib myfun1 myfun2
%
% (1回のmccのコールで)myfun1.mとmyfun2.mからCに変換し、スタンドアロン
% 実行ファイルを作成します。
%       mcc -m myfun1 myfun2
%
% (各々のmccのコール毎に出力ファイルを作成して)myfun1.mとmyfun2.mから
%   Cに変換し、スタンドアロン実行ファイルを作成します。MLIBファイル
% "libmmfile.mlib"はラッパーファイル作成時と最終実行ファイル作成時のみ
% 指定が必要です。
%
%     mcc -t -L C myfun1                            % myfun1.c 作成
%     mcc -t -L C myfun2                            % myfun2.c 作成
%     mcc -W main -L C myfun1 myfun2 libmmfile.mlib % myfun1_main.c 作成
%     mcc -T compile:exe myfun1.c                   % myfun1.o 作成
%     mcc -T compile:exe myfun2.c                   % myfun2.o 作成
%     mcc -T compile:exe myfun1_main.c              % myfun1_main.o 作成
%     mcc -T link:exe myfun1.o myfun2.o myfun1_main.o libmmfile.mlib
%   
% a0.mとa1.mから"liba"という共有/ダイナミックリンクライブラリを作成します。
% ここで、a0もa1もどちらもlibmmfile内の関数をコールしません。
%       mcc -t -W lib:liba -T link:lib a0 a1
%   
% a0.mとa1.mから"liba"という共有/ダイナミックリンクライブラリを作成します。
% ここで少なくともa0とa1の内の1つはlibmmfile内の1つ以上の関数をコール
% します。Cコードコンパイル時には、LIBMMFILEを1に定義します。
%    mcc -t -W lib:liba -T link:lib a0 a1 libmmfile.mlib -M "-DLIBMMFILE=1"
%   
% (1回の mcc の呼び出しで)myfun.m からCに変換し、グラフィックスライブラリ
% を用いるスタンドアロン実行可能ファイルを作成します。
%       mcc -B sgl myfun1 
%   
% (1回の mcc の呼び出しで)myfun.m からC++に変換し、グラフィックスライブラリ
% を用いるスタンドアロン実行可能ファイルを作成します。
%       mcc -B sglcpp myfun1 
%        
% MATLAB C/C++ Graphics Libraryをコールする、a0.mとa1.mから"liba"と
% いう共有/ダイナミックリンクライブラリを作成します。
%       mcc -B sgl -t -W libhg:liba -T link:lib a0 a1 
%   
% 注意: PCでは、上記の.oで終わるファイル名は、実際には.objとなります。
%
% 参考 : COMPILER/FUNCTION, MCCSAVEPATH, REALONLY, REALSQRT, REALLOG, 
%        REALPOW, COMPILER_SURVEY, COMPILER_BUG_REPORT, MEX, MBUILD.


% Copyright 1984-2000 The MathWorks, Inc.
