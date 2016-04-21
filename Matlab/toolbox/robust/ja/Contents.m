% Robust Control Toolbox
% Version 2.0.10 (R14) 05-May-2004
%
%
% �V�@�\
%   Readme     - Robust Toolbox�Ɋւ���d�v�ȃ����[�X���
%                (Readme���_�u���N���b�N���邩�A"whatsnew directoryname"
%                �ƃ^�C�v���Ă��������B���Ƃ��΁A"whatsnew robust"��
%                �^�C�v����ƁA���̃t�@�C����\�����܂�)�B
%
% �V�X�e���f�[�^�\���ɕt���������
%    branch    - �c���[����\���v�f�̎��o��
%    graft     - �c���[�f�[�^�֒ǉ�
%    issystem  - �V�X�e���ϐ��̃`�F�b�N
%    istree    - �c���[�ϐ��̃`�F�b�N
%    mksys     - �V�X�e���̃c���[�ϐ��̍쐬
%    tree      - �c���[�ϐ��̍쐬
%    vrsys     - �W���V�X�e���ϐ����̏o��
%
% ���f���쐬
%    augss     - �v�����g�̊g��(��ԋ�ԃ��f��)
%    augtf     - �v�����g�̊g��(�`�B�֐�)
%    interc    - ��ʓI�ȑ��ϐ��V�X�e���̑��݌���
%
% ���f���̕ϊ�
%    bilin     - ���ϐ��o�ꎟ�ϊ�
%    des2ss    - ���ْl�����ɂ��f�B�X�N���v�^�V�X�e���̏�ԋ�ԕ\����
%                �̕ϊ�
%    lftf      - ���`�����ϊ�
%    sectf     - �Z�N�^�ϊ�
%    stabproj  - ����/�s���胂�[�h����
%    slowfast  - slow/fast���[�h����
%    tfm2ss    - �`�B�֐�����ԋ�ԕ\���ɕϊ�
%
% ���[�e�B���e�B
%    aresolv   - ��ʉ��A������Riccati�\���o
%    daresolv  - ��ʉ����U����Riccati�\���o
%    riccond   - �A������Riccati�������̏�����
%    driccond  - ���U����Riccati�������̏�����
%    blkrsch   - �֐�cschur�ɂ��u���b�N�̏����ɂ���Schur����
%    cschur    - ���fGivens��]�ɂ�鏇���t����ꂽ���fSchur����
%
% ���ϐ�Bode�v���b�g
%    cgloci    - �A���n�̓����Q�C���O��
%    dcgloci   - ���U�n�̓����Q�C���O��
%    dsigma    - ���U�n�̓��ْlBode�v���b�g
%    muopt     - ����/���f�������̕s�m���������V�X�e���̍\�������ْl��
%                ��E(Michael Fan��MUSOL4)
%    osborne   - Osborne�@�ɂ��\�������ْl(SSV)�̏�E
%    perron    - Perron�@�ɂ��ŗL�\��SSV
%    psv       - Perron�@�ɂ��ŗL�\��SSV
%    sigma     - �A���n�̓��ْlBode�v���b�g
%    ssv       - �\�������ْl��Bode�v���b�g
%
% ����
%    iofc      - inner-outer����(��^�C�v)
%    iofr      - inner-outer����(�s�^�C�v)
%    sfl       - ���X�y�N�g������
%    sfr       - �E�X�y�N�g������
%
% ���f�������̒᎟����
%    balmr     - ���t���Ő؂�@�ɂ�郂�f���̒᎟����
%    bstschml  - Schur�@�ɂ�鑊�Ό덷���f���᎟����
%    bstschmr  - Schur�@�ɂ�鑊�Ό덷���f���᎟����
%    imp2ss    - �C���p���X���������ԋ�ԕ\���ւ̕ϊ�
%    obalreal  - �����t�����t������
%    ohklmr    - �œKHankel�ŏ������ߎ�
%    schmr     - Schur�@�ɂ�郂�f���̒᎟����
%
% ���o�X�g����n�݌v�@
%    h2lqg     - �A������H_2����n�݌v
%    dh2lqg    - ���U����H_2����n�݌v
%    hinf      - �A������H_������n�݌v
%    dhinf     - ���U����H_������n�݌v
%    hinfopt   - ��-�C�^���[�V�����ɂ��H_���V���Z�V�X
%    normh2    - H_2�m�����̌v�Z
%    normhinf  - H_���m�����̌v�Z
%    lqg       - LQG�œK����V���Z�V�X
%    ltru      - LQG���[�v���J�o��
%    ltry      - LQG���[�v���J�o��
%    youla     - Youla�p�����g���[�[�V����
%
% �f�����X�g���[�V����
%    accdemo   - �o�l-�}�X�n�̃x���`�}�[�N���
%    dintdemo  - ��d�ϕ��v�f�����v�����g��H���݌v
%    hinfdemo  - H_2 & H���݌v�̗�
%                   �퓬�@�Ƒ�^�F���\����
%    ltrdemo   - LQG/LTR �݌v��-�퓬�@
%    mudemo    - mu�V���Z�V�X�̗��
%    mudemo1   - mu�V���Z�V�X�̗��
%    mrdemo    - ���o�X�g�K�͂���Ƀ��f���̒᎟����
%    rctdemo   - Robust control toolbox�̃f�� - ���C�����j���[
%    musldemo  - MUSOL4�̃f��


% Copyright 1988--2004 The MathWorks, Inc.
