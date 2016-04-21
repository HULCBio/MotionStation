% javaArray   Java Arrayオブジェクトの作成
%
% JA = javaArray(CLASSNAME,DIM1,...) は、Java配列オブジェクト
% (Javaの次元をもつオブジェクト)を出力します。このオブジェクトの
% コンポーネントクラスは、キャラクタ文字列CLASSNAMEで指定される
% Javaクラスです。
%
% 例題
%     % 10要素のjava.awt.Frame Java配列を作成
%     ja = javaArray('java.awt.Frame',10);
%     % 5x10x2 java.lang.Double Java配列を作成
%     ja = javaArray('java.lang.Double',5,10,2);


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:47:36 $
