% BVPINIT  BVP4C用の初期推定を行います。
% 
% SOLINIT = BVPINIT(X,YINIT)は、一般的な環境で、BVP4C用の初期推定を行い
% ます。BVPは、区間[a,b]で解かれます。ベクトルXは、X(1) = a, X(end) = b
% のようにaとbを指定します。適切なメッシュに対する推定にもなります。BVP4C
% は、このメッシュを解法に使います。それで、x = logspace(a,b,10)のような
% 推定でも十分ですが、複雑な場合は、メッシュ点は、解が急激に変化する場所
% に設定しなければなりません。
%
% X は昇順である必要があります。2点 BVP においては、X の要素は区別され、
% a < b の場合、X(1) < X(2) < ... < X(end)のように順序付けられている必要
% があります。多点 BVP の場合は、[a,b] においていくつかの境界条件があります。
% 一般的に、これらの点はインタフェースを表わし、[a,b] 領域において自然に
% 分割されます。BVPINIT は領域に対して左から右( a から b)に与えられ、
% インデックスは 1 からスタートします。インタフェースは初期メッシュ X の
% ダブルエントリーで指定できます。BVPINIT は、1つめのエントリーを領域 k 
% の右終点、他方を領域 k+1 の左終点として解釈します。THREEBVP は、3点 BVP 
% の例題です。
% 
% YINITは、解に対する推定です。この推定に対して、微分方程式と境界条件を
% 計算することができなければなりません。YINITは、ベクトル、または、関数
% のいずれかでも構いません。
% 
% ベクトル：YINIT(i)は、X内のすべてのメッシュ点での解のi番目の要素Y(i,:)
% の定数推定です。
%
% 関数: YINIT は、スカラ x の関数です。たとえば、区間 [a,b] の任意
%       の値 x に対して、yfun(x) が、解 y(x)に対する推定を戻す場合
%       solinit = bvpinit(x,@yfun) を使います。
%     
% SOLINIT = BVPINIT(X,YINIT,PARAMETERS) は、BVP が未知パラメータを含むこ
% とを意味しています。推定は、ベクトル PARAMETERS の中のすべてのパラメー
% タに対して用意されます。
%
% SOLINIT = BVPINIT(X,YINIT,PARAMETERS,P1,P2...) は、付加的な既知パラメー
% タ P1,P2,... を YINIT(X,P1,P2...) として、推定関数に渡します。 
% 未知パラメータが存在する場合、SOLINIT = BVPINIT(X,YINIT,[],P1,P2...) を
% 使います。パラメータ P1,P2,... は、YINIT が関数の場合にのみ使われます。 
% 
% SOLINIT = BVPINIT(SOL,[ANEW BNEW]) は、区間[a,b]上の解 SOL から、区間
% [ANNEW,BNEW]上での初期推定を作成します。新しい区間は、より広くなけれ
% ばなりません。すなわち、ANEW <= a < b <= BNEW、または、
% ANEW >= a > b >= BNEW のどちらかを満たす必要があります。
% 解SOLは、新しい区間に外挿されます。存在する場合は、SOL から PARAMETERS
% は、 SOLINIT を使います。
% 
% SOLINIT = BVPINIT(SOL,[ANEW BNEW],PARAMETERS) は、上で記述した SOLINIT 
% を作成します。しかし、未知のパラメータに関しては、推定値としてPARAMETERS
% を使います。
%
% 参考：BVPGET, BVPSET, BVP4C, DEVAL, @

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2003 The MathWorks, Inc. 
