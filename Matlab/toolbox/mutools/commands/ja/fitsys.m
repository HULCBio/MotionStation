% function sys = fitsys(frdata,order,weight,code,idnum,discflg)
%
% FITSYSは、WEIGHTで(オプションとして)定義された周波数依存重みを使って、
% 周波数応答データFRDATAを次数ORDERの伝達関数で近似します。
%
% FRDATA : 与えられた周波数応答データのVARYING行列。これは、行または列の
%          VARYING行列でなければなりません。
% ORDER  : データを近似するSYSTEM行列の次数。
% WEIGHT : VARYING/SYSTEM/CONSTANT行列。最小二乗近似の重みとして使われま
%          す(デフォルト=1)。
% CODE   : 0 - SYSの極の位置に制限はありません(デフォルト)。
%          1 - SYSは安定な最小位相に制限され、FRDATAは1行1列のVARYING行
%              列でなければなりません。
%          2 - 有理近似に制限されるので、SYSは安定です。
% IDNUM  : 最小二乗の繰り返し回数(デフォルト = 2)
% DISCFLG: DISCFLG == 1(デフォルト=0)の場合、すべての周波数データは単位
%          円データとして解釈され、SYSは離散時間として解釈されます。DI-
%          SCFLG == 0の場合、周波数データは、虚軸に解釈され、SYSは連続時
%          間に解釈されます。4番目の引数 CODEは、オプションです。CODE ==
%          0(デフォルト)の場合、有理数近似は、制約を受けません。CODE == 
%          1 の場合、MUシンセシスルーチンで、有理数近似は、答えに対して、
%          スペクトル分解を単に行うことで、安定で、最小位相であることが
%          条件になります。この場合、応答FRDATAは、プログラムGENPHASEか
%          ら得られ、これは、既に、安定で、最小位相伝達関数に対応してい
%          ます。



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
