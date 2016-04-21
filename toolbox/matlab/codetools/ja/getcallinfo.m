%GETCALLINFO  コールされた関数とその最初のコーリングラインを出力します
% STRUCT = GETCALLINFO(FILENAME,OPTION)
% 出力構造体 STRUCT は、つぎの形式をとります。
%      type:       [ script | function | subfunction ]
%      name:       スクリプト名、関数名、または、サブ関数名
%      firstline:  スクリプト、関数、または、サブ関数の最初の行
%      calls:      スクリプト、関数、または、サブ関数によるコール
%      calllines:  上記のコールが行われるライン
%
% OPTION = [ 'file' | 'subfuns' | 'funlist' ]
% デフォルトでは、OPTION は、'subfuns' に設定されます。
%   
% OPTION = 'file' は、スクリプト、サブ関数のない関数、または、サブ関数の
% ある関数であるかどうかに関わらず、ファイル全体の1つの構造体を出力します。 
% サブ関数のあるファイルに対して、ファイルに対するコールは、サブ関数による
% すべての外部呼び出しを含みます。 
%
% OPTION = 'subfuns' は、構造体の配列を出力します。最初のものはメイン関数に
% 対するもので、サブ関数すべてが続きます。このオプションは、スクリプトと 
% 1つの関数のファイルに対する'file' として同じ結果を出力します。
%
% OPTION = 'funlist' は、 'subfuns' オプションに似た構造体の配列を出力しますが、% calls と calllines の情報は出力されず、サブ関数とその最初のラインのリスト
% のみ出力されます。

%   Copyright 1984-2003, The MathWorks, Inc.
