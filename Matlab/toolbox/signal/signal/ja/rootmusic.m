% ROOTMUSIC   Root MUSIC �A���S���Y�����g���āA���f�����g�̎��g���ƃp��
%             �[���v�Z
% 
% W = ROOTMUSIC(X,P) �́A�M���x�N�g�� X �̒��̕��f�����g�̎��g�� W ���o
% �͂��܂��BW �́Arad/�T���v���P�ʂł��BP �́AX �̒��̕��f�����g�̌���
% ���BX ���f�[�^�s��̏ꍇ�A�e�s�͕ʁX�̃Z���T�[�܂��͎�������̑���l��
% ���߂���܂��B���̏ꍇ�AX �̗񐔂́AP �̗񐔂�葽���Ȃ���΂Ȃ�܂���B
% ���[�U�́A�����Ŏg�p����f�[�^�s����A�֐� CORRMTX ���g���č쐬�ł���
% ���B 
%
% W = ROOTMUSIC(R,P,'corr') �́A���֍s����v�Z����M���ɑ΂��āA����s��
% R�ŗ^��������g���x�N�g�� W ���o�͂��܂��BR �̍s���܂��͗񐔂́AP ��
% ��傫���K�v������܂��B
%
% P ��2�v�f�x�N�g���̏ꍇ�AP(2) �́A�M����Ԃƃm�C�Y��Ԃ𕪗�����J�b�g
% �I�t�Ƃ��Ďg���܂��BP(2)�ƍŏ��̌ŗL�l�̐ς��傫���ŗL�l���M���̌�
% �L�l�ƍl�����܂��B���̏ꍇ�A�M���̕�����Ԃ̎����́A�ق� P(1) �ɂȂ�
% �܂��B
%
% F = ROOTMUSIC(...,Fs) �́A�v�Z�̒��ŃT���v�����O���g�� Fs ���g���āAHz
% �P�ʂŁA���g���x�N�g�� F ���o�͂��܂��B
% 
% [W,POW] = ROOTMUSIC(...) �́AX ���̐����g�̃p���[�̐����v�f�Ƃ���x
% �N�g�� POW ���o�͂��܂��B
%
% ���F
%    randn('state',1); n = 0:99;   
%    s = exp(i*pi/2*n)+2*exp(i*pi/4*n)+exp(i*pi/3*n)+randn(1,100);  
%    X = corrmtx(s,12,'mod'); % �C�������U�@���g���āA���֍s��𐄒�
%    [W,P] = rootmusic(X,3);         
% 
% �Q�l�F   ROOTEIG, PMUSIC, PEIG, PMTM, PBURG, PWELCH, CORRMTX.



%   Copyright 1988-2002 The MathWorks, Inc.
