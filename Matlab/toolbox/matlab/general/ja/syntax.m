% つぎに記述するように、FUNCTION フォーマットまたは COMMAND フォーマット
% のいずれかを使って、MATLABコマンドを入力することができます。
%
%
% FUNCTION フォーマット
%
% このフォーマットでは、コマンドは関数名を最初に、つぎにカンマで区切られ
% るか、あるいは括弧で囲まれた引数から成り立っています。
%
%      functionname(arg1, arg2, ..., argn)
%
% 関数の出力は、1つまたは複数の出力値を設定することができ、複数の場
% 合は、鍵括弧で囲むか、あるいは値をカンマで区切ります。
%
%      [out1, out2, ..., outn] = functionname(arg1, arg2, ..., argn)
%
% たとえば、つぎのように使います。
%
%      copyfile(srcfile, '..\mytests', 'writable')
%      [x1, x2, x3, x4] = deal(A{:})
%
%
% 引数は、値として関数に渡されます。下記の ARGUMENT PASSING の例題を
% 参照してください。
%
%
% COMMAND フォーマット
%
% このフォーマットでは、コマンドは関数名を最初に、その後にスペースで区切ら
% れた1つあるいは複数の引数を配置します。
%
%      functionname arg1 arg2 ... argn
%
% Function フォーマットと異なり、関数の出力に変数を割り当てなくても構い
% ません。割り当てると、エラーを生じます。
%
% たとえば、
%
%      save mydata.mat x y z
%      import java.awt.Button java.lang.String
%
% 引数は、文字列として取り扱われます。下記の ARGUMENT PASSING の例題
% を参照してください。
%
%
% 引数を渡す
%
% FUNCTION フォーマットでは、引数は値で渡されます。
% COMMAND フォーマットでは、引数は文字列として取り扱われます。
%
%
% つぎの例題の中で、
%
%      disp(A) - 変数 A の値を関数 disp に渡します。
%      disp A  - 変数名 'A' を渡します。
%
%         A = pi;
%
%         disp(A)                    % Function フォーマット
%             3.1416
%
%         disp A                     % Command フォーマット
%             A
%
%
% つぎの例題で、
%
%      strcmp(str1, str2) - 文字列 'one' と 'one' を比較します。
%      strcmp str1 str2   - 文字列 'str1' と 'str2' を比較します。
%
%         str1 = 'one';    str2 = 'one';
%
%         strcmp(str1, str2)         % Function フォーマット
%         ans =
%              1        (equal)
%
%         strcmp str1 str2           % Command フォーマット
%         ans =
%              0        (unequal)
%
%
% 文字列を渡す
%
% FUCTION フォーマットを使って文字表現を関数に渡す場合、文字列をシング
% ルコート ('string') で囲む必要があります。
%
% たとえば、MYAPPTESTS と呼ばれる新しいディレクトリを作成するために、つ
% ぎのステートメントを使います。
%
%      mkdir('myapptests')
%
% 一方、文字列を含む変数は、シングルコートで囲む必要はありません。
%
%      dirname = 'myapptests';
%      mkdir(dirname)



%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $Date:
