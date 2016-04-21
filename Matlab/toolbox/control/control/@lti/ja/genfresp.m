% GENFRESP   MIMOモデルの周波数グリッドと応答データを作成
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC) は、自動生成
% された周波数グリッド W 上で、単一MIMOモデル SYSの周波数応答の大きさ
% MAG と位相 PH(ラジアン)を計算します。
%
% GRADE と FGRIDSPEC は、以下のようにグリッド間隔と密度を制御します。
%
%  GRADE and FGRIDSPEC control the grid density and span as follows:
%    GRADE          1 :  Nyquist プロット(最も細かい)
%                   2 :  Nichols プロット  
%                   3 :  Bode プロット
%                   4 :  Sigma プロット
%    FGRIDSPEC     [] :  自動的に決まる帯域
%            'decade' :  自動的に決まる帯域 + 10^k 点を含むグリッド 
%         {fmin,fmax} :  ユーザ定義の帯域 (グリッドはこの帯域にかかります)
%
% 構造体 FOCUSINFO は、応答の各評価を表示するために、選ばれた周波数帯域を
% 含みます(FOCUSINFO.Range(k,:) は、k番目の評価に対して選ばれたものです)
%
% [MAG,PHASE,W,FOCUSINFO] = GENFRESP(SYS,GRADE,FGRIDSPEC,Z,P,K) は、SYS 
% の各I/O の組に対して、零点、極、ゲインを与えます。
%
% 参考 : FREQRESP, BODE, NYQUIST, NICHOLS.


%  Author(s): P. Gahinet
%  Copyright 1986-2002 The MathWorks, Inc.
