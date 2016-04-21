% AUGSS   W1,W2,W3 (状態空間型)の2ポートプラントへの拡大
%
%  [TSS_] = AUGSS(SS_G,SS_W1,SS_W2,SS_W3,W3POLY)または
%  [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGSS(AG,BG,CG,DG,AW1,BW1,CW1,DW1,...
% AW2,BW2,CW2,DW2,AW3,BW3,CW3,DW3,W3POLY)は、つぎのような重み付けによ
% り拡大されたプラントの状態空間モデルを計算します。
%
%     W1 = ss_w1 = mksys(aw1,bw1,cw1,dw1); ---- 誤差信号'e'に対する重み
%     W2 = ss_w2 = mksys(aw2,bw2,cw2,dw2); ---- 制御信号'u'に対する重み
%     W3 = ss_w3 + w3poly ---- 出力信号'y'に対する重み
%   
% ここで
%     ss_w3 = mksys(aw3,bw3,cw3,dw3);
%     w3poly := 降順に並べられた多項式行列(オプション入力)
%             = [w3(n),w3(n-1),...,w3(0)]
%               size(w3(i))=size(dw3) (i=0,1,...,n)
%
% 注意: 1) 上記の重み関数は、ss_w1, ss_w2, ss_w3をmksys([],[],[],[])と設
%          定することによって削除されます。
%       2) w3polyは、省略されるとデフォルトの[]になります。
%
% 拡大されたシステムは、TSS_=mksys(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
% です。



% Copyright 1988-2002 The MathWorks, Inc. 
