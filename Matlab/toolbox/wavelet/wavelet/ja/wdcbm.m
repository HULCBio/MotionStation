% WDCBM 　Birge-Massart法を使って、ウェーブレット1次元雑音除去または圧縮に対応す
%         るスレッシュホールドを行います。
% [THR,NKEEP] = WDCBM(C,L,ALPHA,M) は、Birge-Massart 法を用いたウェーブレット係
% 数の選択規則によって得られる雑音除去、または圧縮に関して、レベルに依存にするス
% レッシュホールド値 THRと係数の数を保持する NKEEP を出力します。
%
% [C,L] は、レベル J0 = length(L)-2 において雑音除去、または圧縮された信号のウェ
% ーブレット分解構造です。ALPHA は、1より大きい実数でなければなりません。典型的
% には、圧縮の場合、ALPHA = 1.5で、雑音除去の場合は、ALPHA = 3となります。M は正
% の整数で、典型的には、もっとも粗い Approximation 係数の長さを2で割った値 M = L
% (1)/2 となります。
%
% THR は、長さ J0 のベクトルで、THR(:,I) は、レベル I に対して得られるスレッシュ
% ホールド値です。NKEEP は、長さ J0 のベクトルで、NKEEP(:,I) は、レベル I で保持
% される係数の数です。
%
% Birge-Massart の論文を参照すると、J0 は J0+1 となっています。J0、M、ALPHA　が、
% この手法を定義付けることになります。
%   - レベル J0+1(及びより粗いレベル)では、すべてのものが保持されます。
%   - 1から J0 までの範囲にあるレベル J において、より大きい係数である nj は、nj
%     = M/(J0+1-j)^ALPHA に保たれます。M は調整パラメータ(デフォルト値を参照)で
%     す。
%
% WDCBM(C,L,ALPHA) は、WDCBM(C,L,ALPHA,L(1)/2) と等価です。
%
% 参考文献： L. Birge, P. Massart, "From model selection to
%            adaptive estimation", in Festschrift for Lucien Le Cam,
%            D. Pollard, E. Torgersen, G.L. Yang editors, Springer, 
%            1997, p. 55-87
% 
% 参考： WDEN, WDENCMP, WPDENCMP.



%   Copyright 1995-2002 The MathWorks, Inc.
