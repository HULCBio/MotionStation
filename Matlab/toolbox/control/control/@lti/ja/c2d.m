% C2D   C2D 変換での LTI プロパティを管理
%
% Tustin や Matched 法では、
% 
%   DSYS.LTI = C2D(CSYS.LTI,TS,TOLINT) 
% 
% は、つぎのようにして作成される離散モデル DSYS のLTIプロパティを設定
% します。
% 
%   DSYS = C2D(CSYS,TS)
% 
% 連続時間の遅れは、TS でスケーリングされ、最も近い整数に丸められます。
%
% ZOH または FOH の手法
% 
%   DSYS.LTI = C2D(CSYS.LTI,TS,DID,DOD,DIOD) 
% 
% は、DSYS = C2D(CSYS,TS) の LTI プロパティを設定します。配列 DID, DOD, 
% DIOD は、ZOH または FOH の離散化の間に計算された離散時間の入力、出力、
% I/O の遅れを示します。
%
% 参考 : TF/C2D.


%   Author(s): P. Gahinet, 5-28-96
%   Copyright 1986-2002 The MathWorks, Inc. 
