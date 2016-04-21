%DEPFUN  M/P-ファイルの影響する関数の位置
% TRACE_LIST = DEPFUN(FUN) は、FUN の従属関数名のセル配列を出力します。
% FUN は、コールする関数に直接関与します。すなわち、FUN は、FUN をコール
% した関数によりコールされる関数などに、直接的には関与しません。
% 発信される情報に基づき、ファイルが解析され、終了されます。
% 通常生成される TRACE_LIST は、FUN が実際に評価されてもコールされない
% 'extra' ファイルを含みます。ファイルは、オリジナルの引数により
% リストされ、追加の従属ファイルの並べ替えられたリストが続きます。 
% 複製された引数ファイルは、最終リストから除かれません。
% スクリプト M-ファイルは含まれますが、解析されません。
%
% MATLABPATH が、'相対的な' ディレクトリを含む場合、これらのディレクトリの
% ファイルはいずれも '相対的な' パスをもちます。
%
% [TRACE_LIST, BUILTINS, MATLAB_CLASSES] = DEPFUN(FUN) は、FUN やそれに
% 従属する関数によってコールされるすべての MATLAB 組み込み関数や MATLAB 
% クラスのセル配列も出力します。
%
% すべての可能な出力引数をもった DEPFUN に対するシンタックスを示します。
%    [TRACE_LIST, BUILTINS, MATLAB_CLASSES, PROB_FILES, PROB_SYMBOLS,...
%                EVAL_STRINGS, CALLED_FROM, OPAQUE_CLASSES] = DEPFUN(FUN)
% ここで、引数はつぎの意味をもっています。
%
% PROB_FILES は、DEPFUN が解釈、配置、アクセスできない M/P ファイルの構
% 造体配列です。解釈に関する問題点は、MATLAB のシンタックスエラーの原因
% になります。
% 構造体のフィールドは、つぎのものになることができます。
%
%          .name       - ファイルへのパス
%          .listindex  - trace_list インデックス
%          .errmsg     - エラーメッセージ文字列
%
% PROB_SYMBOLS [NOT IMPLEMENTED] は、そのシンボル名 DEPFUN が、関数、または、
% 変数として解くことができないことを示す構造体配列です。
% 構造体のフィールドは、つぎのものになることができます。     
%
%          .name       - シンボル名
%          .fcn_id     - trace_list インデックスのdoubleの配列
%
% EVAL_STRINGS [NOT IMPLEMENTED] は、TRACE_LIST の中の関数が、 eval, evalc, 
% evalin, feval 等をコールしている場所を示す構造体配列です。eval やそれと
% 同様な関数が評価する文字列は、TRACE_LIST の中に存在しない関数を使用します。
% 構造体のフィールドは、つぎのものになることができます。
%
%          .fcn_name   - ファイルのパス
%          .lineno     - ファイルのライン番号のdoubleの配列
%
% CALLED_FROM は、各要素が doubleの配列のセル配列であり、だれが関数をコール
% するかを示します。CALLED_FROM は、 TRACE_LIST(CALLED_FROM{i}) が
% TRACE_LIST{i} をコールする FUN のすべての関数をリストするように配列
% されます。CALLED_FROM と TRACE_LIST は、同じ長さです。 空のdoubleの配列は、
% trace_list ファイルが参照されない引数ファイルである、または、終了
% に追加される参照されない 'special' ファイルであることを意味します。
%
% OPAQUE_CLASSES は、 TRACE_LIST の中の1つまたは複数のファイルにより使用される
% Java および COM クラス名を含む 'opaque' クラス名のセル配列です。
%
% [...] = DEPFUN(FILE1,FILE2,...) は、順番に個々のファイルを処理します。
% FILEN は、ファイルのセル配列になることもできます。
%
% [...] = DEPFUN(FIG_FILE) は、.FIG  ファイル FIG_FILE の中に定義されている
% GUI のコールバック文字列の間で、従属関数を探索します。
%
% DEPFUN は、オプションのコントロール入力文字列をもっています。
%
%    '-toponly' 	従属するファイルに対してデフォルトのリカーシブ
%                       なサーチを変更し、これによりDEPFUN は、組み込
%                       み、M/P/MEX ファイルや、DEPFUN への入力として
%                       リストされている関数内でのみ使われるクラスの
%                       一覧を出力することを意味します。
%    '-verbose'		追加の内部メッセージを出力します。
%    '-quiet'           概要の出力を行いません。 エラーメッセージ、
%                       ワーニングメッセージのみ出力します。デフォルト
%                       では、概要のレポートがコマンドウィンドウに表示
%                       されます。
%    '-print','file'    ファイルにフルレポートを出力します。
%    '-all'             利用可能なすべての左辺を計算し、レポートに
%                       結果を表示します。指定した引数のみ出力します。
%    '-notrace'		オリジナルの引数以外にトレースを出力しません。
%			パスにある場合、.fig ファイルに対するコールバック
%                       を検索します。
%    '-expand'		コールされたもの、または コールリストのインデックス
%                       とともにフルパスを指定します
%    '-calltree'	リストの代わりにコールリストを出力します。
%			これは、コールされたもののリストから余分なステップと
%			して得られます。
%
%    Output:
%
%      Summary:
%
%        ==========================================================
%        depfun report summary:
%
%          or
%
%        depfun report summary: (top only)
%        ----------------------------------------------------------
%        -> trace list:       ### files  (total)
%			      ### files  (total arguments)
%                             ### files  (arguments off MATLABPATH)
%                             ### files  (argument duplicates on MATLABPATH)
%                             ### files  (argument duplicates off MATLABPATH)
%        -> builtin list:     ### names
%        -> MATLAB classes:   ### names  (builtin, MATLAB OOPS)
%        -> problem list:     ### files  (argument)
%                             ### files  (other)
%        -> problem symbols:  NOT IMPLEMENTED
%        -> eval strings:     NOT IMPLEMENTED
%        -> called from list: ### files  (argument unreferenced)
%                             ### files  (argument referenced)
%                             ### files  (other referenced)
%			      ### files  (other unreferenced)
%
%           OR if -calltree is passed
%
%        -> call list:        ### files  (argument with no calls)
%                             ### files  (argument with calls)
%                             ### files  (other with calls)
%			      ### files  (other with no calls)
%        -> opaque classes:   ### names  (Java, etc.)
%        ----------------------------------------------------------
%        Note: 1. Use argument  '-quiet' to not print this summary.
%	       2. Use arguments '-print','file' to produce a full
%                 report in file.
%              3. Use argument  '-all' to display all possible
%                 left hand side arguments in the report(s).
%        ==========================================================
%
%      Full:
%
%        depfun report:
%  
%           or
%
%        depfun report: (top only)
%
%        -> trace list:   
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%
%           OR if called from list is generated then:
%
%           For complete list: See -> called from:
%
%           Files not on MATLABPATH:
%           ----------------------------------------------------------
%           1. <file>
%           ...
%           ----------------------------------------------------------
%
%           HG factory callback names:
%           ----------------------------------------------------------
%           ...
%           ----------------------------------------------------------
%  
%        -> builtin list:
%           ----------------------------------------------------------
%           1: <name>
%           ...
%           ----------------------------------------------------------
%  
%        -> MATLAB classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem list:
%           ----------------------------------------------------------
%           #: <file>
%              <message>
%           ...
%           ----------------------------------------------------------
%  
%        -> problem symbols: NOT IMPLEMENTED
%  
%        -> eval strings:    NOT IMPLEMENTED
%  
%        -> called from list: (by trace list)
%
%           OR if -calltree is passed
%
%        -> call list: (by trace list)
%           ----------------------------------------------------------
%           1: <file>
%              <called from (or call) array>
%
%              OR if -expand is passed
%               
%              <called from (or call) array with actual path>
%
%           2: <file>
%              <called from (or call) array>
%           ...
%           ----------------------------------------------------------
%           Note: list the contents of the temporary file associated
%                 with each .fig file.
%  
%        -> opaque classes:
%           ----------------------------------------------------------
%           1: <class>
%           ...
%           ----------------------------------------------------------
%
% 参考 DEPDIR, CKDEPFUN

%    DEPFUN has additional undocumented optional control input strings.
%
%    '-savetmp' 	saves any temporary M-files in the current
%                       directory.
%    '-nosort'		does not sort the dependency files found.
%
%    Copyright 1984-2004 The MathWorks, Inc. 
