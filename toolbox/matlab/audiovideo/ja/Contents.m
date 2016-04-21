% オーディオおよびビデオサポート
%
% オーディオの入力/出力オブジェクト
%   audioplayer   - オーディオプレイヤーオブジェクト
%   audiorecorder - オーディオレコーダオブジェクト
%
% オーディオハードウェアドライバ
%   sound         - ベクトルを音声として再生
%   soundsc       - 音声としてのオートスケーリングと再生
%   wavplay       - Windows オーディオ出力デバイスを使って音声を再生
%   wavrecord     - Windows オーディオ入力デバイスを使って音声を録音
%
% オーディオファイルのインポート/エクスポート
%   aufinfo       - AU ファイルについての情報を出力
%   auread        - NeXT/SUN (".au") サウンドファイルの読み込み
%   auwrite       - NeXT/SUN (".au") サウンドファイルの書き出し
%   wavfinfo      - WAV ファイルについての情報を出力
%   wavread       - Microsoft WAVE (".wav") サウンドファイルの読み込み
%   wavwrite      - Microsoft WAVE (".wav") サウンドファイルの書き出し
%
% ビデオファイルのインポート/エクスポート
%   aviread       - ムービー (AVI) ファイルの読み込み
%   aviinfo       - AVI ファイルについての情報を出力
%   avifile       - 新規 AVI ファイルの作成
%   movie2avi     - MATLAB ムービーから AVI ムービーの作成
%
% ユーティリティ
%   lin2mu        - 線形信号をmu-則符号化に変換
%   mu2lin        - mu-則符号化を線形信号に変換
%
% 例題のオーディオデータ (MAT ファイル).
%   chirp         - 周波数スィープ            (1.6 sec, 8192 Hz)
%   gong          - ゴング                    (5.1 sec, 8192 Hz)
%   handel        - ハレルヤコーラス          (8.9 sec, 8192 Hz)
%   laughter      - 群集の笑い声              (6.4 sec, 8192 Hz)
%   splat         - 薄板による Chirp 波       (1.2 sec, 8192 Hz)
%   train         - 汽車の汽笛　　            (1.5 sec, 8192 Hz)
%
% 参考 IMAGESCI, IOFUN.

% 廃止された関数
%   saxis         - Sound axis スケーリング
% 
% ユーティリティ
%   playsnd       - SOUND の実行

%   Copyright 1984-2003 The MathWorks, Inc. 
