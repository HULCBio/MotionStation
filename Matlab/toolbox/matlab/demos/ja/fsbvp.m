% FSBVP  端点での変化を連続にする
%
% Falkner-Skan BVPs は、平坦な平面上に粘性、非圧縮の層流の近似解に起因し
% ています。例題は、つぎの境界条件
%     f(0) = 0, f'(0) = 0, f'(infinity) = 1
%     beta = 0.5
% をもち、つぎの方程式で表わせます。
%         f''' + f*f'' + beta*(1-(f')^2) = 0
% 
% BVP は、有限点'infinity'での境界条件の下で、解かれます。この端点を連続
% にすることにより、'infinity'の大きな値に対して、収束するように使います。
% そして、'infinity'を十分に大きくした場合に整合性のある結果を保証するよ
% うにします。'infinity'のある値に対する解は、BVPINIT を使って、より大きな
% 'infinity'に対する推定に拡張します。
%
% 参考：BVP4C, BVPINIT, @.


%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.2.4.1 $  $Date: 2004/04/28 01:48:39 $
