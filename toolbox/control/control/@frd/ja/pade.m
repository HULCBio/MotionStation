% PADE   �ނ����Ԃ� Pade �ߎ�
%
% [NUM,DEN] = PADE(T,N) �́A�A�����Ԃł̒x�� exp(-T*s) �� N ���� Pade 
% �ߎ���`�B�֐��̌`���ŏo�͂��܂��B�s�x�N�g�� NUM �� DEN �́As �̎�����
% �~�ׂ��̏��ɕ��ׂ��������̌W�����܂݂܂��B
%
% ���ӂ̈����������ꍇ�APADE(T,N) �́AN ���� Pade �ߎ��̃X�e�b�v�����ƈ�
% ���������v���b�g���A�ނ����Ԃ̐��m�ȉ����Ɣ�r���܂�(����:Pade �ߎ��́A
% ���ׂĂ̎��g���ŁA�P�ʃQ�C���ɂȂ�܂�)�B
%
% SYSX = PADE(SYS,N) �́A�A�����Ԃ̂ނ����Ԃ����V�X�e�� SYS �̂��ׂĂ�
% �ނ����Ԃ� N ���� Pade �ߎ��Œu�������邱�Ƃɂ��A�ނ����Ԃ̂Ȃ��ߎ�
% �V�X�e�� SYSX ���o�͂��܂��B 
%
% SYSX = PADE(SYS,NI,NO,NIO) �́A���́A�o�́AI/O �x�ꖈ�ɓƗ����ċߎ�
% �������w�肵�܂��B�����ŁANI, NO, NIO �́A���̂悤�Ȑ����ł��B
% 
%  * NI(j) �́Aj �Ԗڂ̓��̓`�����l���̋ߎ������ł��B
%  * NO(i) �́Ai �Ԗڂ̏o�̓`�����l���̋ߎ������ł��B
%  * NIO(i,j) �́A���͒x�� j ����o�͒x�� i �܂ł� I/O �x��̋ߎ�������
%    ���B
% 
% ��l�ȋߎ��������w�肷�邽�߂ɁANI, NO, NIO �ɃX�J���[�l�𗘗p���邱��
% ���ł��܂��B���͒x��A�o�͒x��AI/O �x�ꂪ�Ȃ��ꍇ�A[] �𗘗p���܂��B
%
% �Q�l : DELAY2Z, C2D, LTIMODELS, LTIPROPS.


%       Author(s): S. Almy
%       Copyright 1986-2002 The MathWorks, Inc. 
