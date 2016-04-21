% RBIOINFO 　逆双直交スプラインウェーブレットに関する情報
%
% 逆双直交ウェーブレット
%
% 一般的特性: 
% FIR フィルタによる対称的かつ厳密な意味で再構成が可能なコンパクト
% サポートされた双直交スプラインウェーブレットです(Haar を除く直交
% ウェーブレットの場合は再構成できません)。
%
% ファミリ　              Biorthogonal
% 略称                    rbio
% 次数  Nd,Nr             Nd = 1 、Nr = 1、3、5
% 再構成に関する r        Nd = 2 、Nr = 2、4、6、8
% 分解に関する d          Nd = 3 、Nr = 1、3、5、7、9
%                         Nd = 4 、Nr = 4
%                         Nd = 5 、Nr = 5
%                         Nd = 6 、Nr = 8
%
% 例題                    rbio3.1、rbio5.5
%
% 直交性                  なし
% 双直交性                あり
% コンパクトサポート      あり
% 離散ウェーブレット変換  可
% 連続ウェーブレット変換  可
%
% サポート長     　　     再構成に対して、2Nr+1 ：分解に対して、2Nd+1
% フィルタの長さ        max(2Nr,2Nd)+2 ですが、効率的なもの
% bior Nr.Nd              ld                      lr    
%                       LoF_D の有効長          HiF_D の有効長
%
% rbio 1.1                 2                       2
% rbio 1.3                 5                       2
% rbio 1.5                10                       2
% rbio 2.2                 5                       3
% rbio 2.4                 9                       3
% rbio 2.6                13                       3
% rbio 2.8                17                       3
% rbio 3.1                 4                       4
% rbio 3.3                 8                       4
% rbio 3.5                11                       4
% rbio 3.7                16                       4
% rbio 3.9                20                       4
% rbio 4.4                 8                       7
% rbio 5.5                 9                      11
% rbio 6.8                17                      11
%
% psi recに関する
% レギュラリティ          ノットで、Nd-1 と Nd-2 
% 対称性                  あり  
% psi decに関すモーメント Nd
%
% 注意: 
% rbio 4.4 、5.5 及び 6.8 は、互いに再構成、分解関数及びフィルタの値が
% 各々接近しています。
%
% 参考文献： I. Daubechies, 
%            Ten lectures on wavelets, 
%            CBMS, SIAM, 61, 1994, 271-280.
%
% 双直交スプラインウェーブレットに関する情報を参照してください。


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-1998.
%   Copyright 1995-2002 The MathWorks, Inc.
