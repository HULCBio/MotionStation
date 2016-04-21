% COL2IM    行列の列をブロックに再配列
% A = COL2IM(B,[M N],[MM NN],'distinct') は、B のそれぞれの列を、大きさ 
% MM 行 NN 列の行列 A を作成するため、重なりのない M 行 N 列のブロックに
% 再配列します。B = [A11(:) A12(:);A21(:) A22(:)] で、各列が長さ M*N の
% 場合、A = [A11 A12;A21 A22] になります。ここで、Aij は、M 行 N 列の行
% 列です。
% 
% A = COL2IM(B,[M N],[MM NN],'sliding') は、行ベクトル B を大きさ(MM-M+1)
% 行(NN-N+1)列の行列に再配列します。B は、大きさ1行(MM-M+1)*(NN-N+1)列の
% ベクトルでなければなりません。通常、B は、列を圧縮する関数(たとえば、SUM)を使う IM2COL(...,'sliding') の出力の処理結果になります。
% 
% COL2IM(B,[M N],[MM NN]) は、COL2IM(B,[M N],[MM NN],'sliding') と同じで
% す。
% 
% クラスサポート
% -------------
% B は、logical か数値です。A はBと同じクラスです。
% 
% 参考：BLKPROC, COLFILT, IM2COL, NLFILTER.



%   Copyright 1993-2002 The MathWorks, Inc.  
