% SECTF �Z�N�^�ϊ�
%
% [SYSG,SYST] = SECTF(SYSF,SECF,SECG)�A�܂��́A
% [AG,BG,CG,DG,AT,BT1,...,DT21,DT22]=SECTF(AF,BF,CF,DF,SECF,SECG); 
% �܂��́A
% [AG,BG1,...,DG22,AT,BT1,...,DT21,DT22]=SECTF(AF,BF1,...,DF22,SECF,SECG);
%
% SECTF�́AG(s)�̓��o��(Ug,Yg)���Z�N�^SECG�ɑ��݂���悤�ȃZ�N�^�ϊ��V�X
% �e�� G(s)���Z�o���܂��B�K�v�\�������́AF(s)�̑Ή�����M�x�N�g�����o��
% (Uf,Yf)���Z�N�^SECF�ɑ��݂��邱�Ƃł��B�܂��ASYSG = LFTF(SYST,SYSF)��
% ����������`�����ϊ�T(S)���Z�o����܂��B
% ����: SYSF -- 'ss'�܂���'tss'�`���̃V�X�e��;
%               �܂��́A
%               �Ή�����s��AF,BF,CF,DF�A
%               �܂��́A
%               AF,BF1,BF2,CF1,CF2,DF11,DF12,DF21,DF22�̃��X�g;
%               'tss'�`���̏ꍇ�A(Uf1,Yf1)�ɃZ�N�^�ϊ����K�p����܂��B
% SECF,SECG  -- ���̌`���̃Z�N�^:
%       �`��:                      �Ή�����Z�N�^:
%       [A,B]�A�܂��́A[A;B]       0> <Y-AU,Y-BU>
%       [A,B]�A�܂��́A[A;B]       0> <Y-diag(A)U,Y-diag(B)U>
%       [SEC11 SEC12;SEC21,SEC22]  0> <SEC11*U+SEC12*Y,SEC21*U+SEC22*Y>
% 
% �����ŁAA,B��[-Inf,Inf]�̃X�J���AM�sM�񐳕��s��AM-�x�N�g���̂����ꂩ
% �ł��B�����āASEC=[SEC11,SEC12;SEC21,SEC22]�́A1�s1��(�X�J��)��M�sM��
% �u���b�N SEC11,SEC12,SEC21,SEC22�́A�s��A�܂��́A'tss'�V�X�e���ł��B
% �o��:  SYSG -- F(s)�Ɠ����`����G(s) (���Ƃ��΁A'ss'�`����'tss'�`��)
%        SYST -- 'tss'�`����T(s); �܂��́A�s��AT,BT1,...,DT22�̃��X�g
%
% �Q�l�F LFTF, SEC2TSS and MKSYS.



% $Revision: 1.6.4.2 $
% Copyright 1988-2002 The MathWorks, Inc. 
