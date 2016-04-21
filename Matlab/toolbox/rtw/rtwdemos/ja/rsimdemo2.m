% RSIMDEMO2  異なる Chirp 入力を使って、10回の RSim シミュレーションを実
% 行します。
% RSIMDEMO2は、.matファイルから読み込まれ、From Fileブロック内で利用され
% る新たな信号データを用いて、Simulinkモデルをコンパイルされたシミュレー
% ションとして実行するための、Rapid Simulation Target (RSim)の利用を説明
% します。
%
% この例題では、RSimの一連のコンパイルされたシミュレーションに対する入力
% シミュレーションデータとして用いられるchirp信号群を作成します。
%
% 5回のシミュレーションを実行することにより、4 rads/secから1000 rads/sec
% 近くまで周波数範囲を動かします。



% $Revision: 1.6 $
%   Copyright 1994-2002 The MathWorks, Inc.
