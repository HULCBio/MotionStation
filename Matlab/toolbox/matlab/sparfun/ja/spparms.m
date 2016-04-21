% SPPARMS   スパース行列のルーチンに対してパラメータを設定します。
% 
% SPPARMS('key',value) は、スパースルーチン、および特に最小度合いの
% 並べ替え COLMMD と SYMMMD およびスパース / と \ で用いる調整可能
% な複数のパラメータを設定します。
% 
% SPPARMS 自身では、カレントの設定を表示します。
%
% 入力引数がなければ、values = SPPARMS は、カレントの設定値を成分とする
% ベクトルを出力します。[keys,values] = SPPARMS は、カレントの設定値を成分
% とするベクトルと、パラメータのキーワードを行の成分とする文字列行列とを出
% 力します。
%
% SPPARMS(values) は、出力引数なしで、すべてのパラメータを引数ベクトルで指定された値に設定します。
%
% value = SPPARMS('key') は、1つのパラメータのカレント値を出力します。
%
% SPPARMS('default') は、すべてのパラメータをデフォルト値に設定します。
% SPPARMS('tight') は、最小度合いの並べ替えのパラメータを、"tight"(厳密)値
% に設定します。これは、少ない充填で並べ替えを行うことができますが、並べ
% 替えに時間がかかるようになります。
%
% パラメータのキーワードとそのデフォルト値およびtight値はつぎの通りです。
% 
%                キーワード	  デフォルト値	 tight値
%
%    values(1)     'spumoni'       0
%    values(2)     'thr_rel'       1.1             1.0
%    values(3)     'thr_abs'       1.0             0.0
%    values(4)     'exact_d'       0               1
%    values(5)     'supernd'       3               1
%    values(6)     'rreduce'       3               1
%    values(7)     'wh_frac'       0.5             0.5
%    values(8)     'autommd'       1            
%    values(9)     'autoamd'      1
%    values(10)    'piv_tol'      0.1
%    values(11)    'bandden'      0.5
%    values(12)    'umfpack'       1
%
% パラメータの意味は、つぎの通りです。
%
%    spumoni:  スパースモニターフラグで、診断出力を制御します。0は診断出
%              力をしません。1は診断出力を行います。2は詳しい情報を出力し
%              ます。
%    thr_rel,
%    thr_abs:  最小度合いのしきい値は、thr_rel*mindegree + thr_abs です。
%    exact_d:  ゼロでなければ、最小度合いに正確な度合いを使います。ゼロで
%              あれば、近似の度合いを使います。
%    supernd:  正であれば、MMDは supernd 段階毎に supernodes を組み込み
%				 ます。
%    rreduce:  正であれば、MMDは rreduce 段階毎に行の縮小を行います。
%    wh_frac:  density > wh_frac である行は、COLMMD では無視されます。
%    autommd:  非ゼロであれば、QR に基づく \ と / による MMD
%              並べ替えを行います。
%    autoamd:  非ゼロであれば、LU に基づく \ と / による COLAMD 並べ
%              替えを行います。
%    piv_tol:  ピボット許容誤差は、LUに基づく(UMFPACK) \ と / を用います。
%    bandden:  帯域密度が bandden より大きい場合、バックスラッシュは、
%              帯域ソルバを使用します。
%              bandden = 1.0 の場合、帯域ソルバを使いません。
%              bandden = 0.0 の場合、常に帯域ソルバを使います。
% 				  
% 注意: 
% 対称の正定行列のCHOL に基づく \ と / は、SYMMMD を使用します。
% 平方行列の UMMFPACK LU に基づく \ と / (UMFPACK) は、修正された
% COLAMD を使用します。
% 平方行列の v4 LU に基づく \ と / (UMFPACK) は、COLAMD を使用します。
% 長方形の行列の QR に基づく \ と / は、COLMND を使用します。
%
% 参考：COLMMD, SYMMMD, COLAMD, SYMAND, UMFPACK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.10.4.1 $  $Date: 2004/04/28 02:03:32 $
