% REPLACE_BLOCK   モデル内のブロックの置き換え
%
% REPLACE_BLOCK(System,BlockType,NewBlock) は、ブロックタイプが BlockTypeで
% ある System というモデル内のすべてのブロックをNewBlockで置き換えます。たと
% えば、つぎのコマンドは、f14というモデル内のすべての Gain ブロックを
% Integrator ブロックで置き換え、変更されたブロックのパスを変数
% ReplaceNames に格納します。
%
%  ReplaceNames  =  replace_block('f14','Gain','Integrator');
%
% REPLACE_BLOCK(System,BlockParameter,BlockParamValue,NewBlock) は、パラメー
% タ値が BlockParameter と BlockParamValue に一致する System というモデル内
% のすべてのブロックをNewBlockで置き換えます。任意数のパラメータ/値の組を設定
% することができます。たとえば、つぎのコマンドは、Clutch というモデル内の
% Unlocked というサブシステム内の Gain パラメータに対して値 'bv' をもつすべ
% てのブロックを、Integrator ブロックで置き換えます。
%
%  ReplaceNames  =  ... replace_block('clutch/Unlocked','Gain','bv','
% Integrator');
%
% これらのコマンドは、置き換えを行う前に、一致するブロックを選択するよう尋ね
% るダイアログボックスを表示します。このダイアログボックスを表示しないように
% するには、このコマンドの最後の引数として'noprompt'引数を追加してください。
% たとえば、つぎのコマンドは、Gain ブロックを Integratorブロックに変更します
% が、ダイアログボックスは表示せず、左辺引数に結果を出力しません。
%
%  replace_block('f14','Gain','Integrator','noprompt')
%
% このコマンドが行う変更を元に戻すのは困難な可能性があるので、注意して使って
% ください。まずモデルを保存することをお薦めします。
%
% 参考 : FIND_SYSTEM.


% Copyright 1990-2002 The MathWorks, Inc.
