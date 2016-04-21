% SAVEOBJ   オブジェクトのフィルタを保存
%
% B = SAVEOBJ(A) は、オブジェクトが、.MAT ファイルとして保存された場合、
% SAVE によって呼び出されます。出力値 B は、.MATファイルに populate 
% するために、SAVE によって、引き続き使われます。SAVEOBJ は、保存形式
% 内にオブジェクト配列の外側の情報を保持して、オブジェクトを変換する
% ために使うことができます。(ゆえに、再度作成するために、LOADOBJ が
% 引き続き呼ばれます。)
%
% SAVEOBJ は、各オブジェクトを保存するために、別々に呼び出されます。
%
% SAVEOBJ は、ユーザのオブジェクトのみオーバーロードすることができます。
% SAVE は、@double/saveobj が存在しても、(double のような) 組み込みの
% データタイプに対して、SAVEOBJ を呼び出しません。
%
% 参考:  SAVE, LOADOBJ.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.9.4.1 $  $Date: 2004/04/28 01:47:47 $
