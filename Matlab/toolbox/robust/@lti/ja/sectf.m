% SECTF セクタ変換
%
% [SYSG,SYST] = SECTF(SYSF,SECF,SECG)、または、
% [AG,BG,CG,DG,AT,BT1,...,DT21,DT22]=SECTF(AF,BF,CF,DF,SECF,SECG); 
% または、
% [AG,BG1,...,DG22,AT,BT1,...,DT21,DT22]=SECTF(AF,BF1,...,DF22,SECF,SECG);
%
% SECTFは、G(s)の入出力(Ug,Yg)がセクタSECGに存在するようなセクタ変換シス
% テム G(s)を算出します。必要十分条件は、F(s)の対応するMベクトル入出力
% (Uf,Yf)がセクタSECFに存在することです。また、SYSG = LFTF(SYST,SYSF)を
% 満足する線形分数変換T(S)も算出されます。
% 入力: SYSF -- 'ss'または'tss'形式のシステム;
%               または、
%               対応する行列AF,BF,CF,DF、
%               または、
%               AF,BF1,BF2,CF1,CF2,DF11,DF12,DF21,DF22のリスト;
%               'tss'形式の場合、(Uf1,Yf1)にセクタ変換が適用されます。
% SECF,SECG  -- つぎの形式のセクタ:
%       形式:                      対応するセクタ:
%       [A,B]、または、[A;B]       0> <Y-AU,Y-BU>
%       [A,B]、または、[A;B]       0> <Y-diag(A)U,Y-diag(B)U>
%       [SEC11 SEC12;SEC21,SEC22]  0> <SEC11*U+SEC12*Y,SEC21*U+SEC22*Y>
% 
% ここで、A,Bは[-Inf,Inf]のスカラ、M行M列正方行列、M-ベクトルのいずれか
% です。そして、SEC=[SEC11,SEC12;SEC21,SEC22]は、1行1列(スカラ)かM行M列
% ブロック SEC11,SEC12,SEC21,SEC22の、行列、または、'tss'システムです。
% 出力:  SYSG -- F(s)と同じ形式のG(s) (たとえば、'ss'形式や'tss'形式)
%        SYST -- 'tss'形式のT(s); または、行列AT,BT1,...,DT22のリスト
%
% 参考： LFTF, SEC2TSS and MKSYS.



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
