% BILIN ��ԋ�ԃ��f���̑o�ꎟ�ϊ�
%
% [SS_B] = BILIN(SS_,VERS,METHOD,AUG)�A�܂��́A
% [AB,BB,CB,DB] = BILIN(A,B,C,D,VERS,METHOD,AUG) �́A���g�����ʂɂ����āA
% ���̑o�ꎟ�ϊ������s���܂��B
%          az + d                                
%    s = ---------  (vers��1�̏ꍇ);
%          cz + b                                
% 
%             d - bs
% �܂��́A z = ----------  (vers��-1�̏ꍇ)
%             cs - a
% 
% �����ŁA���̂悤�ɂȂ�܂��B
%                    -1                                -1
%       G(s) = C(Is-A) B + D <-------> G(z) = Cb(Iz-Ab)  Bb + Db
% ---------------------------------------------------------------------
%    'Tustin' ----- Tustin�ϊ� (s = 2(z-1)/T(z+1), aug = T).
%    'P_Tust' ----- Prewarped Tustin�ϊ� (s = w0(z-1)/tan(w0*T/2)(z+1),
%                                  aug = (T,w0), w0:prewarped���g��)
%    'BwdRec' ----- ��i��`�ϊ� (s = (z-1)/Tz, aug = T).
%    'FwdRec' ----- �O�i��`�ϊ� (s = (z-1)/T, aug = T).
%    'S_Tust' ----- �V�t�gTustin�ϊ� (2(z-1)/T(z/sh+1), aug = (T,sh),
%                                sh: �V�t�g�W��).
%    'Sft_jw' ----- �V�t�gjw���o�ꎟ�ϊ� (aug = (b1,a1), circle�W��).
%    'G_Bili' ----- ��ʓI�ȑo�ꎟ�ϊ� (s = (az+d)/(cz+b), 
%                   aug = (a,b,c,d)).
%    (����: �����̃I�v�V�����́A�啶���Ə���������ʂ��܂���I)
% ---------------------------------------------------------------------



% Copyright 1988-2002 The MathWorks, Inc. 
