% HISTEQ   �q�X�g�O�����̋ϓ������g���ăR���g���X�g������
%   HISTEQ �́A���x�C���[�W�̒l�A�܂��́A�C���f�b�N�X�t���C���[�W�̃J
%   ���[�}�b�v�̒l���A�o�̓C���[�W�̃q�X�g�O�������ݒ肵���q�X�g�O����
%   �ɋߎ��I�Ɉ�v����悤�ɕϊ����邱�Ƃɂ��A�C���[�W�̃R���g���X�g
%   ���������܂��B
%
%   J = HISTEQ(I,HGRAM) �́Alength(HGRAM) �̃r�������o�̓C���[�W J
%   �̃q�X�g�O�������A�ߎ��I�� HGRAM �ƈ�v����悤�ɁA���x�C���[�W I 
%   ��ϊ����܂��B�x�N�g�� HGRAM �́A�K�؂Ȕ͈�(�N���X double �ł�
%   [0,1]�A�N���X uint8 �ł�[0,255]�A�N���X uint16 �ł�[0,65535])��
%   �ŁA���x�l�������Ԋu�ɕ��z�����r���ɑ΂��鐮���J�E���g���܂�ł�
%   �܂��BHISTEQ �́Asum(HGRAM) = prod(size(I)) �ƂȂ�悤�ɁA�����I��
%   �X�P�[�����O���s���܂��BJ �̃q�X�g�O�����́Alength(HGRAM) �� I ��
%   ���U���x���������������Ƃ��� HGRAM �ƈ�v�x�����܂�܂��B
%
%   J = HISTEQ(I,N) �́A���x�C���[�W I ��ϊ����āAN �̗��U���x����
%   �����x�C���[�W�Ƃ��� J �ɏo�͂��܂��B�s�N�Z���̒��ő�܂��ɓ���
%   ���Ǝv���鐔�l�́AJ �̃q�X�g�O�������ߎ��I�Ƀt���b�g�ɂȂ�悤
%   �ɁAJ �̒��� N ���x���ɕ������ꂽ���̂̊e�X�Ƀ}�b�s���O����܂�(J 
%   �̃q�X�g�O�����́AN �� I �̒��̗��U���x������菭�Ȃ��Ƃ��ɁA���
%   �t���b�g�ɂȂ�܂��j�BN �̃f�t�H���g�l�́A64�ł��B
%
%   [J,T] = HISTEQ(I) �́A���x�C���[�W I �̃O���[���x���� J �̃O���[��
%   �x���Ƀ}�b�s���O����O���[�X�P�[���ϊ����o�͂��܂��B
%
%   NEWMAP = HISTEQ(X,MAP,HGRAM) �́A�C���f�b�N�X�t���C���[�W
%   (X,NEWMAP)�̃O���[�����̃q�X�g�O�������AHGRAM �ɋߎ��I�Ɉ�v�����
%   ���ɃC���f�b�N�X�t���C���[�W X �Ɋ֘A�����J���[�}�b�v��ϊ�����
%   ���BHISTEQ �́ANEWMAP �ɕϊ����ꂽ�J���[�}�b�v���o�͂��܂��B
%   length(HGRAM) �́Asize(MAP,1) �ƈ�v���Ȃ���΂Ȃ�܂���B
%
%   NEWMAP = HISTEQ(X,MAP) �́A�C���f�b�N�X�t���C���[�W X �̃O���[����
%   �̃q�X�g�O�������ߎ��I�Ƀt���b�g�ɂȂ�悤�ɃJ���[�}�b�v�̒l��ϊ�
%   ���܂��B�ϊ����ꂽ�J���[�}�b�v�́ANEWMAP �ɏo�͂���܂��B
%
%   [NEWMAP,T] = HISTEQ(X,...) �́AMAP �̃O���[������ NEWMAP �̃O���[
%   �����Ƀ}�b�s���O����悤�ɃO���[�X�P�[���ϊ����o�͂��܂��B
%
%   �N���X�T�|�[�g
% -------------
%   ���͂Ƃ��ċ��x�C���[�WI���܂�ł���\���ɑ΂��āAI �́Auint8�A
%   uint16�A�܂��́Adouble �̂�����̃N���X���T�|�[�g���Ă��܂��B����
%   �āA�o�̓C���[�W J �� I �Ɠ����N���X�ɂȂ�܂��B���͂Ƃ��ăC���f�b
%   �N�X�t���C���[�W X ���܂�ł���\���ɑ΂��āAX �́A�N���X uint8 �A
%   �܂��́Adouble �̂ǂ�����T�|�[�g���Ă��܂��B�o�̓J���[�}�b�v�́A
%   �K���N���X double �ł��B�܂��A�I�v�V�����o�� T(�O���[���x���ϊ�)��
%   ��ɃN���X double �ł��B
%
%   ���
%   ----
%   �q�X�g�O�����̋ϓ������g���āA���x�C���[�W�̃R���g���X�g�̋������s
%   ���܂��B
%
%       I = imread('tire.tif');
%       J = histeq(I);
%       imshow(I), figure, imshow(J)
%
%   �Q�l : BRIGHTEN, IMADJUST, IMHIST



%   Copyright 1993-2002 The MathWorks, Inc.  
