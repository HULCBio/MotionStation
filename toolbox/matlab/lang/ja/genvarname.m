%GENVARNAME 与えれらた候補から正しい MATLAB 変数名を構成します
% VARNAME = GENVARNAME(CANDIDATE) は、文字列 CANDIDATE から構成された
% 正しい変数名 VARNAMEを出力します。CANDIDATE は、文字列または文字列の
% セル配列になることができます。
%
% 正しい MATLAB 変数名は、最初のキャラクタが文字で、文字列の長さが
% <= NAMELENGTHMAX であるような、文字、数字、アンダースコアの
% 文字列です。
%
% CANDIDATE が文字列のセル配列である場合、VARNAME に出力される結果の
% 文字列のセル配列は、互いに一意的であることが保証されます。 
%
% VARNAME = GENVARNAME(CANDIDATE, PROTECTED) は、PROTECTED の名前リスト
% から一意的である正しい変数名を返します。PROTECTED は、文字列または
% 文字列のセル配列になります。
%
% 例題:
%     genvarname({'file','file'})     % {'file','file1'} を出力
%     a.(genvarname(' field#')) = 1   %  a.field0x23 = 1 を出力
%
%     okName = true;
%     genvarname('ok name',who)       % 文字列 'okName1' を出力
%
% 参考 ISVARNAME, ISKEYWORD, ISLETTER, NAMELENGTHMAX, WHO, REGEXP.

%   Copyright 1984-2003 The MathWorks, Inc.
