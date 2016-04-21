% BIORINFO 　双直交スプラインウェーブレットに関する情報
%
% 双直交ウェーブレット
%
% 一般的特性: 
% FIR フィルタによる対称性かつ厳密な意味での再構成が可能なコンパクト
% サポートされたスプラインウェーブレットです(Haar 以外の直交の場合は、
% 再構成できません)。
%
%    ファミリ　              Biorthogonal
%    略称                    bior
%    次数  Nr,Nd             Nr = 1 、Nd = 1、3、5
%    再構成に関する r        Nr = 2 、Nd = 2、4、6、8
%    分解に関する d          Nr = 3 、Nd = 1、3、5、7、9
%                            Nr = 4 、Nd = 4
%                            Nr = 5 、Nd = 5
%                            Nr = 6 、Nd = 8
%
% 例題                    bior3.1、bior5.5
%
%    直交性                  なし
%    双直交性 　             あり
%    コンパクトサポート      あり
%    離散ウェーブレット変換　可
%    連続ウェーブレット変換  可
%
%    サポート長     　　     再構成に対して、2Nr+1 ：分解に対して、2Nd+1
%    フィルタの長さ        max(2Nr,2Nd)+2 ですが、効率的なもの
%    bior Nr.Nd              ld                      lr    
%                         LoF_D の有効長          HiF_D の有効長
%
%    bior 1.1                 2                       2  
%    bior 1.3                 5                       2
%    bior 1.5                10                       2
%    bior 2.2                 5                       3
%    bior 2.4                 9                       3
%    bior 2.6                13                       3
%    bior 2.8                17                       3
%    bior 3.1                 4                       4
%    bior 3.3                 8                       4
%    bior 3.5                11                       4
%    bior 3.7                16                       4
%    bior 3.9                20                       4
%    bior 4.4                 8                       7
%    bior 5.5                 9                      11
%    bior 6.8                17                      11
%
%    psi rec に対する
%    レギュラリティ              節点で、Nr-1 と Nr-2 
%    対称性                      あり  
%    psi dec に対するモーメント　Nr
%
% 注意: 
% bior 4.4 、5.5 及び 6.8 は、互いに再構成、分解関数及びフィルタが
% 近似しています 。          
%
% 参考文献: I. Daubechies, 
%           Ten lectures on wavelets, 
%           CBMS, SIAM, 61, 1994, 271-280.
%
% 逆双直交スプラインウェーブレットに関する情報を参照してください。


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 12-Mar-96.
%   Copyright 1995-2002 The MathWorks, Inc.
