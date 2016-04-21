% OPENGL OpenGLレンダリングを自動的に選択するように設定
% 
% OpenGL の自動選択モードは、Figureの RendererMode が AUTO に設定されて
% いるときのみ機能します。
% OPENGL AUTOSELECT は、OpenGLが利用可能で、ホストマシンにグラフィック
% スハードウェアがある場合は、OpenGLを自動的に選択します。
% OPENGL NEVERSELECT は、OpenGLの自動選択を行いません。
% OPENGL ADVISE は、OpenGLレンダリングが推奨され、OpenGLが選択されて
% いない場合にコマンドウィンドウに文字列を表示します。
% OpenGL 自身では、カレントの自動選択状態を戻します。
% OPENGL INFO は、ユーザのシステム上のOpenGLのバージョンとベンダに
% 関する情報を表示します。出力される引数は、OpenGL がユーザのシステム上
% で利用可能かどうかを、プログラミングにより決定するために使うことができ
% ます。
% OPENGL DATA は、OPENGL INFO が呼び出されるときに表示される同じ
% データを含む構造体を出力します。
% 
% 自動選択モードは、OpenGLがレンダリングに対して考慮されるかどうかを
% 指定するだけであることに注意してください。レンダリングを明示的に
% OpenGLに設定するわけではありません。そのような場合はFigureの Renderer 
% プロパティを OpenGL にセットしてください。
% 
%  例  set(GCF, 'Renderer','OpenGL');    



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:56:02 $
