% SERIALBREAK   �f�o�C�X�� break �𑗂�
%
% SERIALBREAK(OBJ) �I�u�W�F�N�g OBJ �ɐڑ����Ă���f�o�C�X�ɁA10ms ��
% break �𑗂�܂��BOBJ �́A1�s1��� serial port �I�u�W�F�N�g�łȂ����
% �Ȃ�܂���B
%
% �I�u�W�F�N�g OBJ �́ASERIALBREAK �R�}���h���Ăяo�����O�ɁA FOPEN 
% �R�}���h���g���āA�f�o�C�X�ɐڑ����Ȃ���΂Ȃ�܂���B���̑��̏ꍇ��
% �G���[�ɂȂ�܂��B�ڑ����ꂽ�I�u�W�F�N�g�́Aopen �� Status �v���p�e�B
% �l�������܂��B
%
% SERIALBREAK(OBJ, TIME) �́A�I�u�W�F�N�g OBJ �ɐڑ����Ă���f�o�C�X�� 
% TIME ms �� break �𑗂�܂��B
%
% SERIALBREAK �́A���s����������܂ŁAMATLAB �̃R�}���h���C�����~����
% ���������֐��ł��B
%
% SERIALBREAK �́A�񓯊��̏������݂̎��s���ɁA�R�[�������ƁA�G���[��
% �߂��܂��B���̏ꍇ�A�֐� STOPASYNC ���R�[�����āA�񓯊��������݉��Z��
% ��~���A�������݉��Z����������܂ŁA�҂���Ԃɂ��邱�Ƃ��ł��܂��B
%
% �ؒf�̎��ԊԊu�́A�������̃I�y���[�e�B���O�V�X�e���ł͕s���m�ɂȂ�
% �\�������邱�Ƃɒ��ӂ��Ă��������B
%
% ���:
%      s = serial('COM1');
%      fopen(s);
%      serialbreak(s);
%      serialbreak(s, 50);
%      fclose(s);
%
% �Q�l : SERIAL/FOPEN, SERIAL/STOPASYNC.


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
