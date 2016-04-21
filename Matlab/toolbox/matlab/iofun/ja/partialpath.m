% PARTIALPATH   部分パス名
% 
% 部分パス名は、privateファイルやメソッドファイルの位置を示すために使わ
% れるMATLABPATH相対パス名で、通常隠されているか、与えられた名称の
% ファイルが2つ以上存在するときのファイル検索に限られています。
%
% 部分パス名は、/によって分けられている絶対パス名の最後の部分、または、
% 最後の数個の部分です。たとえば、"matfun/trace"、"private/children"、
% "inline/formula"、"demos/clown.mat"は、有効な部分パス名です。メソッド
% のディレクトリ内で"@"を指定するのはオプションなので、"funfun/inline
% /formula"も有効な部分パス名です。
%
% 多くのコマンドで、絶対パス名の代わりに部分パス名を使うことができます。
% つぎに示すのは、そのようなコマンドのリスト(一部)です。
% 
%      HELP、TYPE、LOAD、EXIST、WHAT、WHICH、EDIT、
%      DBTYPE、DBSTOP、DBCLEAR、FOPEN
%
% 部分パス名によって、MATLABがインストールされている場所と関係なく、ユー
% ザのパス上のtoolboxやMATLABのファイルを探すことが簡単になります。


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:21 $
