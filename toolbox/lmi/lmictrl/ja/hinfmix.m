% [gopt,h2opt,K,R,S] = hinfmix(P,r,obj,region,dkbnd,tol)
%
% 極配置制約を付けたH2/Hinf混合シンセシス
%
% つぎの状態空間方程式で表現されるLTIプラントPを入力します。
%
% 	 dx/dt = A  * x + B1  * w + B2  * u
%	  zinf = Ci * x + Di1 * w + Di2 * u
%	   z2  = C2 * x + D21 * w + D22 * u
%           y  = Cy * x + Dy1 * w + Dy2 * u
% 
% HINFMIXは、つぎを満足する出力フィードバックコントロールu = K(s)*yを計
% 算します。
% 
%  * wからzinfまでのRMSゲインGが値OBJ(1)より小さい。
%  * wからz3までのH2ノルムHが値OBJ(2)より小さい。
%  * つぎの型のトレードオフ基準を最小化。
%              OBJ(3) * G^2 + OBJ(4) * H^2
%  * REGIONで設定したLMI領域に閉ループの極を設定。
%
% 入力:
%  P        LTIプラント。
%  R        z2, y, uの長さを表わす1行3列ベクトル。
%  OBJ      H2/Hinf目的関数を設定する4要素ベクトル:
%           OBJ(1)  : wからzinfまでのRMSゲインの上界(0=未定義)。
%           OBJ(2)  : wからz2までのH2ノルムの上界(0=未定義)。
%           OBJ(3:4): HinfおよびH2性能の相対重み(上記を参照)。
%  REGION   オプション。M行(2M)列行列[L,M]は、極配置のための領域を設定し
%           ます。
%                { z :  L + z * M + conj(z) * M' < 0 }
%           REGIONを作成するためには、対話的関数LMIREGを使います。デフォ
%           ルトREGION=[]は、閉ループ安定性を設定します。
%  DKBND    オプション: K(s)の静的ゲインDKのノルムの境界
%           (100=デフォルト。0は、厳密にプロパなコントローラです)。
%  TOL      オプション: 目的値に対する目標相対精度(デフォルト=1e-2)
%
% 出力:
%  GOPT     wからzinfにおいて保証された閉ループRMSゲイン。
%  H2OPT    wからz2において保証された閉ループH2ノルム。
%  K        最適出力フィードバックコントローラ。
%  R,S      LMIの可解条件での解。
%
% 参考：    LMIREG, HINFLMI, MSFSYN.



% Copyright 1995-2002 The MathWorks, Inc. 
