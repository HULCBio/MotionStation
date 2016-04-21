% IDGREY は、IDGREY モデル構造を作成します。
%       
%   M = IDGREY(MfileName,ParameterVector,CDmfile)
%   M = IDGREY(MfileName,ParameterVector,CDmfile,...
%              FileArgument,Ts,'Property',Value,..)
%
%   M: ユーザ定義の線形モデル構造を記述する IDGREY モデルオブジェクトと
%      して出力
%
% MfileName は、構造を記述するm-ファイル名です。つぎのフォーマットになっ
% ています。
%
%     [A,B,C,D,K,X0] = MfileName(ParameterVector,Ts,FileArgument)
%
% ここで、出力は、イノベーション型で線形システムを記述します。
%
%      xn(t) = A x(t) + B u(t) + K e(t) ;      x(0) = X0
%       y(t) = C x(t) + D u(t) + e(t)
%
% 連続時間でも、離散時間でも適用できます。ここで、離散時間では、
% xn(t) = x(t+Ts)であり、連続時間では、xn(t) = d/dt x(t)です。
%    
% ParameterVectorは、モデル行列を決定するノミナルのパラメータの(列)ベク 
% トルです。 これらは、推定する自由パラメータに対応しています。
% 
% CDmfileは、ユーザの記述したm-ファイルで連続/離散時間モデルをどのように
% 取り扱うかを指定します。
% 
%      CDmfile = 'c'は、常に、連続時間モデル行列を出力するユーザm-ファイル
%                を意味し、Ts を無視します。
%                システムのサンプリングは、示されたデータインターサンプル
%                動作に従い、ツールボックスの内部的なアルゴリズムにより
%                行われます。(DATA.InterSample)
%      CDmfile = 'cd' は、引数 Ts = 0 の場合、連続時間状態空間モデル行列
%                で、Ts > 0 の場合、サンプリング間隔 Ts で得られる離散時
%                間モデル行列を出力するm-ファイルを意味します。
%                この場合、サンプリングルーチンのユーザの選択は、
%                ツールボックスの内部的なサンプリングのアルゴリズムを
%                上書きします。
%      CDmfile = 'd'は、mファイルが、Ts の値に依存する、または、全く依存しない
%                かのどちらかの状態での離散時間モデルの行列を常に出力すること
%                を示します。 
% FileArgumentは、ある適切な方法で使用されるm-ファイルへのエキストラの引 
% 数です(デフォルトは、[])。
%
% Ts は、モデルのサンプリング間隔です。
% デフォルト: CDmfile = 'd' の場合、Ts = 1 
%             CDmfile = 'c' または 'cd'の場合、Ts = 0  (連続時間モデル)
%
% IDGREY プロパティの詳細については、IDPROPS IDGREY で得られます。


%   Copyright 1986-2001 The MathWorks, Inc.
