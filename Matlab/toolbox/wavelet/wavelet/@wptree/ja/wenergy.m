% WENERGY   ウェーブレットパケット分解に対するエネルギ
%
% ウェーブレットパケットツリー T に対して(WPTREE, WPDEC, WPDEC2 を参照)、
% E = WENERGY(T) は、ツリー T の終端ノードに対応するエネルギのパーセン
% テージを含むベクトル E を出力します。
%
% 例題:
%     load noisbump
%     T = wpdec(noisbump,3,'sym4');
%     E = wenergy(T)
%     ------------------------------
%     load detail
%     T = wpdec2(X,2,'sym4');
%     E = wenergy(T)


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:13:17 $
