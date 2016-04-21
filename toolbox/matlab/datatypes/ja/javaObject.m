% javaObject   Javaオブジェクトコンストラクタを起動します
%
% C がJavaクラスの名前を含む文字列の場合、
%
%   javaObject(C,x1,...,xn)
%
% は、引数 x1,...,xn と一致する名前をもつクラスCに対するJavaコンストラクタ
% を起動します。結果のJavaオブジェクトは、Javaオブジェクト配列として出力
% されます。
%
% たとえば、
%
%   X = javaObject('java.awt.Color', 0.1, 0, 0.7)
%
% は、java.awt.Color オブジェクト配列を作成し、出力します。
%
% 指定したクラス、名前と一致するコンストラクタが存在しない場合は、エラーが発
% 生します。
%
% javaObject は、通常必要なく、使われません。すなわち、Javaコンストラクタを起
% 動する通常の方法は、X = java.awt.Color(0, 0, 200) のようなMATLABコンストラ
% クタシンタックスを使ったものです。javaObject は、MATLABコンストラクタシン
% タックスが利用できない場合、たとえば、クラスパラメトリックオブジェクト作成
% が必要な場合等に利用されます。
%
% 参考 ： javaMethod, IMPORT, METHODS, FIELDNAMES, ISJAVA.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:47:38 $
