% WDATAMGR　 データ構造に対する管理コマンド
% WDATAMGR は、ウェーブレットパケットツリー構造に対する一種のデータ管理コマンド
% です。
% [OUT1,OUT2] = WDATAMGR(O,D,IN3,IN4,IN5)、ここで、D はデータ構造、0は文字列オプ
% ションです。使えるオプションは、つぎのとおりです。
% 
% 'write_cfs': 不連続ノードに対する係数を記述
%     data  = wdatamgr('write_cfs',data,tree,node,coefs)
% 
% 'read_cfs'   : 不連続ノードに対する係数の読み込み
%     coefs = wdatamgr('read_cfs',data,tree,node);
% 
% 'read_ent'   : エントロピーベクトルの読み込み
%     ent   = wdatamgr('read_ent',data,nodes) 
% 
% 'read_ento'  : 最適エントロピーベクトルの読み込み
%     ento  = wdatamgr('read_ento',data,nodes)
% 
% 'read_tp_ent': エントロピーに対するタイプとパラメータの読み込み
%     [type_ent,param] = wdatamgr('read_tp_ent',data)
% 
% 'read_wave'  : ウェーブレットの名の読み込み
%     wave = wdatamgr('read_wave',data)
% 
% 'write_wave': ウェーブレット名の書き込み
%     data  = wdatamgr('write_wave',data,wname)
%
% 参考： WPDEC, WPDEC2, WTREEMGR.



% $Revision: $
% Copyright 1995-2002 The MathWorks, Inc.
