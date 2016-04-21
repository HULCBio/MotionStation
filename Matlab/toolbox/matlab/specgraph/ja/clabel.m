% CLABEL   コンタープロットの標高ラベル
% 
% CLABEL(CS,H) は、カレントのコンタープロットに標高ラベルを付けます。
% ラベルは、回転されてコンターラインに挿入されます。CS と H は、コンター
% 行列の出力と CONTOUR、CONTOUR3、CONTOURF から出力されるオブジェクトの
% ハンドル番号です。
%
% CLABEL(CS,H,V) は、ベクトル V で与えられるコンターレベルにラベルを付け
% ます。デフォルトでは、すべての既知のコンターにラベルを付けます。ラベルの
% 位置は、ランダムに選択されます。
%
% CLABEL(CS,H,'manual') は、マウスをクリックした位置にコンターラベルを
% 付けます。リターンキーを押すと、ラベル付けを終了します。マウスを使用
% できないときは、コンターの入力にはスペースバーを、クロスヘアの移動には
% 矢印キーを使ってください。
%
% CLABEL(CS) または CLABEL(CS,V) または CLABEL(CS,'manual') は、上記の
% ようにコンターラベルを付けますが、ラベルはコンター上に、近傍の標高と
% 共にプラス記号として表示されます。
%
% H = CLABEL(...) は、作成されたTEXTオブジェクト(LINEの場合もあり)のハン
% ドル番号を出力します。TEXTオブジェクトのUserDataプロパティは、各ラベル
% の標高値を含みます。
%
% CLABEL(...,'text property',property-value,...) は、ラベルの文字列の設定
% に、任意のTEXTプロパティ/値の組み合わせを使います。
% 
% 1つの特別なプロパティ('LabelSpacing')は、ラベル間(点数で表わす)の間隔
% を設定するのに使います。デフォルトは144点または2インチのどちらかです。
%
% R. Pawlowicz の作成したコードを使って、インラインコンターラベルを取り
% 扱います。
% 
% 例題：
%  　　subplot(1,3,1), [cs,h] = contour(peaks); 
% 　　 clabel(cs,h,'labelspacing',72)
%      subplot(1,3,2), cs = contour(peaks); clabel(cs)
%      subplot(1,3,3), [cs,h] = contour(peaks); 
%      clabel(cs,h,'fontsize',15,'color','r','rotation',0)
%
% 参考：CONTOUR, CONTOUR3, CONTOURF.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 02:04:39 $
