% BILIN 状態空間モデルの双一次変換
%
% [SS_B] = BILIN(SS_,VERS,METHOD,AUG)、または、
% [AB,BB,CB,DB] = BILIN(A,B,C,D,VERS,METHOD,AUG) は、周波数平面において、
% つぎの双一次変換を実行します。
%          az + d                                
%    s = ---------  (versが1の場合);
%          cz + b                                
% 
%             d - bs
% または、 z = ----------  (versが-1の場合)
%             cs - a
% 
% ここで、つぎのようになります。
%                    -1                                -1
%       G(s) = C(Is-A) B + D <-------> G(z) = Cb(Iz-Ab)  Bb + Db
% ---------------------------------------------------------------------
%    'Tustin' ----- Tustin変換 (s = 2(z-1)/T(z+1), aug = T).
%    'P_Tust' ----- Prewarped Tustin変換 (s = w0(z-1)/tan(w0*T/2)(z+1),
%                                  aug = (T,w0), w0:prewarped周波数)
%    'BwdRec' ----- 後進矩形変換 (s = (z-1)/Tz, aug = T).
%    'FwdRec' ----- 前進矩形変換 (s = (z-1)/T, aug = T).
%    'S_Tust' ----- シフトTustin変換 (2(z-1)/T(z/sh+1), aug = (T,sh),
%                                sh: シフト係数).
%    'Sft_jw' ----- シフトjw軸双一次変換 (aug = (b1,a1), circle係数).
%    'G_Bili' ----- 一般的な双一次変換 (s = (az+d)/(cz+b), 
%                   aug = (a,b,c,d)).
%    (注意: これらのオプションは、大文字と小文字を区別しません！)
% ---------------------------------------------------------------------



% Copyright 1988-2002 The MathWorks, Inc. 
