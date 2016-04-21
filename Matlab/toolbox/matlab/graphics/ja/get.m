% GET   オブジェクトのプロパティの取得
% 
% V = GET(H,'PropertyName') は、ハンドル番号 H をもつグラフィックスオブ
% ジェクトの指定したプロパティの値を出力します。H は、ハンドル番号から
% なるベクトルで、get は M が length(H) である、M行1列のセル配列を出力
% します。'PropertyName' が、プロパティ名を含む文字列からなる1行N列
% またはN行1列のセル配列で置き換えられる場合は、GET は、値を要素にもつ
% M行N列のセル配列を出力します。
%
% GET(H) は、ハンドル番号が H のグラフィックスオブジェクトのすべてのプロパ
% ティ名とカレントの値を表示します。
%
% V = GET(H) は、H がスカラのとき、各フィールド名が H のプロパティ名で、
% 各フィールドがプロパティの値を含む構造体を出力します。
%
%   V = GET(0、'Factory') 
%   V = GET(0、'Factory<ObjectType>')
%   V = GET(0、'Factory<ObjectType><PropertyName>') 
% 
% は、すべてのオブジェクトタイプに対して、ユーザ設定が可能なデフォルト値
% をもつ、すべてのプロパティの出荷時に定義されている値を出力します。
%
%   V = GET(H、'Default') 
%   V = GET(H、'Default<ObjectType>') 
%   V = GET(H、'Default<ObjectType><PropertyName>') 
% 
% は、デフォルトのプロパティ値についての情報を出力します(H は、スカラでな
% ければなりません)。 'Default' は、カレントで H に設定されているすべての
% デフォルトのプロパティ値のリストを出力します。'Default<ObjectType>' は、
% H に設定されている<ObjectType>のプロパティのデフォルトのみを出力します。
% 'Default<ObjectType><PropertyName>' は、H に設定されているデフォルトと
% デフォルトが見つかるまでその親を検索することにより、指定したプロパティ
% のデフォルト値を出力します。このプロパティに対するデフォルト値が、H 
% またはルート以下の H の親に設定されていない場合は、出荷時に定義されて
% いるプロパティの値を出力します。
% 
% デフォルトは、オブジェクトの子、またはオブジェクト自身から参照されま
% せん。たとえば、'DefaultAxesColor' の値は、axes または axes の子オブ
% ジェクトから参照されませんが、figureやルートでは参照されます。
%
% 'Factory' または 'Default' の GET を使用するとき、PropertyName が省略
% されていれば、出力値はフィールド名がプロパティ名で、対応する値がプロ
% パティ値である構造体の形式をとります。PropertyName が指定されれば、
% 行列または文字列の値が出力されます。
%   
%
% 参考：SET, RESET, DELETE, GCF, GCA, FIGURE, AXES.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:55:48 $
%   Built-in function.
