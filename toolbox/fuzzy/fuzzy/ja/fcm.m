% FCM ファジィc-means クラスタリングによるデータセットのクラスタリング
%
% [CENTER, U, OBJ_FCN] = FCM(DATA, N_CLUSTER) は、データセットDATAから
% N_CLUSTER個のクラスタを検索します。DATAはM行N列のサイズの場合、Mは
% データポイント数、Nは各データポイントの座標数になります。各クラスター
% センタの座標は、CENTER行列の列に出力されます。メンバシップ関数行列Uは
% 各クラスタの各データポイントのメンバシップのグレードを含みます。
% 0と1の値は、ノーメンバシップ、フルメンバシップを意味します。グレードは
% 0から1の間の値で、データポイントがクラスタ内に部分メンバシップを持つかを
% 示します。各繰り返しにおいて、目的関数を最小にする最適なクラスタ位置を
% 検索します。結果はOBJ_FCNに出力されます。
% 
% [CENTER, ...] = FCM(DATA,N_CLUSTER,OPTIONS) はクラスタリングプロセス
% のオプションベクトルを指定します。
% OPTIONS(1) : 分割行列Uに対するベキ数(デフォルト: 2.0)
% OPTIONS(2) : 繰り返しの最大回数(デフォルト: 100)
% OPTIONS(3) : 改良度による終了基準値(デフォルト: 1e-5)
% OPTIONS(4) : 繰り返し回数の表示(デフォルト: 1)
% クラスタリングプロセスは、繰り返しの最大回数に到達した時点、または目的
% 関数の改善が改良度による終了基準値で指定した値より小さい場合終了します。
% デフォルト値の利用にはNaNを利用します。
% 
% 例
%       data = rand(100,2);
%       [center,U,obj_fcn] = fcm(data,2);
%       plot(data(:,1), data(:,2),'o');
%       hold on;
%       maxU = max(U);
%       % Find the data points with highest grade of membership in cluster 1
%       index1 = find(U(1,:) == maxU);
%       % Find the data points with highest grade of membership in cluster 2
%       index2 = find(U(2,:) == maxU);
%       line(data(index1,1),data(index1,2),'marker','*','color','g');
%       line(data(index2,1),data(index2,2),'marker','*','color','r');
%       % Plot the cluster centers
%       plot([center([1 2],1)],[center([1 2],2)],'*','color','k')
%       hold off;
%
% 参考    FCMDEMO, INITFCM, IRISFCM, DISTFCM, STEPFCM.



%   Copyright 1994-2002 The MathWorks, Inc. 
