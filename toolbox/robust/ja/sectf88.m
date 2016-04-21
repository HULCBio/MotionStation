% SECTF88 は、1988年バージョンのセクタ変換です。
%
% [SS_P] = SECTF(SS_,d11,a,b,sectype)、または、
% [Ap,Bp,Cp,Dp] = SECTF(A,B,C,D,d11,a,b,sectype) は、セクタ[a,b]の中のオリ
% ジナルの入力-出力組(U1,Y1)が他のセクタ[x,y]にマッピングされるようなプラ
% ント P(s)の入力-出力チャンネル1、等々の関係のチャンネルに、多変数セクタ
% 双一次変換が適用されます。
%
%                           |A  B1  B2 |
%           P(s) := |A B| = |C1 D11 D12|
%                   |C D|   |C2 D21 D22|
%
%           d11 = D11 と同様なサイズの行列
%
% 4つのオプションがあります(0 < b <= inf, a < bの関係が必要)。
%
%       sectype = 1, sector(a,b) -----> sector(0,inf) = 正の実問題
%       sectype = 2, sector(a,b) -----> sector(-1,1)  = スモールゲイン問題
%       sectype = 3, sector(0,inf) ---> sector(a,b) (sectype 1の逆写像)
%       sectype = 4, sector(-1,1) ----> sector(a,b) (sectype 2の逆写像)
%

% Copyright 1988-2002 The MathWorks, Inc. 
