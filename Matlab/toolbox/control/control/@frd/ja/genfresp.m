% GENFRESP   MIMOモデルの周波数グリッドと応答データを作成
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) は、自動生成
% された周波数グリッド W 上で、単一MIMOモデル SYS の周波数応答の大きさMAG 
% と位相 PH(ラジアン)を計算します。
% 
% GRADE と FGRIDSPEC は、グリッド間隔と密度を制御します。
%    GRADE               FRDモデルに対して無視されます
%    FGRIDSPEC     [] :  自動的に決まる帯域
%            'decade' :  自動的に決まる帯域 + 10^k 点を含むグリッド
%         {fmin,fmax} :  ユーザ定義の帯域(グリッドは、この帯域にかけ
%                        られます)
%
% 構造体 FOCUSINFO は、応答の各評価を表示するために選ばれた周波数帯域を
% 含みます。(FOCUSINFO.Range(k,:) は、k番目の評価に対する選ばれた帯域です)
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) は、SYS 
% の各I/Oの組み合わせに対する零点、極、ゲインも与えます。
%
% 参考 : FREQRESP, BODE, NYQUIST, NICHOLS.


%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
