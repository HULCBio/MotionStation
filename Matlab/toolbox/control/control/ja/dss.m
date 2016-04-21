% DSS   ディスクリプタ状態空間(DSS)モデルを作成
%
%           .
%         E x = A x + B u            E x[n+1] = A x[n] + B u[n]
%                            または 
%           y = C x + D u                y[n] = C x[n] + D u[n]  
%
% SYS = DSS(A,B,C,D,E) は、連続時間の DSS モデル SYS を行列 A, B, C, D, E
% から作成します。出力の SYS はSSオブジェクトです。
% D = 0 の場合、適切な次元のゼロ行列を設定することができます。
%
% SYS = DSS(A,B,C,D,E,Ts) は、サンプル時間 Ts (サンプル時間を未定義にしたい
% 場合は、Ts = -1 に設定してください)をもつ離散時間 DSS モデルを作成します。
%
% 両方の書式で、入力リストは、つぎのように組にして続けることができます。 
%   'PropertyName1', PropertyValue1, ... 
% これにより、SS モデルの様々なプロパティを設定します(詳細は、LTIPROPSを
% 参照してください)。
% 既存のモデル REFSYS から、LTI プロパティすべてを継承した SYS を作成するた
% めには、つぎの書式を利用してください。 
%   SYS = DSS(A,B,C,D,E,REFSYS)
%
% A, B, C, D, E に対して ND 配列を利用することで、DSS モデルの配列を作成でき
% ます。詳細は、SS に関するヘルプを参照してください。
%
% 参考 : SS, DSSDATA.


% Copyright 1986-2002 The MathWorks, Inc.
