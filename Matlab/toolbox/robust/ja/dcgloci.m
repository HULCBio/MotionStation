% DCGLOCI   ���U�n�̓����Q�C��/�ʑ����g������
%
% DCGLOCI(A,B,C,D,Ts)�A�܂��́ADCGLOCI(SS_,Ts)�́A���̎��g���֐�
%                                                 -1
%                             G(w) = C(exp(jwT)I-A) B + D
%
% �̕��f�s��̓����Q�C��/�ʑ���Bode�v���b�g���쐬���܂��B�����Q�C��/�ʑ�
% �́ABode�Q�C��������MIMO�V�X�e���ւ̊g���ł��B���g���̈�ƃ|�C���g���́A
% �����I�ɑI������܂��B�����V�X�e���ɑ΂��āADCGLOCI(A,B,C,D,'inv')�́A
% �t�V�X�e���̕��f�s��̓����Q�C��/�ʑ����o�͂��܂��B
%	                  -1                    -1      -1
%	                 G (w) = [ C(exp(jwT)I-A) B + D ]
%
% DCGLOCI(A,B,C,D,Ts,W)�A�܂��́ADCGLOCI(A,B,C,D,Ts,W,'inv')�́A���[�U��
% ���g���x�N�g��W��^���邱�Ƃ��ł��܂��B���g���x�N�g��W�́A�����Q�C��/
% �ʑ����]������郉�W�A��/�b�P�ʂ̎��g�����܂܂Ȃ���΂Ȃ�܂���B�i�C
% �L�X�g���g��(pi/Ts)�����傫�����g���ł́A�G���A�V���O���N����܂��B
% 
% ���ӈ�����ݒ肵�Ď��s�����Ƃ�
%		[CG,PH,W] = DCGLOCI(A,B,C,D,Ts,...)
% �́A���g���x�N�g��W�ƁAlength(W)�sMIN(NU,NY)��̍s��CG,PH���o�͂��܂��B
% �����ŁANU�͓��͐��ANY�͏o�͐��ł��B�X�N���[����Ƀv���b�g�͍s���܂�
% ��B�����Q�C��/�ʑ��́A�~���ɏo�͂���܂��B
% 
% �Q�l�FLOGSPACE, SEMILOGX, DNICHOLS, DNYQUIST, DBODE.



% Copyright 1988-2002 The MathWorks, Inc. 
