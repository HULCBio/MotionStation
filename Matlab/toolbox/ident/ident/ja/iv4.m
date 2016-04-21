% IV4  最適な IV を使って、ARX モデルを計算します。
% 
%   MODEL = IV4(DATA,NN)
%
%   MODEL : つぎの型をした ARX モデル
%   
%              A(q) y(t) = B(q) u(t-nk) + v(t)
%   
%           の推定した結果と、共分散と構造情報を含んだものを出力。
% MODEL の正確なフォーマットに関して、HELP IDPOLY と (多出力モデルに対し
% て)HELP IDARX を参照してください。
%
%   DATA  : 単出力 IDDATA オブジェクトとして表した出力 - 入力データ。詳
%           細は、HELP IDDATA を参照。
%
%   NN    : NN = [na nb nk] 。上のモデルの次数と遅れ。
%           多出力システムに対して、NN は出力と同じ行数をもっています。
%           そのため、na は、ny|ny 行列で、その i 行 j 列の要素は、i 番
%           目の入力と j 番目の出力を関連付ける多項式(遅れ演算子を含んで
%           )の次数を表しています。同様に、nb と nk も ny|nu 行列になり
%           ます(ny:# は出力を、nu:# は入力)。
%
% 別の表現は、MODEL = IV4(DATA,'na',na,'nb',nb,'nk',nk) です。
%
% アルゴリズムに｢関連したいくつかのパラメータもアクセスできます。
% 
%   MODEL = IV4(DATA,ORDERS,'MaxSize',MAXSIZE)
%
% ここで、MAXSIZE は、メモリとスピードのトレードオフをコントロールします。
% マニュアルを参照してください。プロパティ名と値を組で設定する方法を使う
% 場合、個々の組を設定する順番は任意です。省略したものは、デフォルト値が
% 使われます。MODEL プロパティ'FOCUS' と'INPUTDELAY' は、つぎのように
% 
%   M = IV4(DATA,[na nb nk],'Focus','Simulation','InputDelay',[3 2]);
% 
% プロパティ名/値の組で設定されます。IDPROPS ALGORITHM と IDPROPS IDMO-
% DEL を参照してください。
%    
% 参考： ARX, ARMAX, BJ, N4SID, OE, PEM.

%   L. Ljung 10-1-86,4-15-90


%   Copyright 1986-2001 The MathWorks, Inc.
