function whitebg(fig,c)
%WHITEBG   axesのバックグラウンドカラーの変更
%   WHITEBG(FIG,C)は、ベクトルFIG内のfigureのaxesのデフォルトのバック
%   グランドカラーを、Cで指定した色に設定します。axesの他のプロパティと
%   figureのバックグラウンドカラーは、グラフが適切なコントラストを保持する
%   ように変更されます。Cは、1行3列のrgbカラーまたは'white'や'w'のような
%   色を示す文字列です。axesの色が'none'ならば、figureの色は(axesの色
%   の代わりに)要求した色に設定されます。
%
%   WHITEBG(FIG)は、指定したfigure内のオブジェクトの色の補色を指定
%   します。このシンタックスは、axesのバックグラウンドカラーを、白と黒の
%   間で切り替えるために使用され、そのためWHITBGというコマンド名に
%   なっています。新たなウィンドウまたはCLF RESETに対してデフォルトの
%   プロパティを反映させるためには、ルートウィンドウのハンドル(0)をFIGに
%   設定してください。
%
%   figureを指定しないと、WHITEBGまたはWHITEBG(C)は、カレントのfigure
%   やルートのデフォルトのプロパティに影響を与えるので、後に続くプロット
%   や新たなfigureでは新たな色を使用します。
%
%   WHITEBGは、figure内のすべてのaxesが同じバックグラウンドカラーで
%   あるときに、最も良く機能します。
%
%   参考    COLORDEF.

%   Copyright 1984-2001 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2001/03/01 23:07:49 $
