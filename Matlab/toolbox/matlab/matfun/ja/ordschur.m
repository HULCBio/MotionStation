%ORDSCHUR  Schur 分解における固有値の並べ替え
% [US,TS] = ORDSCHUR(U,T,SELECT) は、行列 X の Schur 分解 X = U*T*U'
% を並べ替え、固有値の選択されたクラスタが、quasitriangular Schur 行列
% T のleading (左上の) 対角ブロックに現れ、対応する不変部分空間が、 
% U の leading columns によりスパンされます。 論理ベクトル SELECT は、
% 選択されたクラスタを E(SELECT) として指定します。
% ここで、E = EIG(T) です。
%
% ORDSCHUR は、SCHUR コマンドにより生成された行列U,Tをとり、
% X = US*TS*US' を満たす、並べ替えられた Schur 行列 TS と 
% cumulative 直交変換 US を出力します。incremental 変換 
% T = US*TS*US' を得るためには、U=[]と設定してください。
% 
% [US,TS] = ORDSCHUR(U,T,KEYWORD) は、つぎの領域のいずれか1つにすべて
% の固有値を含むように選択したクラスタを設定します。
%
%     KEYWORD           選択領域
%      'lhp'            左半平面  (real(E)<0)
%      'rhp'            右半平面　(real(E)>0)
%      'udi'            単位円板の内部 (abs(E)<1)
%      'udo'            単位円板の外部 (abs(E)>1)
%
% ORDSCHUR は、複数のクラスタを直ちに並べ替えることもできます。
% クラスタインデックスのベクトル CLUSTERS が与えられ、E = EIG(T) 
% に比例し、同じ CLUSTERS 値をもつ固有値すべてが1つのクラスタを形成
% するような場合、[US,TS] = ORDSCHUR(U,T,CLUSTERS) は、上左角に現れる
% 最高のインデックスをもつクラスタ、TS の対角に沿って、降順で
% 指定クラスタをソートします。
%
% 参考 SCHUR, ORDQZ.

%   Copyright 1984-2002 The MathWorks, Inc. 
