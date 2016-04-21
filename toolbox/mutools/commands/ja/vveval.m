% function [out1,out2,out3,...] = vveval(name,in1,in2,in3,...)
%
% MATLABのFEVALと同様に機能しますが、VARYING行列とCONSTANT/SYSTEM行列に
% 対しても機能します。NAMEは、MATLAB関数名(ユーザが作成、またはMATLABが
% 提供するもの)を含むキャラクタ文字列です。
%
%	in1, in2, ... in_lastが、すべてCONSTANTまたはSYSTEM行列の場合、
%       VVEVALは、FEVALを使って、変数NAMEで指定した関数を呼び出します。
%
%       in1, in2, ... in_nのいずれかがVARYING行列、つまり、in_Kの場合、
%       VVEVALはすべてのVARYING行列のデータが同じであることをチェック
%       し、つぎの方法でリカーシブに自身を呼び出すことによって、ループ
%       を実行します。
%
%   out1 = [];
%
%   outm = [];
%   for i=1:length(getiv(in_K))
%      [t1,t2,..,tm] = vveval(xtracti(in1,i),xtracti(in2,i),...
%        ,xtracti(in_n,i);
%     out1 = [out1;t1];
%     out2 = [out2;t2];
%     outm = [outm;tm];
%   end
%   out1 = vpck(out1,ivvalue);
%   out2 = vpck(out2,ivvalue);
%   outm = vpck(outm,ivvalue);
%
% 参考: EVAL, FEVAL, SWAPIV, VEVAL, MVEVAL.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
