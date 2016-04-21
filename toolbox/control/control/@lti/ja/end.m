% END   LTIオブジェクトに対し、オーバロードされた END を作成
%
% END(SYS,POSITION,NUMINDICES) は、LTIモデル、または、LTI配列 SYS の
% 次元 POSITION に従って、最後の要素に対するインデックスを出力します。
% NUMINDICES は、インデックスの表示に利用されるインデックスの番号です。
%
% たとえば、
%   SYS(end,1)   最初の入力から最後の出力までのサブシステムの抽出。
%   SYS(1,1,end) LTI配列 SYS の最後のモデルの最初の入力から最初の出力
%                までのサブシステムの抽出。
%
% LTI配列を拡大するために END を利用した場合、つぎのようになり、
% 
%   SYS(:,:,end+1) = RHS
% 
% は、SYS の存在を最初に確認します。
%
% 参考 : SUBSREF, SUBSASGN.


%   Author(s): S. Almy, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
