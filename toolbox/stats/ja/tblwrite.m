% TBLWRITE   tabular形式への書き出し
%
% TBLWRITE(DATA, VARNAMES, CASENAMES, FILENAME,DELIMITER) は、最初の行に
% 変数名、最初の列にケース名、各変数名に続く列に DELIMITER で区切られた
% データの形をもつファイルを書き込みます。FILENAME は、希望するファイル
% までの完全なパスを示すものです。
% VARNAMES は、変数名を含む文字行列です。
% CASENAMES は、各観測名を含む文字行列です。
% DATA は、変数-ケースのペアに対して設定された値を含む数値行列です。
%
% DELIMITER には、つぎのいずれかを設定することができます。
%  ' ', '\t', ',', ';', '|' または、それに対応する文字列名、
% 'space', 'tab', 'comma', 'semi', 'bar'. 
% これらが与えられない場合、デフォルトは、列の間に複数のスペースで置き
% 換えます。


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:16:00 $
