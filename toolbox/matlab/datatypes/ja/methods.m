% METHODS  クラスのメソッド名の表示
%
% METHODS CLASSNAME は、名前CLASSNAMEをもつクラスに対するメソッド名
% を表示します。
%
% METHODS(OBJECT) は、クラスOBJECTに対するメソッド名を表示します。
%
% M = METHODS('CLASSNAME') は、文字列のセル配列にメソッドを出力します。
%
% METHODS は、WHATと異なり、すべてのメソッドディレクトリからのメソッドもレ
% ポートします。そして、METHODS は重複するものを除去して、結果の一覧を作
% 成します。METHODS は、Javaクラスに対するメソッドも出力します。
%
% METHODS CLASSNAME -full  は、クラス内のメソッドの完全な記述を表示しま
% す。この中には継承された情報も含みます。また、Javaメソッドに対しては、
% 属性やシグネチャも含みます。異なるシグネチャをもつ重複するメソッド名は、
% 削除されます。class_name が MATLAB クラスを表現している場合、その
% クラスが実証された場合のみ、継承情報が返されます。
%
% M = METHODS('CLASSNAME', '-full') は、完全なメソッドの記述を文字列のセル
% 配列に出力します。
%   
% 参考 ： METHODSVIEW, WHAT, WHICH, HELP.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 01:47:42 $
%   Built-in functions.
