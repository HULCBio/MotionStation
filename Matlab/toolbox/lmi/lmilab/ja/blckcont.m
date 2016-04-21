%  関数LMIINFOで利用
%
%  [blck_str,n_ab,n_c] = blckcont(LMI_var,LMI_term,data,nr_lmi,...
%                                          r_l,ind_row,ind_col,n_ab,n_c)
%
% LMIのインナーファクターからブロックのシンボリックな形式での文字への書
% きこみ。
%
%  入力:
%    NR_LMI              着目するLMIの番号
%    R_L                 LMIの左右の指標 ('r'、または、'l')
%    IND_ROW, IND_COL    ブロックの行と列のインデックス
%    N_AB, N_C           係数A, B, Cのインデックス
%
%  出力:
%    BLCK_STR     NR_LMI番目のLMIのR_Lインナーファクターの(IND_ROW,IND_
%                 COL)ブロックのシンボリック形式を含む文字列
%    N_AB, N_C    A, B, Cに対する新たなインデックス

% Copyright 1995-2001 The MathWorks, Inc. 
