% AIRY   Airy関数
% 
% W = AIRY(Z) は、Z の要素のAiry関数 Ai(z) です。
% W = AIRY(0,Z) は、AIRY(Z) と同じです。
% W = AIRY(1,Z) は、微係数 Ai'(z) です。
% W = AIRY(2,Z) は、第2種Airy関数 Bi(z) です。
% W = AIRY(3,Z) は、微係数 Bi'(z) です。
% 引数 Z が配列の場合は、結果は同じサイズになります。
%
% [W,IERR] = AIRY(K,Z) は、エラーフラグの配列も出力します。
%     ierr = 1   引数が間違っています。
%     ierr = 2   オーバフローでInfを出力します。
%     ierr = 3   引数を減らすことにより、精度が低下します。
%     ierr = 4   zが大き過ぎることにより、精度が低下します。
%     ierr = 5   収束しません。NaNを出力します。
%
% Airy関数と修正Bessel関数の関係は、つぎのようになります。
%
%     Ai(z) = 1/pi*sqrt(z/3)*K_1/3(zeta)
%     Bi(z) = sqrt(z/3)*(I_-1/3(zeta)+I_1/3(zeta))
%     ここで、zeta = 2/3*z^(3/2) です。
%
% このM-ファイルは、D. E. AmosによるFortranライブラリへのMEXインタ
% フェースを使用します。
%
% 参考：BESSELJ, BESSELY, BESSELI, BESSELK.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.8.4.1 $  $Date: 2004/04/28 02:03:49 $
