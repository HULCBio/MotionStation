% FREESERIAL   serial port ���MATLAB�̃z�[���h������
%
% FREESERIAL �́A���ׂĂ� Serial port ��� MATLAB �̃z�[���h��Ԃ��J��
% ���܂��B
%
% FREESERIAL('PORT') �́A�w�肵���|�[�g PORT ��� MATLAB �̃z�[���h���
% ���J�����܂��BPORT  �́A������̃Z���z��ł��B
%
% FREESERIAL(OBJ) �́Aserial port �I�u�W�F�N�g�Ɋ֘A�����|�[�g��� 
% MATLAB�̃z�[���h��Ԃ��J�����܂��BOBJ �́Aserial port �I�u�W�F�N�g��
% �z��ł��\���܂���B
%
% serial port �I�u�W�F�N�g��������ꂽ�|�[�g�ɐڑ����悤�Ƃ���Ƃ��ɁA
% �G���[���o�͂���܂��BFCLOSE �R�}���h�́Aserial port ���� serial port 
% �I�u�W�F�N�g��ؒf���邽�߂Ɏg�p����܂��B
%
% serial port �I�u�W�F�N�g�́Aserial port �ƒʐM���邽�߂� javax.comm
% �p�b�P�[�W���g�p���܂��Bjavax.comm �p�b�P�[�W�̃��������[�N�ɂ���āA
% serial port �I�u�W�F�N�g�́AMATLAB���I�����邩�AFREESERIAL �֐���
% �R�[�������܂Ń���������������܂���B
%
% serial port �I�u�W�F�N�g���|�[�g�ɐڑ����ꂽ��A�ʂ̃A�v���P�[�V����
% ���� serial port �I�u�W�F�N�g�ɐڑ�����K�v������A�܂�MATLAB���I��
% �������Ȃ��ꍇ�̂݁AFREESERIAL ���g���܂��B
%
% ����: ���̊֐��́AWindows �v���b�g�t�H�[����ł̂ݎg���܂��B
%
% ���:
%      freeserial('COM1');
%      s = serial('COM1');
%      fopen(s);
%      fprintf(s, '*IDN?')
%      idn = fscanf(s);
%      fclose(s)
%      freeserial(s)
%   
% �Q�l : INSTRUMENT/FCLOSE.


%    MP 4-11-00
%    Copyright 1999-2002 The MathWorks, Inc. 
