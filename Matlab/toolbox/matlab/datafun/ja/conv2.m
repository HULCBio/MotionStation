% CONV2  2次元のコンボリューション
%
% C = CONV2(A, B) は、行列AとBの2次元のコンボリューションを行います。
% [ma,na] = size(A) で、[mb,nb] = size(B)の場合、size(C) = [ma+mb-1,
% na+nb-1]になります。
% C = CONV2(H1, H2, A) は、まずベクトルH1を使って行の方向に、つぎにベクトル
% H2を使って列の方向にAのコンボリューションを行います。 
% 
% C = CONV2( ... ,'shape') は、以下の'shape'によって指定されるサイズをもつ
% 2次元コンボリューションのサブセクションを出力します。
%     'full'  - (デフォルト) 完全な2次元コンボリューションを出力します。
%     'same'  - Aと同じサイズで、コンボリューションの中央部を出力します。
%     'valid' - エッジにゼロを加えずに計算されたコンボリューションの部分
%               のみを出力します。all(size(A) >= size(B))のとき、
%               size(C) =[ma-mb+1,na-nb+1]で、そうでない場合はCは空です。
%
% 参考 ： CONV, CONVN, FILTER2, XCORR2(Signal Processing Toolbox)


%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:46:30 $
%   Built-in function.
