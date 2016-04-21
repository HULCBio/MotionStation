% STMAK   st-型の関数の組立て
%
% ST = STMAK(CENTERS, COEFS) は、つぎの関数のst-型を ST に格納します。
%
%         x |--> sum_j COEFS(:,j)*psi(x - CENTERS(:,j))
% ここで psi は、
%          psi(x) := |x|^2 log(|x|^2) 
%
% であり、|x| は、ベクトル x のユークリッドの長さです。
% CENTERS と COEFS は、同じ列数をもつ行列でなければなりません。
%
% ST = STMAK(CENTERS, COEFS, TYPE) は、つぎの関数のst-型を ST に格納
% します。
%
%         x |--> sum_j COEFS(:,j)*psi_j(x)
%
% ここで、psi_j は、文字列 TYPE に示されるように、'tp00', 'tp10', 'tp01'の
% いずれかです。'tp' がデフォルトです。
% これらの様々なタイプについての以下の記述において、c_j は、CENTERS(:,j) 
% で、n は、項の数、すなわち、size(COEFS,2) に等しくなります。
%
% 'tp00': 2変数thin-plateスプライン
% psi_j(x) := phi(|x - c_j|^2), j=1:n-3, ここで、phi(t) := t log(t) です。
% psi_{n-2}(x) := x(1); psi_{n-1}(x) := x(2); psi_n(x) := 1 です。
%
% 'tp10': 1番目の引数に関するthin-plateスプラインの偏微分
% psi_j(x) := phi(|x - c_j|^2) , j=1:n-1, ここで、  
% phi(t) := (D_1 t)(log(t)+1)  であり、 D_1 t は、x(1) についての
% t := t(x) := |x - c|^2 の微分です。psi_n(x) := 1 です。
%
% 'tp01': 2番目の引数に関するthin-plateスプラインの偏微分
% psi_j(x) := phi(|x - c_j|^2) , j=1:n-1, ここで、
% phi(t) := (D_2 t)(log(t)+1)  であり、 D_2 t は、x(2) についての
% t := t(x) := |x - c|^2 の微分です。psi_n(x) := 1 です。
%
% 'tp': 純粋な2変数thin-plate スプライン (デフォルト) 
% psi_j(x) := phi(|x - c_j|^2), j=1:n, ここで、phi(t) := t log(t)です。
%  
% ST = STMAK(CENTERS, COEFS, TYPE, INTERV) は、st-型の基本区間を、形式 
% {[a1,b1],...} をもつ与えられた INTERV に設定します。
% INTERV のデフォルトの値は、すべての中心を含む最小の軸平行なボックス
% です。すなわち、[ai,bi] は [min(CENTERS(i,:)),max(CENTERS(i,:))] です。
% ただし、つぎの例外があります。1つだけ中心がある場合、基本区間は、左下の
% 角としてその唯一の中心をもつ辺の長さが1のボックスです。 
%
% 参考 : STBRK, STCOL, FNBRK.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
