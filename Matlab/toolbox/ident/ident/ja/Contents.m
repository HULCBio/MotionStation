% System Identification Toolbox
% Version 6.0.1 (R14) 05-May-2004
%
% �V�@�\
%   Readme      - System ID Toolbox �Ɋւ���d�v�ȃ����[�X��� 
%                 (Readme �t�@�C�����_�u���N���b�N���邩�A"whatsnew di-
%                  rectoryname"�A���Ȃ킿�A"whatsnew ident" �ƃ^�C�v�C��
%                  ���Ă�������)�B
%
% �w���v
%   idhelp     - �ȒP�ȃ}�j���A���B�n�߂�ɂ́A"help idhelp" �Ɠ��͂���
%                ���������B
% �f��
%   iddemo     - �c�[���{�b�N�X�̎g�����̃f�����X�g���[�V����
%
% �O���t�B�J�����[�U�C���^�t�F�[�X
%   ident      - ����Ɖ�͂̓�����
%   midprefs   - �X�^�[�g�A�b�v���t�@�C���̑��݃f�B���N�g���̒�`
%
% �V�~�����[�V�����Ɨ\��
%   predict    - M �i��\��
%   pe         - �\���덷�̎Z�o
%   sim        - �V�X�e���̃V�~�����[�V����
%
% �f�[�^����
%   iddata     - �f�[�^�I�u�W�F�N�g�̍쐬
%   detrend    - �f�[�^�Z�b�g����̃g�����h�̏���
%   idfilt     - �o�^�[���[�X�t�B���^�ɂ��t�B���^�����O
%   idinput    - ��������̂��߂̓��͐M���̐���
%   merge      - ���������f�[�^�̃}�[�W
%   misdata    - �����f�[�^�̐���ƕ��
%   resample   - �Ԉ����ƕ�Ԃɂ��f�[�^�̃��T���v�����O
%
% �m���p�����g���b�N����
%   covf       - �f�[�^�s��ɑ΂��鋤���U�֐��̐���
%   cra        - ���։��
%   etfe       - �����I�ȓ`�B�֐��ƃs���I�h�O�����̎Z�o
%   impulse    - �C���p���X�����̒��ړI�Ȑ���
%   spa        - �X�y�N�g�����
%   step       - �X�e�b�v�����̒��ړI�Ȑ���
%
% �p�����[�^����
%   ar         - �l�X�ȃA�v���[�`�𗘗p���Ă̐M���� AR ���f���̐���
%   armax      - �\���덷�@�ɂ�� ARMAX ���f���̐���
%   arx        - �ŏ����@�ɂ�� AR ���f���̐���
%   bj         - �\���덷�@�ɂ�� Box-Jenkins ���f���̐���
%   ivar       - �⏕�ϐ��@�ɂ��X�J�����n��� AR ���f���̐���
%   iv4        - �ߎ��I�ɍœK��4�X�e�[�W�⏕�ϐ��@�ɂ�� ARX ���f���̐�
%                ��
%   n4sid      - ������Ԗ@�ɂ���ԋ�ԃ��f���̐���
%   oe         - �\���덷�@�ɂ��o�͌덷���f���̐���
%   pem        - �\���덷�@�ɂ���ʓI�Ȑ��`���f���̐���
%
% ���f���\���̍쐬
%   idpoly     - �^����ꂽ���������烂�f���I�u�W�F�N�g�̍쐬
%   idss       - ��ԋ�ԃ��f���I�u�W�F�N�g�̍쐬
%   idarx      - ���ϐ� ARX ���f���I�u�W�F�N�g�̍쐬
%   idgrey     - ���[�U�ݒ�̃p�����[�^�����ꂽ���f���I�u�W�F�N�g�̍쐬
%
% ���f���̕ϊ�
%   arxdata    - ���f���� (�K�p�\�ȏꍇ)ARX �s��ɕϊ�
%   polydata   - �^����ꂽ���f���Ɋ֘A����������
%   ssdata     - IDMODEL ����ԋ�Ԃɕϊ�
%   tfdata     - IDMODEL ��`�B�֐��ɕϊ�
%   zpkdata    - ��_�A�ɁA�ÓI�Q�C���A���̕W���΍�
%   idfrd      - ���f���̎��g���֐��Ƃ��̋����U
%   idmodred   - ���f���̒᎟����
%   c2d, d2c   - �A��/���U�̕ϊ�
%   ss, tf, zpk, frd - CSTB �� LTI �I�u�W�F�N�g�ւ̕ϊ�
%   CSTB �ϊ����[�`���́A�قƂ�ǂ�SITB�̃��f���I�u�W�F�N�g�ɑ΂��ēK�p
%   �ł��܂��B
%
% ���f���\��
%   bode       - �`�B�֐��A�܂��́A�X�y�N�g���� Bode ���}(�s�m�����t��)
%   ffplot     - ���g���֐�(�s�m�����t��)
%   plot       - �f�[�^�I�u�W�F�N�g�̓���-�o�̓f�[�^�̃v���b�g
%   present    - �s�m�����t���̃��f���\��
%   pzmap      - ��_�Ƌ�(�s�m�����t��)
%   nyquist    - �`�B�֐��� Nyquist ���}(�s�m�����t��)
%   view       - LTI�r���[�A(CSTB�̃��f���I�u�W�F�N�g�ɑ΂���)
%
% ���f���̌���
%   compare    - �V�~�����[�V����/�\���o�͂Ɗϑ��f�[�^�̔�r
%   pe         - �\���덷
%   predict    - M-�i��\��
%   resid      - ���f���̎c���̐���ƃe�X�g
%   sim        - �^����ꂽ�V�X�e���̃V�~�����[�V����(�s�m�����t��)
%
% ���f���\���̑I��
%   aic, fpe   - �Ԓr�̏��K�͂ƍŏI�\���K�͂̌v�Z
%   arxstruc   - �قȂ� ARX ���f���\���ɑ΂��鑹���֐��̌v�Z
%   selstruc   - ���܂��܂ȋK�͂ɏ����郂�f���\���̑I��
%   struc      - ARXSTRUC �̂��߂̃��f���\���̍쐬



%   Copyright 1986-2004 The MathWorks, Inc.
