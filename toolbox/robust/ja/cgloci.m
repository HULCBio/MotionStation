% CGLOCI   �A���n�̓����Q�C��/�ʑ����g������
% CGLOCI(A,B,C,D)�A�܂��́ACGLOCI(SS_)�́A���̎��g���֐�
%                                       -1
%                        G(jw) = C(jwI-A) B + D
% �̕��f�s��̓����Q�C��/�ʑ���Bode�v���b�g���쐬���܂��B�����Q�C���O��
% �́ABode�Q�C��������MIMO�V�X�e���ւ̊g���ł��B���g���̈�ƃ|�C���g���́A
% �����I�ɑI������܂��B�����V�X�e���ɑ΂��āACGLOCI(A,B,C,D,'inv')�́A
% ���Ɏ����t�V�X�e���̕��f�s��̓����Q�C��/�ʑ����o�͂��܂��B
%	     -1               -1      -1
%           G (jw) = [ C(jwI-A) B + D ]
%
% CGLOCI(A,B,C,D,W)�A�܂��́ACGLOCI(A,B,C,D,W,'inv')�́A���[�U�����g���x
% �N�g��W��^���邱�Ƃ��ł��܂��B���g���x�N�g��W�́A�����Q�C��/�ʑ�����
% ���]������郉�W�A��/�b�P�ʂ̎��g�����܂܂Ȃ���΂Ȃ�܂���B
% ���ӈ�����ݒ肵�Ď��s�����Ƃ�
%		[CG,PH,W] = CGLOCI(A,B,C,D,...)
% �́A���g���x�N�g��W�ƁAlength(W)�sMIN(NU,NY)��̍s��CG,PH���o�͂��܂��B
% �����ŁANU�͓��͐��ANY�͏o�͐��ł��B�X�N���[����Ƀv���b�g�͍s���܂�
% ��B�����Q�C���́A�~���ɏo�͂���܂��B
%
% �Q�l  : LOGSPACE, SEMILOGX, NICHOLS, NYQUIST, BODE.



% Copyright 1988-2002 The MathWorks, Inc. 
