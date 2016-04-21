% FUZARITH ファジィ代数
% 
% C = FUZARITH(X,A,B,OPERATOR) は、領域 X のファジィ集合 A と B に、OP-
% ERATOR を適用した結果としてファジィ集合 C を出力します。A、B および 
% X は、同次元のベクトルでなければなりません。OPERATOR は、文字列 'sum'
% 'sub'、'prod'、'div' の中の1つでなければなりません。出力されるファジィ
% 集合 C は、A と B と長さが同じである列ベクトルです。この関数では、区間
% での演算を使用することと、つぎのことを想定していることに注意してくださ
% い。
% 
% 1.A と B は、凸ファジィ集合です。
% 
% 2.X の範囲の外で、A と B のメンバシップ階級は0です。
%
% ファジィ加算は、"divide by zero"メッセージを作成します。しかしながら、
% この関数の精度に影響はありません(ただし、VAX や Cray などの IEEE 演算
% を使っていないマシンでは問題が生ずる場合があります)。
%
% 例題
%    point_n = 101;                      MFの解像度を決定
%    min_x = -20; max_x = 20;            領域 [min_x,max_x]
%    x = linspace(min_x,max_x,point_n)';
%    A = trapmf(x,[-10 -2 1 3]);        Aは台形ファジィ集合
%    B = gaussmf(x,[2 5]);              Bはガウスファジィ集合
%    C1 = fuzarith(x,A,B,'sum');
%    subplot(2,2,1);
%    plot(x,A,'y--',x,B,'m:',x,C1,'c');
%    title('fuzzy addition A+B');
%    C2 = fuzarith(x,A,B,'sub');
%    subplot(2,2,2);
%    plot(x,A,'y--',x,B,'m:',x,C2,'c');
%    title('fuzzy subtraction A-B');
%    C3 = fuzarith(x,A,B,'prod');
%    subplot(2,2,3);
%    plot(x,A,'y--',x,B,'m:',x,C3,'c');
%    title('fuzzy multiplication A*B');
%    C4 = fuzarith(x,A、B,'div');
%    subplot(2,2,4);
%    plot(x,A,'y--'.x.B.'m:'.x、C4,'c');
%    title('fuzzy division A/B');



%	Copyright 1994-2002 The MathWorks, Inc. 
