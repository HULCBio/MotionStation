%ODEXTEND  微分方程式の初期値問題の解を拡張します
% 
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL) は、SOL にストアされた解を区間
% [SOL.x(1), TFINAL] まで拡張します。SOL は、ODE ソルバで生成された
% ODEの解の構造体です。関数 ODEFUN(T,Y) は、導関数を評価します。
% ODEXTEND は、SOL を生成したのと同じODEソルバを使用して、問題を
% SOL.x(end) からTFINALまで積分することにより解を拡張します。
% デフォルトでは、ODEXTEND は、 続く積分の初期条件として
% SOL.y(:,end)を使用します。SOL の計算に使用される、導関数、積分の
% 特性、追加の入力引数は、その解の構造体の一部にストアされます。
% これらの値が変らない場合、ODEXTEND　に渡される必要はありません。
% SOL.x(1) と TFINAL の間の任意の点で拡張された解を評価するためには、
% DEVAL と SOLEXT を使用してください。 
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT) は、上記のように
% 解きます。SOL.X(end) での新しい初期条件として、列ベクトル
% YINIT を使用して、ODE15Iを使用して得られた解を拡張するためには、
% シンタックス SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,[YINIT,YPINIT]) 
% を使用してください。ここで、列ベクトル YPINIT は、解の初期の
% 導関数です。
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT,OPTIONS) は、OPTIONS に
% 指定された積分特性を使用して、SOL の計算に使用された値を置き換え、
% 上記のように解きます。OPTIONS プロパティの設定についての詳細は、
% ODESET を参照してください。新しい YINIT が設定されていない場合、
% プレースホルダとしてYINIT = [] を使用してください。
%
% SOLEXT = ODEXTEND(SOL,ODEFUN,TFINAL,YINIT,OPTIONS,P1,P2...)  は、
% 追加のパラメータP1,P2,... をODEFUN(T,Y,P1,P2...) として、ODE 関数と、
% OPTIONS に指定されたすべての関数に渡します。追加のパラメータ
% は、SOL の計算に使用された値と異なる場合に限り、指定してください。
% オプションが設定されていない場合、プレースホルダとして 、
% OPTIONS = [] を使用してください。
%
% 例題
%      sol=ode45(@vdp1,[0 10],[2 0]); 
%      sol=odextend(sol,@vdp1,20); 
%      plot(sol.x,sol.y(1,:));
% この例では、区間 [0 10] でシステム y' = vdp1(t,y) を解くために、
% ODE45 を使用します。その後、解を [0 20] まで拡張し、その最初の要素を
% プロットします。
%
% 参考
% ODE ソルバ: ODE23, ODE45, ODE113, ODE15S, 
%             ODE23S, ODE23T, ODE23TB
% インプリシット ODE ソルバ: ODE15I
% オプションハンドリング: ODESET, ODEGET
% 解の評価: DEVAL

%   Jacek Kierzenka
%   Copyright 1984-2003 The MathWorks, Inc. 
