%function out = step_tr(timedata,stepdata,tinc,lastt)
%
% 独立変数のステップ信号の関数を作成します。TIMEDATAベクトルは、ステップ
% の変化が発生する"時間"を示し、ステップ信号の値は、ベクトルSTEPDATAによ
% って与えられます。最後の2つの変数TINCとLASTTは、サンプル時間とステップ
% 信号の長さに対応します。
%
%   TINC  - 時間ステップ
%   LASTT - 終了時刻
%
% 参考: COS_TR, SIGGEN, SIN_TR.



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
