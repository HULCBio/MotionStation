% IDARX/ARX は、(多変数)ARX モデルの推定を行います。
%    
%   M = ARX(Z,Mi)
%
%   Z: IDDATA オブジェクトと同様な出力-入力データ。詳細は、HELP IDDATA を
%      参照
%   Mi: 次数を定義する IDARX オブジェクト。詳細は、help IDARX を参照
%
% アルゴリズムに関連したいくつかのパラメータは、つぎのようにしてアクセス
% されます。
% 
%   MODEL = ARX(DATA,Mi'MaxSize',MAXSIZE)
% 
% ここで、MAXSIZE は、メモリとスピードのトレードオフです。マニュアルを参
% 照してください。
%
% ARX は、E'*inv(LAMBDA)*E のノルムを最小化します。ここで、E は予測誤差で
% LAMBDA は Mi.NoiseVariance です。
%
% プロパティ名と値が組として使用される場合、任意の順番に設定できます。省
% 略したものは、デフォルト値が使われます。
% MODEL プロパティ 'FOCUS' と 'INPUTDELAY' は、
% 
%   M = ARX(DATA,Mi,'Focus','Simulation','InputDelay',[3 2]);
% 
% の中と同じようにプロパティ名と値を一組として設定します。IDPROPS ALGOR-
% ITHM と IDPROPS IDMODEL を参照してください。

%   L. Ljung 10-2-90


%   Copyright 1986-2001 The MathWorks, Inc.
