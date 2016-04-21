% FUNCTION   新しい関数の追加
% 
% 既存の関数を使って、新たな関数をMATLABに追加できます。新たな関数を
% 構成するコマンドと関数は、ファイル名の拡張子に 'm' をもち、新たな関数
% 名を定義するファイル名をもつファイルに設定されます。ファイルの最初の行
% は、新たな関数のシンタックスの定義を含みます。たとえば、STAT.M という
% 名前のディスク上のファイル
% 
%         function [mean,stdev] = stat(x)
%           %STAT Interesting statistics.
%         n = length(x);
%         mean = sum(x) / n;
%         stdev = sqrt(sum((x - mean).^2)/n);
% 
% は、ベクトルの平均と標準偏差を計算する STAT という新たな関数を定義し
% ます。関数本体内の変数は、すべてローカル変数です。ワークスペースでグ
% ローバルに機能するものに関しては、SCRIPT を参照してください。
%
% 同じファイル内の他の関数に対して有効なサブ関数は、先行する関数やサ
% ブ関数の本体の後に、キーワードFUNCTIONを使って新たな関数を定義す
% ることで作成されます。たとえば、avgはファイルSTAT.M内のサブ関数です。
%
%          function [mean,stdev] = stat(x)
%          %STAT Interesting statistics.
%          n = length(x);
%          mean = avg(x,n);
%          stdev = sqrt(sum((x-avg(x,n)).^2)/n);
%
%          %-------------------------
%          function mean = avg(x,n)
%          %AVG subfunction
%          mean = sum(x)/n;
%
% サブ関数は、それらが定義されているファイルの外部では有効ではありま
% せん。通常、ファイルの終端に到達したときにリターンが行われます。
% RETURN ステートメントを使って、途中で強制的にリターンすることができま
% す。
% 
% 参考：SCRIPT, RETURN, VARARGIN, VARARGOUT, NARGIN, NARGOUT, 
%       INPUTNAME, MFILENAME.

%   Copyright 1984-2002 The MathWorks, Inc. 

