% CONTROLSMAKE コンポーネントに対するuicontrolを作成
% 
%   C=CONTROLSMAKE(C,ALIST)
% 
% ここで、ALISTは属性のリストを含む1行N列のセル配列です。UIcontrolsは、
% .attxの設定に従って、これらの属性に対して作成され初期化されます。
%
% ALISTが指定されない場合は、全ての属性が作成されます。
%
% 属性のコントロールは、ハンドル名c.x.AttributeNameを使って作成されます。
% attx.Stringプロパティが空でない場合は、タイトル文字列はc.x.Attribute-
% NameTitleに作成されます。
%
% 2カラムレイアウトは、デフォルトでc.x.LayoutManagerに作成されます。
% 
% 参考   CONTROLSUPDATE, CONTROLSFRAME, CONTROLSRESIZE





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:20:43 $
%   Copyright 1997-2002 The MathWorks, Inc.
