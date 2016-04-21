%  HELP Command Window にヘルプテキストを表示
% 
% HELP自身では、すべての主要なヘルプトピックを表示します。主要な各トピッ
% クは、MATLABPATH 上のディレクトリ名に相当します。
%     
% HELP / は、すべての演算子と特殊キャラクタの概要一覧を表示します。
%     
% HELP FUN は、関数 FUN のシンタックスの説明を表示します。
% FUN が MATLAB パスの複数ディレクトリにある場合、HELP は、パス上に見つかる、
% 最初の FUN の情報を表示し、他の(オーバーロードされた) FUN については、
% PATHNAME/FUN または CLASSNAME/METHODNAME を表示します。 
%     
% HELP PATHNAME/FUN は、PATHNAME/FUN のヘルプを表示します。オーバーロード
% された関数に対して、ヘルプを表示するためには、このシンタックスを使用して
% ください。
%
% HELP DIR は、MATLAB ディレクトリ DIR に、各関数の簡単な概要を表示します。
% DIR は、相対部分パス名にすることができます( HELP PARTIALPATH を参照 )。
% DIR をコールする関数では、ディレクトリのすべての関数一覧を表示する
% ために HELP DIR/ を使用してください。
%     
% HELP CLASSNAME.METHODNAME は、完全に条件の合うクラス CLASSNAME のメソッド
% METHODNAME のヘルプを表示します。METHODNAME に対する CLASSNAME を決定する
% ためには、CLASS(OBJ) を使用してください。ここで、METHODNAME は、オブジェクト
% OBJ　と同じクラスです。
%
% HELP CLASSNAME は、完全に条件の合うクラス CLASSNAME のヘルプを表示します。
%
% T = HELP('TOPIC') は、TOPIC のヘルプテキストを、各行を /n で区切られた
% 文字列として出力します。TOPIC は、HELP で使用できる引数です。
%     
% 注意:
% 1. ヘルプテキストがスクリーン上でスクロールする場合は、MORE ONと入力する
% と、スクリーン毎にHELPを停止します。
% 2. ヘルプシンタックスでは、関数名は、強調するために大文字で表わされて
% います。実際には、関数名を常に小文字で入力してください。大文字と小文字
% で表示される Java 関数 (たとえば、 javaObject)は、表示のように大文字と
% 小文字の両方を用いて入力してください。
% 3. ヘルプブラウザの関数のヘルプを表示するためには、DOC FUN を使用して
% ください。これは、グラフィックスや例題などの、付加的な情報を提供します。
% 4. ユーザ自身の M-ファイルのヘルプを作成するための詳細は、DOC HELP を
% 使用してください。
% 5. ヘルプブラウザのオンラインドキュメントにアクセスするためには、HELPBROWSER 
% を使用してください。TOPIC または 他の語について詳細を検索するためには、
% ヘルプブラウザインデックス、または、Search タブを使用してください。
%
% 例題:
%   help close - CLOSE 関数のヘルプを表示
%   help database/close - Database Toolbox のCLOSE 関数のヘルプを表示
%   help database/ - Database Toolbox のすべての関数の一覧表示
%   help database - DATABASE 関数のヘルプを表示
%   help general - ディレクトリ MATLAB/GENERAL のすべての関数の一覧表示
%   help mkdir - MATLAB MKDIR 関数のヘルプを表示
%   help internet.ftp - INTERNET.FTP のコンストラクタ、INTERNET.FTP.FTP 
%                       の表示
%   help internet.ftp.mkdir は、INTERNET.FTP クラスの MKDIR メソッドの
%   ヘルプを表示します。
%   t = help('close') - CLOSE 関数のヘルプを取得し、t に文字列として保存
%  
% 参考 DOC, DOCSEARCH, HELPBROWSER, HELPWIN, LOOKFOR, MATLABPATH,
%      MORE, PARTIALPATH, WHICH, WHOS, CLASS.


%   Copyright 1984-2004 The MathWorks, Inc.
