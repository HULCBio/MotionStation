% function [dsysl,dsysr] = musynfit(pre_dsysl,Ddata,sens,blk,nmeas,...
%                             ncntrl,clpg,upbd,wt)
%
% DDATAデータにD周波数応答(PRE_DSYSL)を乗算することにより得られるゲイン
% カーブを近似します。安定な、最小位相システム行列DSYSLとDSYSRを出力し、
% これらは、(MMULTを使って)乗算によってオリジナルの相互結合構造に組み込
% まれ、(MINVを使って)逆行列を出力します。一度組み込まれると、H∞設計は、
% MUシンセシスの別のイタレーションによって実行されます。
%
% 最初のMUシンセシスイタレーションに関しては、変数PRE_DSYSLに文字列'fi-
% rst'を設定します。連続的にイタレーションを続けるには、PRE_DSYSLは、1つ
% 前の(左)有理Dスケーリングシステム行列DSYSLを設定しなければなりません。
%
% (オプション)変数CLPGは、DDATA, SENS, UPBDデータを作成した行列です。DD-
% ATAを近似するときに、安定な最小位相システム行列DSYSLとDSYSRは、オリジ
% ナルの行列CLPGに組み込まれ、UPBDデータと共にプロットされます。これらの
% 2つのプロットを比較することは、有理システム行列DSYSLとDSYSRが、どの程
% 度DDATAを近似しているかに関して洞察を与えます。新規にスケーリングされ
% た行列DMDIが出力されます。これは、DSYSLとDSYSRが組み込まれているCLPGで
% す。CLPGとUPBDが与えられなければ、デフォルトでSENS変数を代わりにプロッ
% トします。
%
% オプションの変数WTを使って、DDATAに重み付けることができます。デフォル
% トは、DDATAに対して付加的な重み付けを行いません。
%
% FITMAGの代わりにFITMAGLPが呼び出されることを除いて、MUSYNFITと同じで、
% このコマンドではMAGFITを呼び出します。
%
% 参考: DKIT, FITMAGLP, FITSYS, MAGFIT, MUFTBTCH, MUSYNFIT.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
