% SECTF   �Z�N�^�ϊ�
%
% [SYSG,SYST] = SECTF(SYSF,SECF,SECG); 
% [AG,BG,CG,DG,AT,BT1,...,DT21,DT22]=SECTF(AF,BF,CF,DF,SECF,SECG); 
% [AG,BG1,...,DG22,AT,BT1,...,DT21,DT22]=SECTF(AF,BF1,...,DF22,SECF,SECG);
% 
% SECTF�́AG(s)�̓��o��(Ug,Yg)���Z�N�^SECG�ɑ��݂���悤�ȃZ�N�^�ϊ��V�X�e
% �� G(s)���Z�o���܂��B�K�v�\�������́AF(s)�̑Ή�����M�x�N�g�����o��(Uf,
% Yf)���Z�N�^SECF�ɑ��݂��邱�Ƃł��B�܂��ASYSG = LFTF(SYST,SYSF)�𖞑���
% ����`�����ϊ�T(S)���Z�o����܂��B
% 
% ����: SYSF -- 'ss'�܂���'tss'�`���̃V�X�e��;
%                �܂��́A�Ή�����s��AF,BF,CF,DF��������
%                AF,BF1,BF2,CF1,CF2,DF11,DF12,DF21,DF22�̃��X�g;
%                'tss'�`���̏ꍇ�A(Uf1,Yf1)�ɃZ�N�^�ϊ����K�p����܂��B
%   SECF,SECG  -- ���̌^�̃Z�N�^�̂����̂����ꂩ�B
%         Form:                       �Ή�����Z�N�^
%         [A,B] �܂��� [A;B]              0> <Y-AU,Y-BU>
%         [A,B] �܂��� [A;B]              0> <Y-diag(A)U,Y-diag(B)U>
%         [SEC11 SEC12;SEC21,SEC22]       0> <SEC11*U+SEC12*Y,SEC21*U+
%                                            SEC22*Y>
% �����ŁAA,B�͔͈�[-Inf,Inf]�̃X�J���A�܂���M�sM��s��܂���M-�x�N�g����
% ���B
% 
% SEC=[SEC11,SEC12;SEC21,SEC22]�́A�s��A�܂���1�s1��(�X�J��)�܂���M�sM��
% �̃u���b�NSEC11,SEC12,SEC21,SEC22������ 'tss'�V�X�e���̂����ꂩ�ł��B
% 
% �o��:  SYSG -- F(s)�Ɠ����`����G(s)(���Ƃ��΁A'ss'�܂���'tss'�^)�B
%        SYST -- 'tss'�^��T(s)�A�܂��͍s��AT,BT1,...,DT22�̃��X�g�B
%
% �Q�l   LFTF, SEC2TSS, MKSYS.



% Copyright 1988-2002 The MathWorks, Inc. 
