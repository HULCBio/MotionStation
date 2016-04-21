% CFS2WPT   係数からウェーブレットパケットツリーを構築
%
% CFS2WPT は、ウェーブレットパケットツリーと関連する解析信号、または
% イメージを構築します。
%
% [T,X] = CFS2WPT(WNAME,SIZE_OF_DATA,TN_OF_TREE,ORDER,CFS) は、ウェーブ
% レットパケットツリー T と関連する解析信号、またはイメージ X を出力し
% ます。
%
%   WNAME は、解析に使用するウェーブレット名です。
%   SIZE_OF_DATA は、解析信号、またはイメージの大きさです。
%   TN_OF_TREE は、ツリーの終端ノードインデックスを含むベクトルです。
%   ORDER は、信号に対して2、イメージに対して4です。
%   CFS は、オリジナル信号、またはイメージを再構成するために、使用する
%       係数を含んだベクトルです。
%
% CFS は、オプションです。CFS2WPT が、CFS 入力パラメータなしで使われた
% 場合、すべてのツリー係数は(X が空であることを意味する)空になりますが、
% ウェーブレットパケットツリー構造 (T) は生成されます。
%
% 例題:
%     load detail
%     t = wpdec2(X,2,'sym4');
%     cfs = read(t,'allcfs');
%     noisyCfs = cfs + 40*rand(size(cfs));
%     noisyT = cfs2wpt('sym4',size(X),tnodes(t),4,noisyCfs);
%     plot(noisyT)
%
%     t = cfs2wpt('sym4',[1 1024],[3 9 10 2]',2);
%     sN = read(t,'sizes',[3,9]);
%     sN3 = sN(1,:); sN9 = sN(2,:);
%     cfsN3 = ones(sN3);
%     cfsN9 = randn(sN9);
%     t = write(t,'cfs',3,cfsN3,'cfs',9,cfsN9);
%     plot(t)


%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 01-Aug-2001.
%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2003/04/18 18:11:52 $
