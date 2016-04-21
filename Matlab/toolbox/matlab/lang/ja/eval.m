% EVAL   MATLAB表現をもつ文字列の実行
% 
% EVAL(s) は、s が文字列のとき、文字列を式またはステートメントとして実行
% します。
%
% EVAL(s1,s2) は、エラーを捕らえる機能を提供します。これは、文字列 s1 を
% 実行し、演算が成功すると結果を出力します。演算がエラーになると、結果を
% 出力する前に文字列 s2 が評価されます。これは、EVAL('try','catch') と
% 考えられます。失敗した 'try' によって出力されたエラー文字列は、LASTERR 
% によって取り出せます。
% 
% [X,Y,Z,...] = EVAL(s) は、文字列 s の中の表現から出力引数を戻します。
%
% EVAL の入力文字列は、鍵括弧内の部分的な文字列や変数を連結して作成
% されます。たとえば、
%
% 変数 M1からM12までの一連の行列を作成するためには、
%
%     for n = 1:12
%        eval(['M' num2str(n) ' = magic(n)'])
%     end
%
% つぎの例では、選択したM-ファイルスクリプトを実行します。行列Dの行に
% 設定される文字列は、すべて同じ長さでなければなりません。
% 
%       D = ['odedemo '
%            'quaddemo'
%            'fitdemo '];
%       n = input('Select a demo number: ');
%       eval(D(n,:))
%
% 参考：FEVAL, EVALIN, ASSIGNIN, EVALC, LASTERR.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:58:55 $
%   Built-in function.
