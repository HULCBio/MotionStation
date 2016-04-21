% AUGD 2ポート状態空間プラントの対角スケーリング行列 D(s) による拡大
%
% [TSS_D] = AUGD(TSS_,SS_D)、または、
% [AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22] = AUGD(A,B1,B2,C1,C2,..
% D11,D12,D21,D22,AD,BD,CCD,DD) は、2ポート拡大プラントを生成します。
% TSS_D は、対角行列D(s)とinv(D(s))により、つぎのように拡大されます。
%                             -1
%     (TSS_D) := D(s) P(s) D(s)
%              = MKSYS(AD,BD1,BD2,CCD1,CCD2,DD11,DD12,DD21,DD22,'tss');
%
%
%  入力データ : P = TSS_ = MKSYS(A,B1,B2,C1,C2,D11,D12,D21,D22,'tss')
%               D = SS_D = MKSYS(AD,BD,CCD,DD);

% Copyright 1988-2002 The MathWorks, Inc. 
