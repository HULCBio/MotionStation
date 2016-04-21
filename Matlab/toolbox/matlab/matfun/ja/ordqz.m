%ORDQZ  QZ 分解における固有値の並べ替え
% [AAS,BBS,QS,ZS] = ORDQZ(AA,BB,Q,Z,SELECT) は、行列の組 (A,B) の QZ
% 分解 Q*A*Z = AA, Q*B*Z = BB を並べ替え、固有値の選択されたクラスタが
% quasitriangular の組 (AA,BB)の leading (左上) 対角ブロックに現れ、
% 対応する不変部分空間は、Z の leading columns によりスパンされます。
% 論理ベクトル SELECT は、選択されたクラスタを E(SELECT) として指定します。
% ここで、E = EIG(AA,BB) です。
%
% ORDQZ は、QZ コマンドにより生成された行列 AA,BB,Q,Z をとり、
% QS*A*ZS = AAS, QS*B*ZS = BBS を満たす、並べ替えられた組 (AAS,BBS) 
% と cumulative 直交変換 QS および ZS を出力します。
% (AA,BB) を (AAS,BBS) に変換する incremental QS,ZS を得るためには、
% Q=[] または、Z=[] と設定してください
% 
% [AAS,BBS,...] = ORDQZ(AA,BB,Q,Z,KEYWORD) は、つぎの領域のいずれか
% 1つに、すべての固有値を含むように選択されたクラスタを設定します。
%
%     KEYWORD           選択領域
%      'lhp'            左半平面  (real(E)<0)
%      'rhp'            右半平面  (real(E)>0)
%      'udi'            単位円板の内部 (abs(E)<1)
%      'udo'            単位円板の外部 (abs(E)>1)
%
% ORDQZ は、複数のクラスタを直ちに並べ替えることもできます。
% クラスタインデックスのベクトル CLUSTERS が与えられると、E = EIG(AA,BB)
% に比例し、同じ CLUSTERS 値をもつ固有値すべてが1つのクラスタを形成
% するような場合、[...] = ORDQZ(AA,BB,Q,Z,CLUSTERS) は、上左角に現れる
% 最高のインデックスをもつクラスタ、(AAS,BBS)の対角に沿って、降順で
% 指定クラスタをソートします。
%
%   参考 QZ, ORDSCHUR.

%   Copyright 1984-2002 The MathWorks, Inc. 
