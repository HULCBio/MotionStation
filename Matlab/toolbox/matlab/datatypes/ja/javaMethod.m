% javaMethod   Javaメソッドを起動
%
% javaMethod は、静的な、または静的でないJavaメソッドを起動するために用いら
% れます。
%
% MはJavaメソッドの名前を含む文字列で、C はJavaクラスの名前を含む文字列
% の場合は、
%
%   javaMethod(M,C,x1,...,xn)
%
% は、引数 x1,...,xn と一致する名前をもつクラス C のJavaメソッドMを起動
% します。たとえば、 
%   
%   javaMethod('isNaN', 'java.lang.Double', x)
%
% は、クラスjava.lang.Doubleの静的なJavaメソッドisNaNを起動します。
%
% J がJavaオブジェクト配列の場合、javaMethod(M,J,x1,...xn) は、引数 
% x1,...xn と一致する名前をもつJのクラスの非静的なJavaメソッドMを起動
% します。たとえば、F がjava.awt.Frame Java オブジェクト配列の場合、
%
%   javaMethod('setTitle', F, 'New Title')
%
% は、フレームに対してタイトルを設定します。javaMethod は、通常この型を必要
% とせず、また使うこともありません。Javaオブジェクト上でMATLABメソッドを起動
% する通常の方法は、setTitle(F, 'New Title')のようなMATLABメソッド呼び出しシ
% ンタックスや、F.setTitle('New Title')のようなJava呼び出しシンタックスに
% よるものです。javaMethod は、(完全なコントロールが必要とされるような)
% 通常の方法が利用できない場合に利用するものです。
%
% 参考 ： javaObject, IMPORT, METHODS, ISJAVA.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.4.4.1 $  $Date: 2004/04/28 01:47:37 $
