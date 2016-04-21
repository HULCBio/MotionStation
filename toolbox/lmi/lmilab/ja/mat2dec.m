% decvars = mat2dec(lmisys,X1,X2,X3,...)
%
% 連立LMI LMISYSに関する行列変数の値X1, X2, X3, ... を与えると、MAT2DEC
% は、決定変数のベクトルの値DECVARSを計算します。この操作は、DEC2MATによ
% って行われるものの逆操作です。
%
% 入力:
%    LMISYS     連立LMIを記述する配列。
%    X1, X2, X3,...
%               行列変数の値。MAT2DECは、最大20個の値をもちます。
%               行列変数が割り当てられないままならば、エラーが出力されま
%               す。
% 出力:
%    DECVARS    決定変数の値のベクトル。
%
% 参考：    DEC2MAT, DECINFO, DEFCX.



% Copyright 1995-2002 The MathWorks, Inc. 
