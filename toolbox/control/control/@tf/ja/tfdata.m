% TFDATA   �`�B�֐��f�[�^�ւ̃N�C�b�N�A�N�Z�X
%
% [NUM,DEN] = TFDATA(SYS) �́A�`�B�֐� SYS �̕��q�������ƕ��ꑽ������
% �o�͂��܂��BNU ���́ANY �o�͂̓`�B�֐��ɑ΂��āANUM �� DEN �́ANY*NU 
% �̃Z���z���(I,J) �v�f�́A���� J ����o�� I �܂ł̓`�B�֐���\���܂��B
% SYS �́A�K�v�ȏꍇ�A�܂��A���߂ɓ`�B�֐��ւ̕ϊ����s���܂��B
%
% [NUM,DEN,TS] = TFDATA(SYS) �́A�T���v������ TS ���o�͂��܂��BSYS ��
% ���̑��̃v���p�e�B�́AGET �܂��́A���ړI�ɍ\���̃��C�N�ȏ���(���Ƃ��΁A
% SYS.Ts)�ŎQ�Ƃ��邱�Ƃ��ł��܂��B
%
% SISO���f�� SYS �ł́A�����A
% 
%    [NUM,DEN] = TFDATA(SYS,'v')
% 
% �́A�Z���z��ł͂Ȃ��A�s�x�N�g���ŕ��q�������ƕ��ꑽ�������o�͂��܂��B
%
% LTI���f���̔z�� SYS �ɑ΂��āANUM �� DEN �́ASYS �Ɠ����T�C�Y�� ND �Z��
% �z��ŁANUM(:,:,k) �� DEN(:,:,k) �� k �Ԗڂ̃��f�� SYS(:,:,k) �̓`�B�֐�
% ��\���܂��B
%
% �Q�l : TF, GET, ZPKDATA, SSDATA, LTIMODELS, LTIPROPS.


%       Author(s): P. Gahinet, 25-3-96
%       Copyright 1986-2002 The MathWorks, Inc. 
