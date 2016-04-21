% ISSYSTEM   (MKSYSで作成された)システム行列のチェック
%
% [I,TY,N]=ISSYSTEM(X)は、X が関数 MKSYS, MKLTI, PCK, LTISS, SS, TF. ZPK 
% で作成されたシステム行列であるかどうかをチェックします。X がシステムの場
% 合、つぎのようになります。
% 
%                I    =  1
%                TY   =  システムのタイプ
%                N    =  システム内の行列数(TYに依存)
% そうでなければ、I=0, TY=[], N=0です。
%
% 参考： MKLTI, MKSYS, PCK, LTISYS and BRANCH.



% Copyright 1988-2002 The MathWorks, Inc. 
