% FITGAIN �́A�ʑ����Ȃ��Ɏ��g�������Ȑ��̋ߎ�(PSD �@)
%
% [SS_] = FITGAIN(MAG,W,ORD,WT,FLAG)�A�܂��́A
% [A,B,C,D] = FITGAIN(MAG,W,ORD,WT,FLAG) �́A�A���V�X�e���̃Q�C���Ȑ� 
% "MAG" ��"�����"��ԋ�Ԏ������쐬���܂��B
%
%    ���́F
%               mag ---- �Q�C���̐�Βl����Ȃ�z��
%               w   ---- "mag"���v�Z������g�� (rad/sec)
%               ord ---- �����̃T�C�Y
%    �I�v�V�����F
%               wt  ---- �Ȑ��ߎ��̏d�ݕt��(�f�t�H���g = ones(w))
%               flag --- Bode ���}��\��(�f�t�H���g), 0: Bode ���}��\��
%                        ���Ȃ�
%
%    �o�́F (a,b,c,d) ---- "MAG" �̈������
%
%  �A���S���Y���́A����3�X�e�b�v����\������Ă��܂��B
%                         2
%                   |G(s)|   = G(s) * G(-s)
%    �X�e�b�v1�FG(s) �� PSD ���v�Z�A���Ȃ킿�APSD = |G(s)|^2 �����s
%    �X�e�b�v2�FMATLAB �֐� "invfreqs.m"���g���āAPSD ��L���֐��ŋߎ���
%               �܂��B
%    �X�e�b�v3�F�����̒��̈���A�ŏ��ʑ����𒊏o
%                          (�I�� !!)

% Copyright 1988-2002 The MathWorks, Inc. 
