% SGMLTAG - SGML要素を文法的に解釈した表現
% SGMLTAGオブジェクトは、以下のフィールドをもちます。
%   T.tag  - タグのテキスト  <tag>
%   T.data - タグの内容。数値、文字列、その他のSGMLTAGオブジェクト、セル
%            配列を使うことができます。
%   T.att  - N行2列のセル配列。列1は属性名で、列2は属性値です。
%   
% T.optは、オプションベクトルです。
%       opt(1) = IndentContents.  真の場合は、subtagsとcdataをインデント
%                します。
%       opt(2) = EndTag.  真の場合は、endtagを挿入します。
%       opt(3) = Expanded.  真の場合は、タグとデータを、別の行に置きます。
%       opt(4) = SGML.  内容はSGMLです。 <,& をエスケープキャラクタで置
%                き換えないでください。
%
% SGMLTAGオブジェクト:
% 
%     T.tag='foo';
%     T.data='bar';
%     T.att={'att1',0;'att2',a};
%     T.opt=[1 1 1 0];
%
%   SGMLテキスト:
% 
%       <foo att1=0 att2="a">
%          bar
%       </foo>
%
% 参考: SGMLTAG/CHAR, SGMLTAG/SET, SGMLTAG/SHOW





% $Revision: 1.1.6.1 $ $Date: 2004/03/21 22:23:39 $
%   Copyright 1997-2002 The MathWorks, Inc.
