%LOGM   �s��̑ΐ�
% L = LOGM(A) �́A�s�� A �̑ΐ��̎�l�ŁAEXPM(A) �̋t�֐��ł��B
% L �́A���傤�� -PI �� PI �̊Ԃɂ��鋕���������ׂĂ̌ŗL�l�ɑ΂���
% ���j�[�N�ȑΐ��ł��BA ���񐳑��A�܂��́A���̎�����ɌŗL�l�����ꍇ�A
% �ΐ��̎�l�͒�`���ꂸ�A��l�łȂ��ΐ����v�Z����A���[�j���O���b�Z�[�W
% ���\������܂��B
%
% [L,EXITFLAG] = LOGM(A) �́ALOGM �̏I���������q�ׂ�X�J���[�� EXITFLAG 
% ���o�͂��܂��B
%   EXITFLAG = 0: �A���S���Y���̐���I��
%   EXITFLAG = 1: 1�܂��͕����� Taylor �������������܂���ł����B
%                 �������A�v�Z���ꂽ F �́A���m�ł��B
% ����: R13 �� �ȑO�̃o�[�W�����́A��2�o�͈����Ɍv�Z�ʂ������s���m�ɂȂ邱��
% �������덷�]�����o�͂��Ă������߁A���̓_�ňقȂ�܂��B
%
% �Q�l EXPM, SQRTM, FUNM.

%   Nicholas J. Higham
%   Copyright 1984-2003 The MathWorks, Inc. 
