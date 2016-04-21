%APPEND は、入力と出力を追加することで、IDMODELS をグループ化します。
%   Control System Toolboxが必要です。
%
%   MOD = APPEND(MOD1,MOD2, ...) は、つぎの集合システムを生成します。
% 
%                 [ MOD1  0       ]
%           MOD = [  0   MOD2     ]
%                 [           .   ]
%                 [             . ]
%
%   APPEND は、結果のモデル MOD を生成するために、モデル MOD1, MOD2,...の
%   入力ベクトルと出力ベクトルを結合します。
%
%   注意: APPEND は、測定された入力チャンネルのみを取り扱います。ノイズ
%         入力チャンネルも内部接続するためには、あらかじめ NOISECNV を利
%         用して観測チャンネルに変換しておく必要があります。
%
%   共分散情報は失われます。
%
%   参考: FEEDBACK, PARALLEL, SERIES



%   Copyright 1986-2001 The MathWorks, Inc.
