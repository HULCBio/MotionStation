% FITD �́A�ݒ肵�� Bode ���}�̏�ԋ�Ԏ������s�Ȃ��܂��B
%
% [SS_D,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG)
% [AD,BD,CD,DD,LOGDFIT] = FITD(LOGD,W,N,BLKSZ,FLAG) �́A�s�� LOGD �̍s��
% �^����ꂽ Bode ���}�̃Q�C���f�[�^�ɋߎ��I�ɓK������Ίp�`�B�֐��s���
% ����ȍŏ��ʑ���ԋ�Ԏ��� SS_D ���o�͂��܂��B���l�I�Ɉ���ȃ��[�`�� 
% "YLWK.M"���g���܂��B
%
%   ����:        LOGD  �s��̍s�́ABode���}�̃Q�C���v���b�g�̃��O�ł��B
%                W �́A���g���x�N�g���ł��B
%   �I�v�V����: N �́A�ߎ��Ɏg�p�����]���鎟����\���x�N�g��
%               (�f�t�H���g = 0);
%               BLKSZ �́ASS_D �̒��̑Ίp�s��̃T�C�Y�������x�N�g��
%               (�f�t�H���g = 1);
%                FLAG (�f�t�H���g�FBode ���}�̕\��; 0: Bode ���}��\����
%                �܂���);
%       ?????? Bode plot of the fit will be displayed 4 at a time
%              with a "pause" in between every full screen display.
% 
%   �o��:      SS_D �́A�Ίp�`�B�֐��s�� D(s) =diag(d1(s)I1,...,dn(s)In)
%              �̏�ԋ�Ԏ����ł��B�����ŁAdi(s) �́ALOGD �� i �Ԗڂ̍s
%              �ւ̋ߎ��ŁAI1,...In �́An �x�N�g�� BLKSZ �̒��ŗv�f�Ƃ�
%              �ė^������傫�������P�ʍs��ł��B
%              LOGDFIT �́ALOGD�A���Ȃ킿�ASS_D �� Bode ���}�ւ̋ߎ�����
%              ��ł��܂��B

% Copyright 1988-2002 The MathWorks, Inc. 
