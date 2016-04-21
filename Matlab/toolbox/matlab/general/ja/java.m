% MATLABの中からのJavaの使用
%
% ユーザは、クラス名を使って、MATLABの中からJavaオブジェクトを作成できま
% す。
%
%    >> f = java.awt.Frame('My Title')
%
%    f =
%
%    java.awt.Frame[frame0,0,0,0x0,invalid,hidden,layout=java.awt.Border
%    Layout,resizable,title=my title]
%
% つぎのMATLABシンタックスを使っても、Javaオブジェクトのメソッドを呼び出す
% ことができます。
%       >> setTitle (f, 'new title' )
%       >> t = getTitle(f)
%   
%       t =
%   
%       new title
%
% Javaシンタックスを使っても、Javaオブジェクトのメソッドを呼び出すことができま
% す。
%       >> f.setTitle ('new title' )
%       >> t = f.getTitle
%   
%       t =
%   
%       new title
%
% この例題では、f は上記で作成された java.awt.Frame オブジェクトで、getTitle 
% と setTitle は、そのオブジェクトのメソッドです。
%
% 変更および強化された組み込み関数
%
% METHODS
% 関数METHODは、Javaのクラス名を引数として受け入れます。METHODSは、
% -full 付きで使用できます。-full は、METHODに、Javaのクラスのすべての
% メソッドの全記述を出力させます。この中には、Javaクラスの中のメソッドの
% シグネチャや使用に関する他の情報も含まれています。
% 
% METHODSは、-full なしで、すべての重複している名前を削除したコンパクトな
% メソッドリストを出力します。
%
% FIELDNAMES
% 関数FIELDNAMESは、Javaオブジェクトを引数として受け入れます。FIELDNAMES
% もまた、-full 付きで使用できます。-full は、Javaオブジェクトのすべてのパ
% ブリックなフィールドの完全な説明を表示させます。その中には、属性、タイ
% プ、継承も含んでいます。-full なしのFIELDNAMESは、コンパクトなフィール
% ド名リストを出力します。
%
% ISA
% ISA関数も、Javaのクラス名を受け入れます。配列が指定したJavaクラスのメ
% ンバの場合、または、指定したJavaクラスからのクラス継承の場合１を出力し
% ます。たとえば、isa(x, 'java.awt.Frame')、 isa(x, 'java.awt.Component'),
% isa(x, 'java.lang.Object')は、xがクラスjava.awt.Frameのオブジェクトを
% 含んでいると、すべて1を出力します。
%
% EXIST
% 関数EXISTは、2番目の引数 'class' を受け入れます。EXIST は、最初の引数
% がMATLABのJavaクラスパス上のJavaクラス名の場合、8を出力します。
%
% CLASS
% 関数CLASSは、JavaオブジェクトのJavaクラス名を出力させるように強化され
% ます。
%
% DOUBLE
% DOUBLE は、java.lang.Integer, java.lang.Byte等のような java.lang.Number
% から継承されるすべてのJavaオブジェクトやオブジェクトのJava配列を
% MATLABの double に変換するためにオーバロードされました。'toDouble'
% メソッドを含む任意のJavaクラスは、MATLABを使って、そのクラスのオブ
% ジェクトをMATLABの double に変換することができます。すなわち、MATLABは、
% Javaクラスの中で'toDouble'メソッドをコールして、このようなオブジェクトを
% MATLABの double に変換します。
%
% CHAR
% CHAR は、すべての java.lang.String オブジェクトをMATLABキャラクタ
% 配列に変換したり、java.lang.String のすべてのJava配列をキャラクタの
% MATLAB配列に変換するためにオーバロードされました。'toChar'メソッドを
% 含む任意のJavaクラスは、MATLABを使って、そのクラスのオブジェクトを 
% MATLABキャラクタに変換できます。すなわち、MATLABは、Javaクラスの中
% の'toChar'メソッドをコールして、このようなオブジェクトをMATLABキャラ
% クタに変換します。
%
% INMEM
% INMEMは、オプションの3番目の出力引数を受け入れるように拡張されていま
% す。仮に設定すると、この3番目の引数は、ロードされるすべてのJavaクラスの
% リストを出力します。
%
% WHICH
% WHICHは、引数文字列と一致するメソッドに対して、すべてのロードされた
% Javaクラスを探索します。
% 
% CLEAR
% CLEAR IMPORTは、ベースインポートリストをクリアします。
%
% SIZE
% 関数SIZEがJava配列に適用されると、出力される行数はJava配列の長
% さで、列数は常に1になります。SIZE が配列のJava配列に適用されると、結
% 果は、配列からなる配列の一番上のレベルの配列のみを記述します。
%
% 新しい組み込み関数
%
% METHODSVIEW
% 関数 METHODSVIEW は、指定したクラスで実現されるすべてのメソッドの情
% 報を表示します。METHODSVIEW は、新しいウィンドウを作成し、読みやすいテ
% ーブルフォーマットで、情報を書式化します。
%
% METHODSVIEW PACKAGE_NAME.CLASS_NAME は、Javaクラス 
% PACKAGE_NAME のパッケージから利用可能なJavaクラス CLASS_NAME を
% 記述する情報を表示します。
%
% METHODSVIEW CLASS_NAME は、インポートされたJavaクラスまたはMATLAB
% クラス CLASS_NAME を記述する情報を表示します。
%
% 例題
% % java.awt.MenuItem クラスの中のすべてのメソッドに関する情報をリストします。
%   methodsview java.awt.MenuItem
%
% IMPORT  カレントJavaパッケージとクラスインポートリストに付加します。
% IMPORT PACKAGE_NAME* は、指定したパッケージ名をカレントインポートリス
% トに付加します。IMPORT PACKAGE_NAME.CLASS_NAME は、指定したJavaクラ
% スをインポートします。
%
% IMPORT PACKAGE1.* PACKAGE2.CLASS_NAME ... は、複数のパッケージを付
% 加するために使用します。
%
% L = IMPORT(...)は、IMPORTの終了時に、IMPORTが存在するとき、カレントの
% インポートリストの内容を文字列のセル配列としてその通りに出力します。
%
% L = IMPORTは、入力を与えない場合は、カレントのインポートリストを得ます。
% ここでは、付加されるものはありません。
%
% IMPORT は、使用されるものの中で、関数のインポートリストのみに影響を与え
% ます。コマンドプロンプトで使われるベースインポートリストも存在します。
% IMPORTがスクリプト内で使われると、スクリプトを読み込む関数のインポートリス
% トに影響を与えるか、またはスクリプトがコマンドプロンプトから読み込まれた
% 場合は、ベースインポートリストに影響を与えます。
%
% CLEAR IMPORT は、ベースインポートリストをクリアします。
%
% 例題
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % java.awt.Frameオブジェクトを作成
%       s = String('hello');     % java.lang.Stringオブジェクトを作成
%       methods Enumeration      % java.util.Enumerationメソッドのリスト
% 
%  ISJAVA  Javaオブジェクトの検出
%  ISJAVA(J)は、JがJavaオブジェクトの場合１、他の場合0を出力します。
%
% コンストラクタが、指定したクラスや識別子と一致していない場合、エラーが
% 生じます。
%
% javaArray
% 関数 javaArray は、指定した次元をもつJava配列を作成します。
%
% JA = javaArray(CLASS_NAME,DIM1,...) は、Java配列オブジェクト(Javaの次
% 元をもつオブジェクト)を出力し、その要素クラスは、キャラクタ文字列 
% CLASSNAME で指定したJavaクラスです。
%
% 例題
%   % 10x5 java.awt.Frame Java 配列を作成
%     ja = javaArray('java.awt.Frame',10,5);
%
% javaMethod 
%   関数 javaMethod は、指定したJavaメソッドを読み込みます。
%
%   X = javaMethod(METHOD_NAME,CLASS_NAME,X1,...,Xn) は、X1,...,Xn と一致
%   する引数リストをもつクラス CLASS_NAME 内の static メソッド METHOD_
%   NAME を読み込みます。
%
%   javaMethod(METHOD_NAME,J,X1,...,Xn) は、X1,...,Xn と一致する引数リス
%   トをもつオブジェクト J 上のnonstatic メソッド METHOD_NAME を読み込み
%   ます。
%
% 例題
%   % nonstatic メソッド setTitle を読み込みます。ここで、frameObj は、
%   % java.awt.Frame オブジェクトです。
%     frameObj = java.awt.Frame;
%     javaMethod('setTitle', frameObj, 'New Title');
%
% javaObject
%   関数 javaObject は、指定したJavaクラスのオブジェクトを作成します。
%
%   J = javaObject(CLASS_NAME,X1,...,Xn) は、X1,...,Xn に一致する引数リス
%   トをもつクラス CLASS_NAME 用のJavaコンストラクタを読み込んで、新し
%   いオブジェクトを出力します。
%
% 例題
%   % クラス java.lang.String のJavaオブジェクトを作成し、出力します。
%     strObj = javaObject('java.lang.String','hello')
%
% Caveats
%
% 1つのサブスクリプトのみを使って、配列からなるJava配列がインデックス付け
% された場合、戻り値は、配列からなる配列のトップレベル配列になり、配列から
% なる配列の線形化形式のスカラ要素ではありません。

