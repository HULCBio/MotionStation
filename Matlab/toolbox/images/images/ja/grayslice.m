% GRAYSLICE   �X���b�V���z�[���h�@���g���āA���x�C���[�W����C���f�b�N
%             �X�t���C���[�W���쐬
% X=GRAYSLICE(I,N) �́A�X���b�V���z�[���h�l�A1/n,2/n,...,(n-1)/n ��
% �g���āA���x�C���[�W I �ɃX���b�V���z�[���h��K�p���AX �ɃC���f�b
% �N�X�t���C���[�W���o�͂��܂��B
%
% X=GRAYSLICE(I,V) �́A�l V ���X���b�V���z�[���h�l�Ƃ��Ďg���āAI ��
% �X���b�V���z�[���h��K�p���AX �ɃC���f�b�N�X�t���C���[�W���o�͂���
% ���B�����ŁAV �́A0��1�̊Ԃ̒l����\�������x�N�g���ł��B
%
% �K�؂Ȓ����̃J���[�}�b�v���g���āAIMSHOW(X,MAP) �ɂ��X���b�V��
% �z�[���h��K�p�����C���[�W�������ł��܂��B
%
% �N���X�T�|�[�g
% -------------
% ���̓C���[�W I �́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X
% ���T�|�[�g���Ă��܂��B���̓C���[�W I �́A��X�p�[�X�ł���K�v������
% �܂��B�X���b�V���z�[���h�l�́AI ���N���X uint8 �A�܂��́Auint16 ��
% �����Ă��A�K��0��1�͈̔͂̒l�ł��邱�Ƃɒ��ӂ��Ă��������B
% I ���N���X uint8 �A�܂��́Auint16 �̏ꍇ�A�e�X���b�V���z�[���h�l�́A
% ���ۂɎg���X���b�V���z�[���h�����߂邽�߂�255�{�A�܂��́A65535�{����܂��B
%
% �o�̓C���[�W X �̃N���X�́AN �A�܂��́Alength(V) �Őݒ肳���X
% ���b�V���z�[���h�l�̐��Ɉˑ����܂��B�X���b�V���z�[���h�l�̐���256
% �����̏ꍇ X �̓N���X uint8 �ɂȂ�AX �̒l��0���� N �A�܂��́A
% length(V) �͈̔͂ɂȂ�܂��B�X���b�V���z�[���h�l�̐���256�ȏ�̏�
% ���AX �̓N���X double �ɂȂ�AX �̒l��1���� N+1�A�܂��́A
% length(V)+1�͈̔͂ɂȂ�܂��B
%
% ���
% ----
% �}���`���x���X���b�V���z�[���h�@���g���āA�V���֘A�C���[�W�̖��ēx
% �����߂܂��B
%
%       I = imread('ngc4024m.tif');
%       X = grayslice(I,16);
%       imshow(I), figure, imshow(X,hot(16))
%
% �Q�l : GRAY2IND.



%   Copyright 1993-2002 The MathWorks, Inc.  
