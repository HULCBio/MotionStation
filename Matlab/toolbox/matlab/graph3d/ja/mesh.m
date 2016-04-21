% MESH   3次元メッシュサーフェス
% 
% MESH(X,Y,Z,C) は、4つの行列引数で定義された色付けされたパラメトリック
% メッシュをプロットします。視点は、VIEW で指定されます。軸のラベルは、
% X、Y、Z の範囲や、AXIS のカレントの設定によって決定されます。カラーの
% スケーリングは、Cの範囲または CAXIS のカレントの設定によって決定され
% ます。スケーリングされたカラー値は、カレントの COLORMAP のインデックス
% として使用されます。
%
% MESH(X,Y,Z) は C = Z を使用するので、カラーはメッシュの高さに比例します。
%
% MESH(x,y,Z) と MESH(x,y,Z,C) は、最初の2つの引数を行列からベクトルへ
% 置き換え、[m,n] = size(Z) のとき、length(x) = n かつ length(y) = m で
% なければなりません。この場合、メッシュラインの頂点は、(x(j)、y(i)、Z(i,j))
% の3要素です。
% x は Z の列に対応し、y は行に対応することに注意してください。
% 
% MESH(Z) と MESH(Z,C) は、x = 1:n と y = 1:m を使います。この場合、高さ
% Z は一価関数で、幾何学的な長方形グリッドに対して定義されます。
%
% MESH(...,'PropertyName',PropertyValue,...) は、指定したサーフェス
% プロパティの値を設定します。複数のプロパティ値も1つのステートメント
% で設定できます。
%
% MESH(AX,...) は、GCA ではなく AX にプロットします。
%
% MESH SURFACEオブジェクトのハンドル番号を出力します。
%
% AXIS、CAXIS、COLORMAP、HOLD、SHADING、HIDDEN、VIEWは、メッシュの
% 表示に影響を与えるfigure、axes、surfaceのプロパティを設定します。
%
% 下位互換性
% MESH('v6',...) は、MATLAB 6.5 および 以前の MATLAB との互換性の
% ために、surface plot オブジェクトではなく、surface オブジェクト
% を作成します。
% 
% 参考：SURF, MESHC, MESHZ, WATERFALL.

%-------------------------------
% 詳細追加:
%
% MESH は、背景色に FaceColor プロパティを設定し、EdgeColor プロパティを
% 'flat' に設定します。
%
% NextPlot axis プロパティ が REPLACE (HOLD が off) の場合、MESH は、
% Position を除くすべての axis プロパティをデフォルト値にリセットし、
% すべての axis children (line, patch, surf, image, および、text 
% オブジェクト) を削除します。

% Copyright 1984-2004 The MathWorks, Inc. 
