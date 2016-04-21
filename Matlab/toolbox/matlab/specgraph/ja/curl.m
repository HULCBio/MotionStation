% CURL ベクトル場のCurlと角速度ベクトルを出力します。
% 
% [CURLX, CURLY, CURLZ, CAV] = CURL(X,Y,Z,U,V,W) は、3次元ベクトル場、
% U,V,W の流れ(単位時間あたりのラジアン)に直交するCurlと角速度ベクトル
% を計算します。配列 X,Y,Z は、U,V,W に対する座標を定義し、単調で、
% (MESHGRID で作成するように)3次元格子でなければなりません。
% 
% [CURLX, CURLY, CURLZ, CAV] = CURL(U,V,W) は、つぎのステートメントを
% 仮定しています。
% 
%         [X Y Z] = meshgrid(1:N, 1:M, 1:P) 
% 
% ここで、[M,N,P] = SIZE(U) です。 
%
% [CURLZ, CAV] =  CURL(X,Y,U,V) は、2次元ベクトル場 U,V の z に直交する
% 角速度ベクトルとCurl z 成分を計算します。配列 X,Y は、U,V に対する座標
% を定義し、単調で、(MESHGRID で作成するように)2次元格子でなければなり
% ません。
% 
% [CURLZ, CAV] = CURL(U,V) は、つぎのステートメントを仮定しています。
% 
%         [X Y] = meshgrid(1:N, 1:M) 
% 
% ここで、[M,N] = SIZE(U) です。 
% 
% [CURLX, CURLY, CURLZ] = CURL(...) または [CURLX, CURLY] = CURL(...) 
% は、Curl のみを出力します。
% 
%   CAV = CURL(...) は、curl 角速度のみを出力します。
%   
% 例題 1:
%      load wind
%      cav = curl(x,y,z,u,v,w);
%      slice(x,y,z,cav,[90 134],[59],[0]); shading interp
%      daspect([1 1 1])
%      camlight
%
% 例題 2:
%      load wind
%      k = 4; 
%      x = x(:,:,k); y = y(:,:,k); u = u(:,:,k); v = v(:,:,k); 
%      cav = curl(x,y,u,v);
%      pcolor(x,y,cav); shading interp
%      hold on; quiver(x,y,u,v)
%
% 参考：STREAMRIBBON, DIVERGENCE.


%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.7.4.1 $  $Date: 2004/04/28 02:04:52 $
