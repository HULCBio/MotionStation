% FINDROW 入力文字列に一致する行列の行の検索
% 
% ROWNUM = FINDROW(STR,STRMAT) は、行列 STRMAT の行でベクトル STR と一致
% する行列STRMAT の1つ、または、複数の行へのインデックスを出力します。ブ
% ランク(ASCII 32)と0については考慮しません。一致するものがない場合には
% 空行列を出力します。
%
% 例題:
%    strMat = fstrvcat('one','fish','two','fish',[1 2 3 4 5 6]);
%    rowNum = findrow('fish',strMat)



%   Copyright 1994-2002 The MathWorks, Inc. 
