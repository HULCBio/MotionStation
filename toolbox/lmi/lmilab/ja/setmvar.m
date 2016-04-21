%% newsys = setmvar(lmisys,k,X)
%
% K番目の行列変数XkをXに設定し、Xkに関するすべてのLMI項を計算します。定
% 数項は、それに応じて更新されます。
%
% 便宜上、KをLMIVARで出力される識別子に設定します。SETMVARは、変数の識別
% 子を変更しないので、残っている行列変数は、元の識別子によって参照されま
% す。
%
% 入力:
%   LMISYS       連立LMIを記述する配列。
%   K	         Xに設定される変数行列の識別子。
%   X            Xkに割り当てられた行列の値(スカラtは、t*Iとして解釈され
%                ます)。
% 出力:
%   NEWSYS       連立LMIの更新された記述。
%
% 参考：    LMIVAR, DELMVAR.



% Copyright 1995-2002 The MathWorks, Inc. 
