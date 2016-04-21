% QUESTDLG   質問ダイアログボックス
% 
% ButtonName = QUESTDLG(Question) は、セル配列または文字列(ベクトルまたは
% 行列)Questionを、適切なサイズのウインドウに合うように、自動的に改行
% したダイアログボックスを作成します。クリックされるボタン名は、
% ButtonName に出力されます。figureのタイトルは、2つ目の文字列引数を
% 付け加えて指定できます。質問は通常の文字列として解釈されます。  
%
% QUESTDLG は、UIWAIT を使って、ユーザが反応するまで実行を停止することが
% できます。
% 
% QUESTDLG に対するデフォルトのボタン名は、'Yes','No' 'Cancel' です。
% 上記の呼び出しシンタックスに対するデフォルトの答えは、'Yes' です。
% これは、デフォルトのButtonを指定する3つ目の引数を付け加えて、変更
% できます。たとえば、ButtonName = questdlg(Question,Title,'No') のように
% します。
%
% 関数コールへの追加の引数として、ボタン文字列の名前(単数または複数)を
% 入力することで、最大3個のカスタムボタン名を指定できます。カスタムの
% ButtonName が入力されると、デフォルトの ButtonName は、追加の引数
% DEFAULT を付け加えて指定しなければなりません。たとえば、 
%
% ButtonName = questdlg(Question,Title,Btn1,Btn2,DEFAULT);
%
% で、ここで、DEFAULT = Btn1 です。これは、デフォルトの答えとして Btn1
% を出力します。DEFAULT 文字列が、ボタンの文字列名に一致しない場合、
% ワーニングメッセージが表示されます。
%
% 文字列 Question にTeXの解釈を使うには、データ構造体をつぎのように
% 最後の引数で指定しなければなりません。
%
%     ButtonName = questdlg(Question,Title,Btn1,Btn2,OPTIONS);
% 
% OPTIONS構造体は、Default と Interpreter のメンバーを必要とします。
% Interpreterは、'none' または 'tex' で、Default は用いられるデフォルト
% のボタン名です。
%
% ダイアログが、有効な選択をせずに閉じられた場合、結果の値は空になります。
%
% 例題:
% 
%  ButtonName=questdlg('What is your wish?', ...
%                      'Genie Question', ...
%                      'Food','Clothing','Money','Money');
%
%  
%  switch ButtonName,
%    case 'Food', 
%     disp('Food is delivered');
%    case 'Clothing',
%     disp('The Emperor''s  new clothes have arrived.')
%     case 'Money',
%      disp('A ton of money falls out the sky.');
%  end % switch
%
% 参考： TEXTWRAP, INPUTDLG.


%  Author: L. Dean
%  Copyright 1984-2002 The MathWorks, Inc.
