% IMPORT   カレントのJavaパッケージとクラスインポートリストの追加
% 
% IMPORT PACKAGE_NAME.* は、指定したパッケージ名をカレントのインポート
% リストに加えます。
% 
% IMPORT PACKAGE1.* PACKAGE2.* ...は、複数のパッケージ名を付加するのに
% 使います。
% 
% IMPORT CLASSNAME は、完全に条件の合ったJava クラス名をインポートリスト
% に加えます。
% 
% IMPORT CLASSNAME1 CLASSNAME2 ... は、複数の完全に条件の合ったJavaクラ
% ス名をインポートリストに加えます。
% 
% パッケージ名やクラス名が文字列に格納される場合は、IMPORT(S) のよう
% な IMPORT の関数形式を使います。
% 
% L = IMPORT(...)は、IMPORTの終了時に、IMPORTが存在するとき、カレントの
% インポートリストの内容を文字のセル配列としてその通りに出力します。
% 入力を与えないL = IMPORTでは、カレントのインポートリストを得ます。
% ここでは、付加されるものはありません。
% 
% IMPORTは、使用されるものの中で、関数のインポートリストのみに影響を与え
% ます。コマンドプロンプトで使われるベースインポートリストも存在します。
% IMPORTがスクリプト内で使われると、スクリプトを読み込む関数のインポー
% トリストに影響を与えるか、または、スクリプトがコマンドプロンプトから読
% み込まれた場合は、ベースインポートリストに影響を与えます。
% 
% CLEAR IMPORTは、ベースインポートリストをクリアします。関数のインポート
% リストは、クリアされません。
% 
% 例題：
%       import java.awt.*
%       import java.util.Enumeration java.lang.*
%       f = Frame;               % java.awt.Frame オブジェクトを作成
%       s = String('hello');     % java.lang.String オブジェクトを作成
%       methods Enumeration      % java.util.Enumeration メソッドのリス
%                                % ト表示
%
% データのインポート
% 種々のタイプのデータを MATLAB にインポートできます。この中には、
% MAT-ファイル、テキストファイル、バイナリファイル、HDF ファイルも含ま
% れています。MAT-ファイルからデータをインポートするには、関数 LOAD を
% 使います。
% MATLAB のインポート関数をGUI で使用するためには、UIIMPORT をタイプし
% ます。
%
% データのインポートの詳細については、つぎのヘッダの下の MATLABヘルプ 
% ブラウザのデータのインポートとエクスポートを参照してください。
%
%       MATLAB -> MATLAB開発環境
%       MATLAB -> External Interfaces/API
% 
% 参考：CLEAR, LOAD


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 01:53:07 $
%   Built-in function.

