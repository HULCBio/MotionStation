%  関数LMIINFOで利用
%
%  [type_a,type_b,test_sym] = coeftype(lmi_t,data,type_var)
%
%　項lmi_tの係数A,Bの型の取得とA'=Bのテスト
%
%  入力:
%    LMI_T  A*Xk*Bに関連するLMI_TERMSからの項
%    DATA   係数データ
%
%  出力:
%    TYPE_A, TYPE_B : 係数AとBの型
%                     ( 0 -> スカラ, 1 -> フル)
%    TEST_SYM : A' = Bの場合1、そうでなければ0

% Copyright 1995-2001 The MathWorks, Inc. 
