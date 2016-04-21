% DSPFDES   DSP Blockset のフィルタ設計インタフェース
%
% 使用法：
%    [a,b,c,d,h,w,s]=dspfdes(method,type,N,Wlo,Whi,Rp,Rs,Ts);
% ここで、
% a,b,c,d: フィルタの状態空間係数で、古典的なFIRに対して、b のみ空では
%          ありません。
%       h: 希望するフィルタの周波数応答(アイコン表示用のみ)
%       w: h のインデックスに対応する正規化された周波数(アイコン表示のみ)
%       s: 読み込まれる設計関数名(アイコン表示のみ)
%
% Ts が渡されない場合、アナログフィルタが設計されます。


% Copyright 1995-2002 The MathWorks, Inc.
% $Revision: 1.6.6.1 $ $Date: 2003/07/22 21:03:37 $
