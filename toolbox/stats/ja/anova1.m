% ANOVA1   ����q���U����(ANOVA)
%
% ANOVA1 �́A�����̃f�[�^�O���[�v�̕��ς��r�������q���U���͂����s
% ���܂��B�O���[�v�̕��ς��������Ɖ]���A�������ɑ΂��� p �l���o�͂��܂��B
%
%   P = ANOVA1(X,GROUP,DISPLAYOPT)
% 
% X ���s��̏ꍇ�AANOVA1 �́A�e��𕪊������O���[�v�Ƃ��Ď�舵���A�e���
%   ��W�c���ς����������ۂ������肵�܂��BANOVA1 �̂��̌^�́A�e�O���[�v���A
%   �����v�f��(���t�����ꂽ ANOVA)�������Ă���ꍇ�ɓK�؂ɂȂ�܂��B
%   GROUP �́AX �̊e�񂪈�̍s�ɑ΂��āA�O���[�v�����܂񂾃L�����N�^
%   �z�񂩁A�܂��́A������̃Z���z��̂ǂ��炩�ł��B�O���[�v����ݒ肵����
%   �Ȃ��ꍇ�́A��z��([])��ݒ肷�邩�A���̈������ȗ����Ă��������B
% X ���x�N�g���̏ꍇ�AGROUP �́A���������̃x�N�g���ł��邩�A�܂��́AX ��
%   �e�v�f�ɑ΂��āA��̍s����������̃Z���z��A�����z�񂩂̂����ꂩ
%   �ł��BGROUP �l�Ɠ����l�ɑΉ����� X �l���A�����O���[�v�̒��ɔz�u����܂��B
%
% DISPLAYOPT �́A�W����1���q���U���͕\�ƃ{�b�N�X�v���b�g���܂ސ}��\��
% ����ɂ� 'on'(�f�t�H���g)�A�����̕\�����ȗ�����ɂ� 'off' ���g���܂��B
%
% [P,ANOVATAB] = ANOVA1(...) �́AANOVA �e�[�u���l���Z���z�� ANOVATAB �Ƃ���
% �o�͂��܂��B
%
% [P,ANOVATAB,STATS] = ANOVA1(...) �́AMULTCOMPARE �֐��ŕ��ς̑��d��r
% ����̎��s�ɖ𗧂t���I�ȓ��v�ʂ̍\���̂��o�͂��܂��B
%
% �Q�l : ANOVA2, ANOVAN, BOXPLOT, MANOVA1, MULTCOMPARE.


%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.6 $  $Date: 2003/02/12 17:10:02 $
