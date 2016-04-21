% LTIVIEW LTI   Viewer���I�[�v��
%
%
% LTIVIEW �́A��� LTI Viewer ���I�[�v�����܂��B
% LTI Viewer �́A���`���f���Q�̎��ԉ����A�܂��́A���g����������͂�����A��r
% �����肷��Θb�^�̃O���t�B�J�����[�U�C���^�t�F�[�X(GUI)�ł��BControl System
% Toolbox���ł̐��`���f���̎g�����̏ڍׂ́ALTIMODELS ���Q�Ƃ��Ă��������B
%
% LTIVIEW(SYS1,SYS2,...,SYSN) �́ALTI ���f�� SYS1,SYS2,...,SYSN �̃X�e�b�v
% �������܂ށALTI Viewer ���J���܂��B���̂悤�ɁA�J���[�A���C���X�^�C���A
% �}�[�J���e�V�X�e�����Ɏw�肷�邱�Ƃ��ł��܂��B 
%   sys1 = rss(3,2,2); 
%   sys2 = rss(4,2,2); 
%   ltiview(sys1,'r-*',sys2,'m--');
%
% LTIVIEW(PLOTTYPE,SYS1,SYS2,...,SYSN) �ł́ALTI Viewer �̃v���b�g�ɂ����
% �w������邱�Ƃ��ł��܂��BPLOTTYPE�@�ɂ́A���̕�����i�܂��́A���̑g�����j
% �����͂ł��܂��B 
% 1) 'step'           Step ����
% 2) 'impulse'        Impulse ����
% 3) 'bode'           Bode ���}
% 4) 'bodemag'        Bode ���}�̑傫���̉����̂ݕ\��
% 5) 'nyquist'        Nyquist���}
% 6) 'nichols'        Nichols���}t
% 7) 'sigma'          ���ْl�v���b�g
% 8) 'pzmap'          ��/��_�}
% 9) 'iopzmap'        I/O ��/��_�}
%
% ���Ƃ��΁A 
%   ltiview({'step';'bode'},sys1,sys2) 
% �́ALTI���f�� SYS1 �� SYS2 �� step��Bode���������� LTI Viewer ���J���܂��B
%
% LTIVIEW(PLOTTYPE,SYS,EXTRAS) �́A�l�X�ȉ����^�C�v�ɂ���ăT�|�[�g����Ă���
% �t���I�ȓ��͈������w�肷�邱�Ƃ��ł��܂��B�����̕t���I�Ȉ����̌`���̏ڍ�
% �ɂ��ẮA�e�����^�C�v�ɑ΂��āAHELP �e�L�X�g���Q�Ƃ��Ă��������BLTI Viewer
% �� LSIM �܂��� INITIAL �̏o�̓v���b�g�ŉ��L�̃V���^�b�N�X�𗘗p���邱�Ƃ�
% �ł��܂��B
%   ltiview('lsim',sys1,sys2,u,t,x0)
%
% 2�̕t���I�ȃI�v�V�����́A���炩���ߋN������ LTI Viewer �𑀍삷�邽�߂�
% ���p�\�ł��B
%
% LTIVIEW('clear',VIEWERS) �́A�n���h�� VIEWERS ������ LTI Viewer ����
% �v���b�g��f�[�^���������܂��B
%
% LTIVIEW('current',SYS1,SYS2,...,SYSN,VIEWERS) �́A�V�X�e�� SYS1,SYS2,...
% �̉������n���h���ԍ� VIEWERS ������ LTI Viewer �ɕt�����܂��B
%
% �Q�l : STEP, IMPULSE, LSIM, INITIAL, (IO)PZMAP,


% Copyright 1986-2002 The MathWorks, Inc.
