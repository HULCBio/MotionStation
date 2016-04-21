% SPCOL B-スプライン選点行列
%
% COLLOC = SPCOL(KNOTS,K,TAU) は、行列
%
%      [ D^m(i)B_j(TAU(i)) : i=1:length(TAU), j=1:length(KNOTS)-K ] ,
%
% です。ここで、D^m(i)B_j は B_j のm(i)次微分、B_j は、節点列 KNOTS に
% 対する次数 K のj番目のB-スプライン、TAU はサイトの列です。KNOTS と 
% TAU は、共に非減少であると仮定します。
% さらに、m(i) は、整数 #{ j<i : TAU(j) = TAU(i) }、即ち TAU における 
% TAU(i) の累積多重度です。
%
% これは、COLLOC の第j列が、列 KNOTS に対する次数 K のB-スプラインの
% j番目、すなわち、節点を KNOTS(j:j+K) とするB-スプラインのベクトル 
% TAU のすべての要素における値と、ことによると微分を含むことを意味します。
% COLLOC のi番目の行は、これらのB-スプラインすべてのm(i)次微分の TAU(i) 
% での値を含みます。ここで、m(i) は、TAU(i) に等しい TAU の前の要素の数
% です。
%
% 例題:
%  tau = [0,0,0,1,1,2];          % 従って、m は [0,1,2,0,1,0] に等しく
%                                % なります。
%  k = 3; knots = augknt(0:2,k); % 従って、knots は [0,0,0,1,2,2,2] に
%  colloc = spcol(knots,k,tau)   % 等しくなります。
%
% ここで、COLLOC(:,j)  の6つの要素が含むのは、0での B_j の値と、1次、
% 2次微分、それから、1での B_j の値と1次微分、最後に2での B_j の値です。
% ここで B_j は、節点列 knots に対するk次のB-スプラインのj番目で、たと
% えば、B_2 は、knots を B_j を 0,0,1,2 とするB-スプラインです。
%
% 指定した値と、場合によっては、指定したサイトでのいくつかの微分をもつ
% スプラインを作成するために COLLOC を使用することができます。
% 
% 例題:
%      a = -pi; b = pi;  tau = [a a a 0 b b]; k = 5;
%      knots = augknt([a,0,b],k);
%      sp = spmak(knots, ( spcol(knots,k,tau) \ ...
%          [sin(a);cos(a);-sin(a);sin(0);sin(b);cos(b)] ).' )
%
% は、0でちょうど1つの内部節点をもつ区間 [a,b] 上での2次のスプラインを
% 与えます。このスプラインは a,0,b において、正弦関数を補間し、また、a に
% おいて1次および2次微分を、そして b において1次微分を一致させます。
%
% COLLOC = SPCOL(KNOTS,K,TAU,ARG1,ARG2,...) は、オプションの引数 ARG1, 
% ARG2, ... に依存する、同じかあるいは関連する行列を与えます。
%
% オプション引数の1つが 'slvblk' の場合、COLLOC は、SLVBLK で必要とされる
% (スプラインに対して指定された)ほぼブロック対角な形式です。
%
% オプション引数の1つが 'sparse' の場合、COLLOC は、スパース行列です。
%
% オプション引数の1つが 'noderiv' の場合、多重度は無視されます。すなわち、
% すべての i に対して m(i) = 0 です。
%
% B-スプラインの漸化式は、行列の要素を生成するために使用されます。
%
% 例題:
%      t = [0,1,1,3,4,6,6,6]; x = linspace(t(1),t(end),101); 
%      c = spcol(t,3,x); plot(x,c)
%
% は、与えられた節点列 t に対してj番目の2次のB-スプラインの値の適切な列を
% c(:,j) に生成するために SPCOL を使用します。
%
% 参考 : SLVBLK, SPARSE, SPAPI, SPAP2, BSPLINE.


%   Copyright 1987-2003 C. de Boor and The MathWorks, Inc.
