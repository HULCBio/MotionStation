% function  [sysk,emax,sysobs]=ncfsyn(sysgw,factor,opt)
%
% システム記述の正規化された既約因子の中の不確かさの大きさにより与えられ
% るシステム群をロバスト安定化させるコントローラを設計します。
%
% 入力:
% -------
%  SYSGW  - 制御される重み付きシステム
%  FACTOR - =1 最適コントローラが必要とされます。
%           >1 最適より若干性能が落ちるFACTOR値を達成する準最適コントロ
%              ーラが必要とされます。
%  OPT    - 'ref'は、リファレンス入力を含みます(オプション)。
%
% 出力:
% -------
%  SYSK   -  H∞ループ整形コントローラ
%  EMAX   -  非構造的摂動に関するロバスト性の指標としての安定余裕。EMAX
%            は、必ず1より小さく、0.3よりも小さいEMAXの値は、通常良いロ
%            バスト性を示します。
%  SYSOBS -  H∞ループ整形オブザーバコントローラ。この変数は、FACTOR>1で
%            OPT = 'ref'のときのみ作成されます。
%
% 参考: HINFNORM, HINFSYN, NUGAP



% $Revision: 1.8.2.2 $
%   Copyright 1991-2002 MUSYN Inc. and The MathWorks, Inc. 
