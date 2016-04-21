% STATSET   STATS オプション構造体の作成/修正
%
% OPTIONS = STATSET('PARAM1',VALUE1,'PARAM2',VALUE2,...) は、指定された
% パラメータが指定された値をもつ統計量のオプション構造体 OPTIONS を作成
% します。指定されていないパラメータはいずれも [] が設定されます。統計
% 関数に OPTIONS を渡す場合に、パラメータ値として [] を設定すると、その
% パラメータのデフォルト値を利用することを意味します。パラメータ名を省略
% して、ユニークに区別できる文字列として指定することも可能です。
% 注意: 文字列の値のパラメータに対して、値に対して完全な文字列が必要です。
% 無効な文字列が与えられた場合、デフォルトが使われます。
%   
% OPTIONS = STATSET(OLDOPTS,'PARAM1',VALUE1,...) は、指定された値で修正
% された指定されたパラメータをもつ OLDOPTS のコピーを作成します。
%   
% OPTIONS = STATSET(OLDOPTS,NEWOPTS) は、新しいオプション構造体 NEWOPTS 
% を既存のオプション構造体 OLDOPTS に結合します。空でない値をもつ NEWOPTS 
% 内の任意のパラメータは、OLDOPTS 内の対応する古いパラメータに上書き
% されます。
%   
% 入力引数と出力引数をもたない STATSET は、デフォルトがオプションで使用
% するすべての関数に対して同じであるとき、{} 内で示されるデフォルトと
% 共にパラメータ名とそれらの可能な値をすべて表示します。
% 特定の関数に対する関数の仕様の詳細を見るには、(下で示すように) 
% STATSET(STATSFUNCTION) を使用してください。
%
% OPTIONS = STATSET (入力引数をもたない) は、すべてのフィールドに [] が
% 設定されたオプション構造体 OPTIONS を作成します。
%
% OPTIONS = STATSET(STATSFUNCTION) は、STATSFUNCTION 内で指定された
% 最適化関数に関連するすべてのパラメータ名とデフォルト値をもつオプション
% 構造体を作成します。STATSET は、OPTIONS 内のパラメータに、STATSFUNCTION 
% に対して有効でないパラメータに [] を設定します。
% たとえば、statset('factoran') または statset(@factoran) は、関数 
% 'factoran' に関連するすべてのパラメータ名とデフォルト値を含むオプション
% 構造体を出力します。
%   
% STATSET パラメータ:
%      Display     - 表示のレベル [ off | notify | final ]  
%      MaxFunEvals - 関数評価の最大許容回数 [ 正の整数 ]
%      MaxIter     - 繰り返しの最大許容回数 [ 正の整数 ]
%      TolBnd      - パラメータの境界の収束誤差許容値 [ 正のスカラ ]
%      TolFun      - 目的関数値に対する収束誤差許容値 [ 正のスカラ ]
%      TolX        - 推定に対する収束誤差許容値 [ 正のスカラ ]
%
% 参考 : STATGET.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/02/12 21:37:44 $
