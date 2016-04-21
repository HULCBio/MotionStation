% PERMUTE   配列の次元を並べ替え
%
% B = PERMUTE(A,ORDER) は、A の次元を並べ替え、ベクトル ORDER によって
% 指定される順番にします。任意の特定の要素にアクセスするのに必要な定期
% 的な順序は、ORDER によって指定された並びに替えられますが、配列は、A
% と同じ値をもつよう生成されます。ORDER の要素は、1からNの数の並べ替え
% でなければなりません。
%
% PERMUTE と IPERMUTE は、N次元の配列に対して、転置 (.') の一般化した
% ものを生成します。
%
% 例題
%      a = rand(1,2,3,4);
%      size(permute(a,[3 2 1 4])) % 3×2×1×4の大きさになります。
%
% 参考:  IPERMUTE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.1.4.1 $  $Date: 2004/04/28 01:51:39 $
%   Built-in function.
