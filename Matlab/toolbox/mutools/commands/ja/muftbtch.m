% function [dsysl,dsysr] = ...
%   muftbtch(pre_dsysl,Ddata,sens,blk,nmeas,ncntrl,dim,wt)
%
% DDATAデータにD周波数応答(PRE_DSYSL)を乗算することにより得られるゲイン
% カーブを近似します。安定な、最小位相システム行列DSYSLとDSYSRを出力し、
% これらは、(MMULTを使って)乗算によってオリジナルの相互結合構造に組み込
% まれ、(MINVを使って)逆行列を出力します。一度組み込まれると、H∞設計は、
% muシンセシスの別のイタレーションによって実行されます。
%
% 最初のMUシンセシスイタレーションに関しては、変数PRE_DSYSLに文字列'fi-
% rst'を設定します。連続的にイタレーションを続けるには、PRE_DSYSLは、1つ
% 前の(左)有理Dスケーリングシステム行列DSYSLを設定しなければなりません。
%
% MAGFITに対して、dim=[hmax,htol,nmin,nmax]と設定します(dim=[.26,.1,0,3]
% は、可能な場合は、精度が1dBで、3次の近似を得ます)。
%
% 参考: FITMAG, FITSYS, MAGFIT, MUSYNFIT, MUFTBTCH, MUSYNFLP.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
