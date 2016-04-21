% SELECTMOVERESIZE   オブジェクトの対話的な選択、移動、リサイズ、コピー
% 
% SELECTMOVERESIZE は、ボタンダウン機能として、AxesとUicontrolグラフィックス
% オブジェクトの選択、移動、リサイズ、コピーを扱います。
% 
% たとえば、つぎのステートメントは、カレントAxesのボタンダウン機能を
% SELECTMOVERESIZE に設定します。
% 
%    set(gca,'ButtonDownFcn','selectmoveresize')
%
% A = SELECTMOVERESIZE は、つぎのものを含む構造体配列を出力します。
%  A.Type    : 動作のタイプを含む文字列。Select、Move、Resize、Copy の
%              いずれか。
%  A.Handles : 選択したハンドル番号のリスト、または、Copyに対しては1列目
%              がオリジナルのハンドル番号で、2列目が新しいハンドル番号で
%              あるM行2列の行列。


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:08:47 $
%   Built-in function.
