% PRINTSYS   分かり易い(pretty)フォーマットでシステムを印刷
% 
% PRINTSYS は、状態空間システムの場合、左側と上側にラベルを付け、伝達関数
% の場合、二つの多項式の比として印刷します。
%
% PRINTSYS(A,B,C,D,ULABELS,YLABELS,XLABELS) は、文字列 ULABELS, YLABELS,
% XLABELS に含まれる入力、出力、状態に関するラベルを使って、状態空間シス
% テムを印刷します。ULABELS, YLABELS, XLABELS は、スペースで区切って、
% 入力、出力、状態のラベルを含む文字列変数です。たとえば、ラベル文字列
% 
%    YLABELS = ['Phi Theta Psi']
% 
% は、最初の出力に'Phi'、二番目の出力に'Theta'、三番目の出力に'Psi'を
% 付けます。
% 
% PRINTSYS(A,B,C,D) は、数値ラベルを使って、システムに印刷することができ
% ます。
% 
% PRINTSYS(NUM,DEN,'s')、または、PRINTSYS(NUM,DEN,'z') は、変換変数's'、
% または。'z'で、2つの多項式の比として伝達関数を印刷します。
%
% 参考 : PRINTMAT, POLY2STR.


%   Clay M. Thompson  7-23-90
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2003/06/26 16:08:20 $
