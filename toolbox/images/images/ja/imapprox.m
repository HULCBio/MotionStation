% IMAPPROX   ���Ȃ��J���[�ŃC���f�b�N�X�t���C���[�W���ߎ�
%   [Y,NEWMAP] = IMAPPROX(X,MAP,N) �́A�C���f�b�N�X�t���C���[�W X �Ƃ�
%   ��Ɋ֘A�����J���[�}�b�v MAP �����J���[���ŏ��ϓ��ʎq���@���g��
%   �ċߎ����܂��BIMAPPROX �́A�J���[�}�b�v NEWMAP �����C���f�b�N�X
%   �t���C���[�W Y ���o�͂��܂��B���̃J���[�}�b�v�́A�������� N �̃J
%   ���[���������Ă��܂���B
%
%   [Y,NEWMAP] = IMAPPROX(X,MAP,TOL) �́AX �� MAP �̒��̃J���[����l��
%   �q���@�ɂ��ߎ����܂��BNEWMAP �́A��������(FLOOR(1/TOL)+1)^3 �F��
%   ���܂�ł��܂���BTOL �́A0��1.0�̊Ԃ̒l�ł��B
%
%   Y = IMAPPROX(X,MAP,NEWMAP) �́AMAP �̒��̃J���[�Ɉ�ԃ}�b�`�����
%   ���� NEWMAP �̒��̃J���[�����߂邽�߂ɁA�J���[�}�b�s���O���g���āA
%   MAP �̒��̃J���[���ߎ����܂��B
%
%   Y = IMAPPROX(...,DITHER_OPTION) �́A�f�U�����O��K�p���邩�ǂ�����
%   �ݒ肵�܂��BDITHER_OPTION �ɂ́A���̂����ꂩ�̕������ݒ肷�邱
%   �Ƃ��ł��܂��B
%
%       'dither'   �K�v�Ȃ�΁A��ԓI�ȉ𑜓x���]���ɂ��āA�J���[�̉�
%                  ���x�����߂邽�߂Ƀf�U�����O��K�p(�f�t�H���g)
%
%       'nodither' �I���W�i���C���[�W�̊e�J���[���A�V�����}�b�v�̍ł�
%                  �߂��J���[�Ƀ}�b�s���O�B�f�U�����O�͓K�p����܂�
%                  ��B
%
% �N���X�T�|�[�g
% -------------
%   ���̓C���[�W X �́Auint8�Auint16�A�܂��́Adouble �̂�����̃N���X
%   ���T�|�[�g���Ă��܂��B�o�̓C���[�W Y �́ANEWMAP �̒�����256�ȉ���
%   �ꍇ�ɁA�N���X uint8 �ɂȂ�܂��BNEWMAP �̒�����256���傫���ꍇ
%   �ɂ́AX �̓N���X double �ɂȂ�܂��B
%
% �Q�l : CMUNIQUE, DITHER, RGB2IND



%   Copyright 1993-2002 The MathWorks, Inc.  
