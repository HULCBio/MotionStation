% LOOKFOR   M-ファイルのキーワード検索
% 
% LOOKFOR XYZは、MATLABPATH上に存在するすべてのM-ファイルの中で、Helpテ
% キストの最初のコメントライン(H1ライン)から文字列XYZを検索します。一致
% したすべてのファイルに対して、LOOKFORはH1ラインを表示します。
%
% たとえば、"lookfor inverse"は、"inverse hyperbolic cosine"、"two-dim-
% ensional inverse FFT"、"pseudoinverse"等からなるH1ラインを含むものが、
% 少なくとも1ダース見つけられます。これと、"which inverse"または"what 
% inverse"を比較してみてください。これらのコマンドは、より速く実行します
% が、通常、MATLABは関数"inverse"をもたないため、見つけられません。
%
% LOOKFOR XYZ -allは、各M-ファイルの最初のコメントブロックをすべて検索し
% ます。
%
% まとめると、WHATは、指定したディレクトリ内の関数をリストします。
% WHICHは、指定した関数またはファイルを含むディレクトリを検索します。
% LOOKFORは、指定されたキーワードに関連するすべてのディレクトリ内の
% すべての関数に対して検索します。
%
% 参考：DIR, HELP, WHO, WHAT, WHICH.



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/04/28 01:56:31 $
%   Built-in function.
