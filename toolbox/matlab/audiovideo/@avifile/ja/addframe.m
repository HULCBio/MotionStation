% ADDFRAME   ビデオフレームを AVI ファイルに付加
% 
% AVIOBJ = ADDFRAME(AVIOBJ,FRAME) は、FRAME 内のデータを AVIFILE として
% 作成されたAVIOBJ へ付加します。FRAME は、インデックス付きイメージ(M行
% N列)、または double か uint8 の精度のトゥルーカラーイメージ(M×N×3)
% のいずれかになります。FRAME で、最初のフレームが AVIファイルに付加され
% ない場合、前のフレームの次元と整合性をもつ必要があります。
%   
% AVIOBJ = ADDFRAME(AVIOBJ,FRAME1,FRAME2,FRAME3,...) は、複数のフレームを
% 一つのAVIファイルに付加します。
%
% AVIOBJ = ADDFRAME(AVIOBJ,MOV) は、MATLABムービー MOV に含まれたフレーム
% をAVIファイルに付加します。インデックス付きイメージとしてフレームを
% ストアするMATLABムービーは、カラーマップが前もって設定されていない
% 場合、AVIファイル用のカラーマップとして最初のフレームを使います。
%
% AVIOBJ = ADDFRAME(AVIOBJ,H) は、figure、または座標軸のハンドルからの
% フレームをキャプチャし、このフレームをAVIファイルに付加します。フレーム
% は、AVIファイルに加えられる前に、画面外の配列内に描写されます。この
% シンタックスは、アニメーション内のグラフが XOR グラフィックスを用いて
% いる場合は使えません。
%
% アニメーションが XOR グラフィックスを用いている場合、MATLABムービー
% のあるフレームの中にグラフィックスを表示する代わりに GETFRAME を用いて
% つぎの例に示すように、シンタックス [AVIOBJ] = ADDFRAME(AVIOBJ,MOV) を
% 使います。GETFRAME は、画面上のイメージのスナップショットを撮ります。
% 
%    fig=figure;
%    set(fig,'DoubleBuffer','on');
%    set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%        'nextplot','replace','Visible','off')
%    aviobj = avifile('example.avi')
%    x = -pi:.1:pi;
%    radius = [0:length(x)];
%    for i=1:length(x)
%     h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%     set(h,'EraseMode','xor');
%     frame = getframe(gca);
%     aviobj = addframe(aviobj,frame);
%    end
%    aviobj = close(aviobj);
%
% 参考：AVIFILE, AVIFILE/CLOSE, MOVIE2AVI.


%   Copyright 1984-2002 The MathWorks, Inc.
