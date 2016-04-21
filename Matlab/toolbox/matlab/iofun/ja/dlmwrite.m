%DLMWRITE ASCII デリミタ付きファイルに書き出します
%
% DLMWRITE('FILENAME',M) は、',' を行列の要素を分けるデリミタとして使って、
% 行列 M を FILENAME に書き出します。
%
% DLMWRITE('FILENAME',M,'DLM') は、キャラクタ DLM をデリミタとして使って、
% 行列 M を FILENAME に書き出します。
%
% DLMWRITE('FILENAME',M,'DLM',R,C) は、行列 M をファイル内でのオフセット
% 行 R と オフセット列 C から書き出します。R と C はゼロを基準としている
% ので、R=C=0 は、ファイル内の最初の数値を指定します。
%
% DLMWRITE('FILENAME',M,'ATTRIBUTE1','VALUE1','ATTRIBUTE2','VALUE2'...)
% DLMWRITE のオプションの引数を指定するために属性値の組を使用する、
% 別の呼び出し構文です。各属性タグに適切な値が続けば、属性と値の組
% の順序は問題になりません。
%
%	DLMWRITE('FILENAME',M,'-append') は、ファイルに行列を追加します。
%	このフラグがない場合、DLMWRITE は、既存のファイルへ上書きします。
%
%	DLMWRITE('FILENAME',M,'-append','ATTRIBUTE1','VALUE1',...)  
%	前の構文と同様ですが、 '-append' フラグと同様に属性値の組も
%       受け取ります。このフラグは、引数リストの属性値の組の間のどこにでも
%　　　 置くことができますが、ある属性とその値の間に置くことはできません。
%
% ユーザが設定できるオプション
%
%   ATTRIBUTE : Attribute タグを定義する引用符で囲まれた文字列。 
%               つぎの attribute タグ使用できます。
%       'delimiter' =>  行列要素を分けるために使用するデリミタ文字列
%       'newline'   =>  'pc' ラインターミネーターとして CR/LF を使用します。
%                       'unix' ラインターミネーターとして LF を使用します。
%       'roffset'   =>  目的ファイルの上からデータを書き込む場所までの、
%                       行についてのゼロを基準にしたオフセット。
%       'coffset'   =>  目的ファイルの左からデータを書き込む場所までの、
%                       列についてのゼロを基準にしたオフセット。
%       'precision' =>  ファイルにデータを書き込むために使用する数値精度。
%                       有効数字としての精度、または、'%10.5f' のように、
%                       '%' ではじまる、C-スタイルの書式の文字列。
%                       これは、数を丸めるためにオペレーティングシステムの
%                       標準ライブラリを使用することに注意してください。
%
% 例題:
%
%   DLMWRITE('abc.dat',M,'delimiter',';','roffset',5,'coffset',6,...
%   'precision',4)  は、行列要素間のデリミタとして、; を使用して
%　 ファイル abc.dat の列オフセット 5, 列オフセット 6 に行列 M を
%　 書きます。データの数値の精度は、4 桁の10進数に設定されます。
%
%   DLMWRITE('example.dat',M,'-append') は、行列 M をファイル example.dat
%   の最後に追加します。デフォルトでは、append モードは off, すなわち、
%   DLMWRITE は既存のファイルに上書きします。
%
%   DLMWRITE('data.dat',M,'delimiter','\t','precision',6) は、有効桁数 6
%   の精度を使用して、タブキャラクタで区切られた要素をもつ M をファイル
%   'data.dat' に書き出します。
%   
%   DLMWRITE('file.txt',M,'delimiter','\t','precision','%.6f') は、小数点
%   以下の6 桁の精度を使用して、タブキャラクタで区切られた要素をもつ M
%   をファイル file.txt に書き出します。
%
%   DLMWRITE('example2.dat',M,'newline','pc') は、PC プラットフォームの
%   通常のラインターミネーターを使用して、ファイル example2.dat に M を書き出し
%   ます。
%
% 参考 DLMREAD, CSVWRITE, CSVREAD, WK1WRITE, WK1READ, NUM2STR, 
%   　 TEXTREAD, TEXTSCAN, STRREAD, IMPORTDATA, SSCANF, SPRINTF.

%   Brian M. Bourgault 10/22/93
%   Modified: JP Barnard, 26 September 2002.
%             Michael Theriault, 6 November 2003 
%   Copyright 1984-2002 The MathWorks, Inc. 
