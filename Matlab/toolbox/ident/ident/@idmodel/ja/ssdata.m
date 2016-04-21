% IDMODEL/SSDATA   IDMODEL モデルに対する状態空間行列を出力します。
%
%   [A,B,C,D,K,X0] = SSDATA(M)
%
% M は、モデルのサンプリング時間 Ts に依存する連続、または離散時間の 

%   $Revision: 1.1 $  $Date: 2003/04/18 17:08:43 $
5 IDPOLY、IDARX、IDSS および IDGREY のような任意の IDMODEL オブジェクト
% です。
%
%     x[k+1] = A x[k] + B u[k] + K e[k] ;      x[0] = X0
%     y[k] = C x[k] + D u[k] + e[k]
%
% [A,B,C,D,K,X0,dA,dB,dC,dD,dK,dX0] = SSDATA(M) は、モデルの不確かさ
% (標準偏差) dA も返します。
% 
% M が時系列の(入力がない)場合、B と D は空行列として返されます。この
% ときノイズ源 e は、出力となることに注意してください。ノイズ源を通常
% の入力に変換するには、単位あたりの分散を正規化するためのオプションを
% 用いて、M = NOISECNV(M,noise) を使用してください。
%
% 参考: NOISECNV, TFDATA, ZPKDATA.

  
   