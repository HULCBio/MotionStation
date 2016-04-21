% WMEMTOOL 　メモリツールの管理コマンド
%
% 一般バッファオプション
% -----------------------
% 'handle' 、'create' 、'close'、'empty' ,
% 'put'、'get'、'del'、'find'.
%  
% HDL = WMEMTOOL('handle')
% HDL = WMEMTOOL('create')
% WMEMTOOL('close')
% WMEMTOOL('empty')
% WMEMTOOL('put',NAME,VAL)、または、wmemtool('put',NAME,VAL,STRINFO) は、バッフ
% ァが検出されない場合に、バッファを作り出します。
%
% VAL = WMEMTOOL('get',NAME,STRINFO)は、"NAME" で指定された変数が検出されない場
% 合、[]を出力します。
%
% WMEMTOOL('del',NAME,VAL)、または、WMEMTOOL('del',NAME,VAL,STRINFO)
%
% REP = WMEMTOOL('find') は、バッファが存在する場合1を、他の場合は0を出力します。
%
%  FIGURE オプションにおけるバッファ
% ----------------------------
% T = WMEMTOOL('ini',FIG,BLOCNAME,NBVAL)
% T = WMEMTOOL('hmb',FIG,BLOCNAME)
% T は、MemBloc を含むテキストのハンドルです。
%
% WMEMTOOL('wmb',FIG,BLOCNAME,IND1,V1,...,IND12,V12),
% [V1,..V12] = WMEMTOOL('rmb',FIG,BLOCNAME,IND1,...,IND12),
% Vj = MemBloc の j 番目の値 
% INDj = MemBloc の j 番目のインデックス
%
% WMEMTOOL('dmb',FIG,BLOCNAME) は、指定された MemBloc を削除します。
% 



%   Copyright 1995-2002 The MathWorks, Inc.
