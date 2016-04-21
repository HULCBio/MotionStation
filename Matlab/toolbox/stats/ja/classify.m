% CLASSIFY   判別分析
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP) は、SAMPLE のデータの各行を
% TRAINING のグループの値に割り当てます。SAMPLE とTRAINING は、同数の列を
% もつ行列である必要があります。GROUPは、TRAINING に対するグループ化変数
% です。その値は、グループを定義し、各要素は、どのグループがTRAINING の
% 行に属しているかを決定します。GROUP は、数値ベクトル、文字列配列、
% 文字列のセル配列のいずれかで設定できます。TRAINING とGROUP は、同数の
% 行です。CLASSIFY は、GROUPのNaNs、あるいは、空の文字列を欠測値として
% 取り扱い、TRAININGの対応する行を無視します。CLASSは、SAMPLE の各行が、
% どのグループに割り当てられるかを示し、GROUP と同じタイプをもちます。
%
% [CLASS,ERR] = CLASSIFY(SAMPLE,TRAINING,GROUP) は、誤判別するエラーの
% 割合の推定も出力します。CLASSIFY は、見かけのエラーの割合、 即ち、
% 誤判別された TRAINING の観測値の百分率を出力します。
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE) では、判別関数のタイプを、
% 'linear', 'quadratic' あるいは、'mahalanobis'のいずれかに指定することが
% できます。線形判別は、共分散の代表的な推定を用いて、各グループに多変量
% 正規分布密度をフィッティングします。2次判別は、グループ毎に階層化された
% 共分散推定を用いて、MVN 密度をフィッティングします。Mahalanobis判別は、
% 階層化された共分散の推定を用いて、Mahalanobis距離を使用します。TYPE は、
% デフォルトでは、'linear'です。
%
% CLASS = CLASSIFY(SAMPLE,TRAINING,GROUP,TYPE,PRIOR) により、3つの方法の
% いずれか1つで、グループに対する事前確率を指定することができます。
% PRIOR は、GROUP の一意的な値の数と同じ長さの数値的なベクトルとなることが
% できます。GROUPが、数値である場合、PRIOR の順番は、GROUPにソートされて
% いる値に対応し、あるいは、GROUP が文字列を含む場合、GROUPの値の最初の
% 事象の順番に対応します。PRIOR は、フィールド'prob'をもつ 1×1 構造体、
% 数値ベクトル、さらに、GROUPと同じタイプで'prob'の要素がどのグループに
% 相当するかを示す一意的な値を含む'group'と設定することもできます。
% 構造体として、PRIOR は、GROUPに現れないグループを含むこともできます。
% これは、TRAINING が、より大きい訓練データのサブセットである場合、有効に
% なります。最終的に、PRIOR は、TRAINING のgroupの相対的頻度から推定される
% groupの事前確率を示す、 文字列の値'empirical'になることもできます。
% PRIORは、デフォルトで、等しい確率を示す数値ベクトル、すなわち、一様分布に
% 等しいものになります。 PRIOR は、エラーの割合の計算を除いて、Mahalanobis
% 距離による判別には使用されません。
%
% 例題:
%
%      % 訓練データ: 2つの正規分布の成分
%      training = [mvnrnd([ 1  1],   eye(2), 100); ...
%                  mvnrnd([-1 -1], 2*eye(2), 100)];
%      group = [repmat(1,100,1); repmat(2,100,1)];
%      % あるランダムな標本データ
%      sample = unifrnd(-5, 5, 100, 2);
%
%      % 既知の事前値、 group 1 の30% の確率、 group 2 の70% の確率を
%      % 使った分類
%      c = classify(sample, training, group, 'quad', [.3 .7]);
%


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:11:04 $
