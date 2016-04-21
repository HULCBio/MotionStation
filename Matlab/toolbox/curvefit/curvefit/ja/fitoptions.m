% FITOPTIONS  Fit options オブジェクトの作成/修正
% F = FITOPTIONS(LIBNAME) は、ライブラリモデル LIBNAME に対して、デフォ
% ルト値をオプションパラメータとして使って、fitoptions オブジェクト F 
% を作成します。LIBNAME の詳細情報は、CFLIBHELP を参照してください。
%
% F = FITOPTIONS(LIBNAME,'PARAM1',VALUE1,'PARAM2',VALUE2,...) は、ライブ
% ラリモデル LIBNAME に対して、指定したパラメータに指定した値を使って、デ
% フォルトの fitoptions オブジェクトを作成します。
%
% F = FITOPTIONS('METHOD',VALUE) は、VALUE で指定した方法を使って、デフォ
% ルトの fitoptions オブジェクトを作成します。VALUE で選択可能な値は、つ
% ぎのものです。
%
%      NearestInterpolant     - 最近傍内挿
%      LinearInterpolant      - 線形内挿
%      PchipInterpolant       - 区分的キュービックエルミート内挿
%      CubicSplineInterpolant - キュービックスプライン内挿
%      SmoothingSpline        - 平滑化スプライン 
%      LinearLeastSquares     - 線形最小二乗
%      NonlinearLeastSquares  - 非線形最小二乗
%
% VALUE への入力は、すべての文字を入力する必要はなく、ユニークに識別でき
% る文字数で十分です。また、大文字、小文字の区別はありません。
%
% F = FITOPTIONS('METHOD',VALUE1,'PARAM2',VALUE2,...) は、デフォルトの 
% fitoptions オブジェクトに対して、設定したパラメータ名に対して、VAL-
% UE... で設定した値で書き換えます。
%
% F = FITOPTIONS(OLDF,NEWF) は、既存の fitoptions オブジェクト OLDF と新
% しい fitoptions オブジェクト NEWF を組み合わせます。OLDF と NEWF が、
% 同じ'Method' の場合、空でない値をもつ NEWF の中のいくつかのパラメータ
% は、OLDF の中の対応する古いパラメータを書き換えます。OLDF と NEWF が異
% なる'Method' をもつ場合、F は、OLDF と同じ Method をもち、NEWF の 'Nor-
% malize', 'Exclude', 'Weights' フィールドが、OLDF のものに代わり、使わ
% れます。
%
% F = FITOPTIONS(OLDF,'PARAM1',VALUE1,'PARAM2',VALUE2,...) は、fitoptions
% オブジェクト OLDF に対して、指定したパラメータと値で書き換えたもので、新
% しい fitoptions オブジェクトを作成します。
%
% F = FITOPTIONS は、すべてのフィールドがデフォルト値に設定され、Method 
% パラメータが、'None' である fitoptions オブジェクト F を作成します。
%
% すべての FITOPTIONS オブジェクトは、つぎのパラメータをもっています。
%
%    Normalize - データの中心を移動したり、スケーリングするか否かを設定
%                 [{'off'} | 'on']
%    Exclude   - データを削除したベクトルをオリジナルデータと同じ長さの
%                ベクトルにする
%                [{[]} | 削除した要素部を1に設定した論理ベクトル]
%    Weights   - データと同じ長さの重みベクトル
%                [{[]} | 正の要素をもつベクトル] 
%    Method    - FIT で使用する Method
%
% Method 値に依存して、fitoptions オブジェクトは、他のパラメータをもつこ
% ともできます。
%
% Method が、NearestInterpolant, LinearInterpolant, PchipInterpolant, Cu-
% bicSplineInterpolant のいずれかの場合、付加的なパラメータはありません。
%
% Method が、SmoothingSpline の場合、つぎの付加的なパラメータが存在します。
%      SmoothingParam - 平滑化パラメータ [{NaN} | [0,1] の間の値]
%                       NaN は、FIT の間、計算されることを意味します。
%
% Method が、LinearLeastSquares の場合、つぎの付加的なパラメータが存在し
% ます。
%
%      Robust    - ロバスト手法を使用するか否か [{'off'} | 'on']
%      Lower     - 近似する係数に適用する下限用のベクトル
%                  [{[]} | 係数の数を長さとするベクトル]
%      Upper     - 近似する係数に適用する魚右舷用のベクトル
%                  [{[]} | 係数の数を長さとするベクトル]
%
% Method が、NonlinearLeastSquares の場合、つぎの付加的なパラメータが存
% 在します。
%
%      Robust    - ロバスト手法を使用するか否か [{'off'} | 'on']
%      Lower     - 近似する係数に適用する下限用のベクトル
%                  [{[]} | 係数の数を長さとするベクトル]
%      Upper     - 近似する係数に適用する魚右舷用のベクトル
%                  [{[]} | 係数の数を長さとするベクトル]
%     StartPoint    - FIT 中で、スタート点を要素とするベクトル
%                     [{[]} | 係数の数を長さとするベクトル]
%     Algorithm     - FIT に使用するアルゴリズム
%                     [{'Levenberg-Marquardt'} | 'Gauss-Newton' | 
%                      'Trust-Region']
%     DiffMaxChange - 有限差分で、係数に適用可能な最大変化量
%                     勾配 [正のスカラ | {1e-1}]
%     DiffMinChange - 有限差分で、係数に適用可能な最小変化量
%                     勾配 [正のスカラ | {1e-8}]
%     Display       - 表示レベル ['off' | 'iter' | {'notify'} | 'final']
%     MaxFunEvals   - 関数(モデル)の計算の許容最大回数
%                     [正の整数]
%     MaxIter       - 繰り返し計算の許容最大回数[正の整数]
%     TolFun        - 関数(モデル)値に関する終了に関するトレランス
%                     [正のスカラ | {1e-6}]
%     TolX          - 係数に関する終了トレランス
%                     [正のスカラ | {1e-6}]
%
% すべての文字を入力する必要はなく、ユニークに識別できる文字数で十分です。
% また、大文字、小文字の区別はありません。
%
% 参考 FITTYPE, CFLIBHELP

% $Revision: 1.2.4.2 $
%   Copyright 2001-2004 The MathWorks, Inc.
