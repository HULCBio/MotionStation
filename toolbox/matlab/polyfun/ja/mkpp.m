%MKPP 区分多項式を作成
% PP = MKPP(BREAKS,COEFS) は、節点と係数から区分多項式 PP を作成します。
% BREAKS は、区間 L の出発点と終了点を表わす要素を含む長さ L+1 のベクトル
% です。行列 COEFS は、L×K でなければなりません。第i行、COEFS(i,:) が、
% 区間 [BREAKS(i) ... BREAKS(i+1)] での K 次多項式のローカルな係数を表わす、
% すなわち、多項式                 
%   COEFS(i,1)*(X-BREAKS(i))^(K-1) + COEFS(i,2)*(X-BREAKS(i))^(K-2) + ... 
%   COEFS(i,K-1)*(X-BREAKS(i)) + COEFS(i,K) です。
% 注意: K 次の多項式は、 つぎのように K 個の係数を使用して記述します。
%      C(1)*X^(K-1) + C(2)*X^(K-2) + ... + C(K-1)*X + C(K)
% 従って、次数は K より小さくなります。たとえば、キュービック多項式は、通常、
% 4 要素をもつベクトルとしてかかれます。
%
% PP = MKPP(BREAKS,COEFS,D) は、区分多項式 PP がD-ベクトル値であることを
% 意味しています。D は、スカラーまたは整数ベクトルのいずれかです。BREAKS は、
% 長さ L+1 のベクトルで、要素値は、順次増加します。COEFS のサイズが何で
% あっても、その最後の次元は、多項式の次数 K にとられます。そのため、残りの
% 次元の積は、prod(D)*L になる必要があります。
% COEFS をサイズ [prod(D),L,K] とすると、COEFS(r,i,:) は、i番目の区分の
% 多項式の r 番目の要素の K 係数です。内部的には、COEFS は、サイズ 
% [prod(D)*L,K] の行列として保存されます。
%
% 例題:
% つぎの最初の2つのプロットは、二次式 1-(x/2-1)^2 = -x^2/4 + x が
% 区間 [-2 .. 2] から区間 [-8 .. -4] にシフトし、その多項式の負、
% すなわち、二次式 (x/2-1)^2-1 = x^2/4 - x は、[-2 .. 2] から区間 
% [-4 .. 0] へシフトします。
%      subplot(2,2,1)
%      cc = [-1/4 1 0];
%      pp1 = mkpp([-8 -4],cc); xx1 = -8:0.1:-4;
%      plot(xx1,ppval(pp1,xx1),'k-')
%      subplot(2,2,2)
%      pp2 = mkpp([-4 -0],-cc); xx2 = -4:0.1:0;
%      plot(xx2,ppval(pp2,xx2),'k-')
%      subplot(2,1,2)
%      pp = mkpp([-8 -4 0 4 8],[cc; -cc; cc; -cc]);
%      xx = -8:0.1:8;
%      plot(xx,ppval(pp,xx),'k-')
%      [breaks,coefs,l,k,d] = unmkpp(pp);
%      dpp = mkpp(breaks,repmat(k-1:-1:1,d*l,1).*coefs(:,1:k-1),d);
%      hold on, plot(xx,ppval(dpp,xx),'r-'), hold off
% 最後のプロットは、4区間に渡って、最初の2つの二次式を変更させて作成した
% 区分多項式をプロットします。区分多項式の特性を強調するために、UNMKPP に
% より得られた区分多項式についての情報から構成されるように、1階導関数も
% 示されています。
%
% 入力 BREAKS,COEFS のサポートクラス
%      float: double, single
%
% 参考 UNMKPP, PPVAL, SPLINE.

%   Carl de Boor 7-2-86
%   Copyright 1984-2004 The MathWorks, Inc.
