% MAXFLAT は、できる限り平坦な汎用ディジタルButterworthフィルタを設計し
% ます。
%
% [B,A] = MAXFLAT(NB,NA,Wn)は、それぞれ、次数NBおよびNAの分子係数Bおよび
% 分母係数AをもつローパスButterworthフィルタを設計します。Wnはカットオフ
% 周波数で、その周波数で、フィルタのゲイン応答が 1/sqrt(2)(約 -3dB)とな
% ります。Wnは0と1の間で、1はフィルタのサンプリング周波数の1/2です。NAが
% 0の場合、フィルタの周波数応答を平滑化するために、Wnの範囲は、かなり制
% 限されます。
%
% B = MAXFLAT(NB,'sym',Wn)は、対称FIR Butterworthフィルタを設計します。
% NBは偶数で、Wnは[0,1]に制限されます。Wnが、この区間の外に設定された場
% 合、関数はエラーになります。
%
% [B,A,B1,B2] = MAXFLAT(NB,NA,Wn) や [B,A,B1,B2] = MAXFLAT(NB,'sym',Wn) 
% は、分子多項式Bを多項式 B1 と B2 の積(B = CONV(B1,B2))になるように分解
% した多項式を出力します。B1 は z = -1 でのすべての零点を含み、B2 は他の
% 零点を含みます。
%
% 例題 1: IIR 設計
%      NB = 10; NA = 2; Wn = 0.6;
%      [b,a,b1,b2] = maxflat(NB,NA,Wn);
%      fvtool(b,a);
% 例題 2: FIR 設計
%      NB = 10; Wn = 0.6;
%      h = maxflat(NB,'sym',Wn); 
%      fvtool(h);
%
% 設計のモニタリング
% 設計で使用されている設計テーブルのテキスト表示用に、たとえば、MAXFLAT
% (NB,NA,Wn,'trace') のように、最後に 'trace' 引数を付けて使用します。フ
% ィルタの大きさ、遅延、零点、極をプロット表示するため、'plot' 引数で、
% MAXFLAT(NB,NA,Wn,'plot') を使います。テキスト表示とプロット表示を共に
% 使いたい場合、'both' を設定してください。
%
% 参考：   BUTTER, FREQZ, FILTER.



%   Author: Ivan Selesnick, Rice University, September 1995.
%   Copyright 1988-2002 The MathWorks, Inc.
