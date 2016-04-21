% THSS2TH TH(SS) 形式を標準の多入力1出力 THETA フォーマットに変換
% TH2FF とTH2ZP のための補助ルーチン
%   
%         TH = thss2th(TH_SS, IY)
%
%   TH_SS : THETA(SS)フォーマットで定義されたモデル(thss 参照)
%   IY    : TH の出力として考えられる TH_SS の出力数(THETA フォーマット
%           は、1出力モデルにのみ対応します) デフォルト: IY = 1
%   TH    : 変換された共分散行列を含む THETA フォーマットのモデル
%           (THETA 参照)
%
% デフォルトで、対角雑音行列(H)が仮定されます。すべての雑音源に対してモ
% デルを求めるためには、TH = thss2th(TH_SS, IY, 'noises')と実行します。
% 雑音源は、付加的な入力として取り扱われ、カウントされます。
%
% 共分散行列の変換は、数値差分の Gauss 漸近公式を利用して実行されます。
% 差分のステップ幅は、Mファイル nuderst で定義されます。

%   Copyright 1986-2001 The MathWorks, Inc.
