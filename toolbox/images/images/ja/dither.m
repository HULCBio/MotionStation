% DITHER    �f�U�����O���g���āA�C���[�W��ϊ�
% X = DITHER(RGB,MAP) �́A�J���[�}�b�v MAP �̃J���[�̃f�U�����O���g���āA
% �z�� RGB ���� RGB �C���[�W�̃C���f�b�N�X�t���C���[�W�ߎ����s���܂��B
% MAP �́A65536 �F�ȏ�̃J���[�������Ƃ͂ł��܂���B
%
% X = DITHER(RGB,MAP,Qm,Qe) �́A�p�����[�^ Qm �� Qe ���w�肵�āARGB ����
% �C���f�b�N�X�t���C���[�W���쐬���܂��BQm �́A�t�J���[�}�b�v�ɑ΂���e
% �J���[���ɉ����Ďg���ʎq���r�b�g����ݒ肵�܂��B�����āAQe �́A�J���[
% ��Ԃ̌��v�Z�Ɏg�p����ʎq���r�b�g����ݒ肵�܂��BQe < Qm �̏ꍇ�A�f
% �U�����O�͎��s���ꂸ�A�f�U�����O����Ă��Ȃ��C���f�b�N�X�t���C���[�W��
% X �ɏo�͂���܂��B�����̃p�����[�^���ȗ�����ƁADITHER �́A�f�t�H��
% �g�l Qm = 5, Qe = 8���g���܂��B
% 
% BW = DITHER(I) �́A�s�� I �̋��x�C���[�W���f�U�����O���g���āA�o�C�i��
% �C���[�W BW �ɕϊ����܂��B
% 
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W(RGB�A�܂��́AI)�́Auint8�Auint16�A�܂��́Adouble �̂�����
% �̃N���X���T�|�[�g���Ă��܂��B���̓��͈����́A���ׂăN���X double �ł�
% ����΂Ȃ�܂���B�o�̓C���[�W(X�A�܂��́ABW)�́A�o�C�i���C���[�W�̏�
% ���A�N���Xlogical�ɂȂ�A�J���[��256�ȉ��̃C���f�b�N�X�t���C���[�W�̏ꍇ�A
% �N���X uint8 �ɂȂ�A���̑��̏ꍇ�ɂ́A�N���X uint16 �ɂȂ�܂��B
% 
% �Q�l�FRGB2IND.



%   Copyright 1993-2002 The MathWorks, Inc.  
