% IV   補助変数法を使って、単出力 ARX モデルを計算
%
%   MODEL = IV(Z,NN,NF,MF)
%
%   MODEL : つぎの ARX モデル
%   
%              A(q) y(t) = B(q) u(t-nk) + v(t)
%   
%           の関連する構造情報を含む IV 推定結果の出力。MODEL の詳細な構
%           造は、HELP IDPOLY を参照。
%
%   Z     : 単出力 IDDATA オブジェクトとして表した出力 - 入力データ。詳
%           細は、HELP IDDATA を参照。
%
%   NN    : NN = [na nb nk] は、上のモデルに関連した次数と遅れを設定
%   NF と MF は、つぎの形式の補助変数 X を設定します。
%   
%          NF(q) x(t) = MF(q) u(t)
%
% 補助変数の自動的な選択については、IV4 を参照してください。
%
%   MODEL = IV(Z,NN,NF,MF,maxsize)
%
% は、アルゴリズムに関連したいくつかのパラメータにアクセスすることができ
% ます。
% これらの説明の詳細は、IDPROPS ALGORITHM を参照してください。

%   Copyright 1986-2001 The MathWorks, Inc.
