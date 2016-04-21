% HANK2SYS    Hankel 行列を線形システムモデルへ変換
%
% [NUM, DEN] = HANK2SYS(H, INI, TOL) は、Hankel 行列 H を分子 NUM と分母
% DEN の線形システム伝達関数へ変換します。INI は、時間0でのシステムイン
% パルスです。TOL > 1 のとき、TOL は変換の次数を表します。TOL < 1 のとき
% TOL は、特異値に基づいて次数を選択する際の許容誤差を表します。TOL の
% デフォルト値は0.01です。この変換では、特異値分解(SVD)を使用します。
% 
% [NUM, DEN, SV] = HANK2SYS(...) は、伝達関数と SVD 値を出力します。
% 
% [A, B, C, D] = HANK2SYS(...)は、線形システムの状態空間モデルの A, B, 
% C, D 行列を出力します。
% 
% [A, B, C, D, SVD ] = HANK2SYS(...) は、状態空間モデルと SVD 値を出力
% します。
%
% 参考： RCOSFLT.


%   Copyright 1996-2002 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $
