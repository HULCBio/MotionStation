% LFTF   2ポートの線形分数変換
%
% [TSS_] = LFTF(TSS_1,TSS_2); または 
% [A,B1,B2,..] = LFTF(A11,B11,..,A21,B21,..);
% [SS_L] = LFTF(TSS_1,SS_2); または 
% [AL,BL,CL,DL] = LFTF(A11,B11,..,AW,BW,CW,DW);
% [SS_L] = LFTF(SS_1,TSS_2);
%  関数LFTFは、[U1;U2]から[Y1;Y2]への線形分数変換を行います。
%                                P1(s)
%  optional              ---------------------                optional
%  U1 (nu1) -----------> | P11(s)     P12(s) | -------------> Y1 (ny1)
%               -------> | P21(s)     P22(s) | -------
%               |        ---------------------       |
%               |      (nx  no. of states of P s))   |
%               |        ---------------------       |
%  optional     -------- | P11(s)     P12(s) |<-------        optional
%  Y2 (ny2) <----------- | P21(s)     P22(s) |<---------------U2 (nu2)
%                        ---------------------
%                                P2(s)



% Copyright 1988-2002 The MathWorks, Inc. 
