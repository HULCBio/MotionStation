% LTIVIEW LTI   Viewerをオープン
%
%
% LTIVIEW は、空の LTI Viewer をオープンします。
% LTI Viewer は、線形モデル群の時間応答、または、周波数応答を解析したり、比較
% したりする対話型のグラフィカルユーザインタフェース(GUI)です。Control System
% Toolbox内での線形モデルの使い方の詳細は、LTIMODELS を参照してください。
%
% LTIVIEW(SYS1,SYS2,...,SYSN) は、LTI モデル SYS1,SYS2,...,SYSN のステップ
% 応答を含む、LTI Viewer を開きます。つぎのように、カラー、ラインスタイル、
% マーカを各システム毎に指定することができます。 
%   sys1 = rss(3,2,2); 
%   sys2 = rss(4,2,2); 
%   ltiview(sys1,'r-*',sys2,'m--');
%
% LTIVIEW(PLOTTYPE,SYS1,SYS2,...,SYSN) では、LTI Viewer のプロットにさらに
% 指定をすることができます。PLOTTYPE　には、つぎの文字列（または、その組合せ）
% が入力できます。 
% 1) 'step'           Step 応答
% 2) 'impulse'        Impulse 応答
% 3) 'bode'           Bode 線図
% 4) 'bodemag'        Bode 線図の大きさの応答のみ表示
% 5) 'nyquist'        Nyquist線図
% 6) 'nichols'        Nichols線図t
% 7) 'sigma'          特異値プロット
% 8) 'pzmap'          極/零点図
% 9) 'iopzmap'        I/O 極/零点図
%
% たとえば、 
%   ltiview({'step';'bode'},sys1,sys2) 
% は、LTIモデル SYS1 と SYS2 の stepとBode応答を示す LTI Viewer を開きます。
%
% LTIVIEW(PLOTTYPE,SYS,EXTRAS) は、様々な応答タイプによってサポートされている
% 付加的な入力引数を指定することができます。これらの付加的な引数の形式の詳細
% については、各応答タイプに対して、HELP テキストを参照してください。LTI Viewer
% の LSIM または INITIAL の出力プロットで下記のシンタックスを利用することが
% できます。
%   ltiview('lsim',sys1,sys2,u,t,x0)
%
% 2つの付加的なオプションは、あらかじめ起動した LTI Viewer を操作するために
% 利用可能です。
%
% LTIVIEW('clear',VIEWERS) は、ハンドル VIEWERS をもつ LTI Viewer から
% プロットやデータを消去します。
%
% LTIVIEW('current',SYS1,SYS2,...,SYSN,VIEWERS) は、システム SYS1,SYS2,...
% の応答をハンドル番号 VIEWERS をもつ LTI Viewer に付加します。
%
% 参考 : STEP, IMPULSE, LSIM, INITIAL, (IO)PZMAP,


% Copyright 1986-2002 The MathWorks, Inc.
