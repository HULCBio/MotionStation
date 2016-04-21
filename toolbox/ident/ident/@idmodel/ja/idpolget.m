% IDPOLGET は、idpoly の補助関数です。 
% IDPOLGET は、IDSS モデルと等価な IDPOLY を作成し、.Utility.Idpoly にス
% トアします。
% 
%   [idpol, sys1, flag] = IDPOLGET(sys,noises,ts)
%
%   idpol        : IDPOLY モデルの配列、各出力に一つ
%          
%   sys1         : sys1.Utility.Idpoly にストアされている idpol をもつ 
%                  sys、これらは、noisecnv(sys) に対して計算されます。
%   flag = 1     ：IDPOLY モデルが、前に計算されていない場合
%
%   noises = 'g' : すべてのノイズ源が入力として取り扱われ、それらの間の
%                  相関も計算されます。
%   noises = 'd' : ノイズフィルタ H は対角であると、仮定しています。
%
%   ab = 'a' の場合、idpolget は、noisecnv(sys,'norm') に対応する IDPOLY
%        モデルを出力します。
%        - ノイズを取り扱う (デフォルト)
%   ab = 'b' の場合、idpolget は、noisecnv(sys) に対応する IDPOLY モデル
%        を出力します。
%        - ノイズを取り扱う。後者は、sys1.Utility.Idpolyboth にストアされ
%          ます。



%   Copyright 1986-2001 The MathWorks, Inc.
