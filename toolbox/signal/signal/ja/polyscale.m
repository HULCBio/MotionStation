% POLYSCALE 多項式の根のスケーリング
% POLYSCALE(A,ALPHA) は、Z平面内で、ALPHAによって、多項式Aの根をスケーリ
% ングします。ここで、Aは、多項式係数のベクトルです。ALPHAが実数で、0 <=
% ALPHA <= 1の場合、Aの根は、Z平面の中で原点方向に放射状にスケーリングさ
% れます。複素ALPHAは、任意の変更を根の位置に与えます。
%
% 自己回帰多項式の中で根の半径を短くすることにより、周波数応答の中のスペ
% クトルピークのバンド幅は、(平坦に)広がります。この演算は、しばしば、
% "バンド幅拡張"と云われます。
%
% 例題：LPC音声スペクトルのバンド幅拡張
%      load mtlb;                    % 音声信号
%      Ao = lpc(mtlb(1000:1100),12); % 12次の AR 多項式
%      Ax = polyscale(Ao,.85);       % バンド幅拡張
%      subplot(2,2,1); zplane(1,Ao); title('Original');
%      subplot(2,2,3); zplane(1,Ax); title('Flattened');
%      [ho,w]=freqz(1,Ao);  [hx,w]=freqz(1,Ax);
%      subplot(1,2,2); plot(w,abs(ho), w,abs(hx));
%      legend('Original','Flattened');
%
% 参考： POLYSTAB.



% Copyright 1988-2002 The MathWorks, Inc.
