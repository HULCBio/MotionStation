% SURF   3次元カラーサーフェス
% 
% SURF(X,Y,Z,C) は、4つの行列引数で定義された色付けされたパラメトリック
% サーフェスをプロットします。視点は、VIEW で指定されます。軸のラベルは、
% X、Y、Z の範囲や、AXIS のカレントの設定によって決定されます。カラーの
% スケーリングは、C の範囲または CAXIS のカレントの設定によって決定され
% ます。スケーリングされたカラー値は、カレントの COLORMAP のインデックス
% として使用されます。シェーディングモデルは、SHADING により設定されます。
%
% SURF(X,Y,Z)は C = Z を使用するので、カラーはサーフェスの高さに比例
% します。
%
% 最初の2つの引数が行列からベクトルに置き換えられた SURF(x,y,Z) と
% SURF(x,y,Z,C) は、[m,n] = size(Z) のとき、length(x) = n かつ 
% length(y) = m でなければなりません。この場合、サーフェスのパッチの
% 頂点は、(x(j)、y(i)、Z(i,j)) の3要素です。x は Z の列に対応し、y は
% 行に対応することに注意してください。
% 
% SURF(Z) と SURF(Z,C) は、x = 1:n と y = 1:m を使います。この場合、
% 高さ Z は一価関数で、幾何学的な長方形グリッドで定義されます。
%
% SURF(...,'PropertyName',PropertyValue,...) は、指定したサーフェスプロパ
% ティの値を設定します。複数のプロパティ値を1つのステートメントで設定でき
% ます。
%
% SURF(AX,...) は、GCA ではなく AX にプロットします。
%
% SURF は、SURFACEオブジェクトのハンドル番号を出力します。
%
% AXIS、CAXIS、COLORMAP、HOLD、SHADING、VIEW は、サーフェスの表示に
% 影響を与える　figure、axes、surfaceのプロパティを設定します。
%
% 下位互換性
% SURF('v6',...) は、MATLAB 6.5 および 以前の MATLAB との互換性の
% ために、surface plot オブジェクトではなく、surface オブジェクト
% を作成します。
%
% 参考：SURFC, SURFL, MESH, SHADING.

%-------------------------------
% 詳細追加:
%
% NextPlot axis プロパティ が REPLACE (HOLD が off) の場合、SURF は、
% Position を除くすべての axis プロパティをデフォルト値にリセットし、
% すべての axis children (line, patch, surf, image, および、text 
% オブジェクト) を削除します。

% Copyright 1984-2002 The MathWorks, Inc. 
