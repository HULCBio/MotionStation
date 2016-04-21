% WHICH   関数とファイルの位置の出力
% 
% WHICH FUN は、関数 FUN のフルパス名を表示します。ワークスペースの中の
% 変数、組み込み関数、ロードされたSimulinkモデル、またはロードされたJavaクラ
% ス内のメソッドは、その名前が変数、組込関数、Simulinkモデル、または複数の
% ロードされたJavaクラス内のメソッドであることを示すメッセージを表示します。
% WHICH 自身では、クラスパス上に存在するJavaクラスのメソッドを探索するのみ
% です。
%
% WHICH FUN -ALL は、FUN という名前をもつすべての関数のパスを表示します。
% -ALL フラグは、WHICH のすべての形式で使うことができます。
%
% WHICH FILE.EXT は、指定したファイルがカレントワーキングディレクトリ、または
% MATLABパス上に存在する場合、ファイルのフルパス名を表示します。 EXIST を
% 使って、ファイルが他の場所に存在するか否かをチェックできます。
%
% WHICH FUN1 IN FUN2 は、M-ファイル FUN2 の中の関数 FUN1 のパス名を表
% 示します。FUN2 をデバッグしている間、WHICH FUN1は、同じことを行います。
% このことを利用して、サブ関数またはプライベートな関数をパス上の関数の代わり
% に呼び出すことができるかどうかを決定することができます。
%
% WHICH FUN(A,B,C) は、与えられた入力引数を使って関数のパスを表示します。
% たとえば、g = inline('sin(x)') のとき、which feval(g) は、inline/feval.m
% が呼び込まれることを示します。S = java.lang.String('my Java string') の
% とき、which toLowerCase(S) は、クラス java.lang.String の中の toLowerCase 
% メソッドが呼び込まれることを示します。
%
% S = WHICH(...) は、WHICH の結果をスクリーンに表示する代わりに、文字列Sに
% 出力します。S は、組み込み関数やワークスペース変数に対しては文字列
% 'built-in' または 'variable' です。出力引数があるときは、WHICH を関数形式
% で使わなければなりません。
%
% W = WHICH(...,'-all') は、WHICH の複数サーチバージョンの結果を、セル配列
% W に出力します。W は、通常スクリーンに表示されるパスの文字列を含みます。
% 
% 参考：DIR, HELP, WHO, WHAT, EXIST, LOOKFOR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 01:53:45 $
%   Built-in function.
