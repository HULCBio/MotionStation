% LMI Control Toolbox
% Version 1.0.9 (R14) 05-May-2004
%
%             A. ��͂Ɛ݌v�̂��߂̃c�[��
%             ----------------------------
%
% �m�~�i�����\�̕]��
%    norminf     - �A�����ԃV�X�e����RMS/Hinf�Q�C��
%    dnorminf    - ���U���ԃV�X�e����RMS/Hinf�Q�C��
%    norm2       - �A�����ԃV�X�e����H2�m����
%
% ���o�X�g�����
%    quadstab    - 2�����萫
%    quadperf    - 2��Hinf���\
%    pdlstab     - �p�����g���b�N��Lyapunov�֐��ɂ�郍�o�X�g���萫
%    popov       - ���o�X�g���萫�ɑ΂���Popov�
%    decay       - 2��������
%    mubnd       - �\�������ْl�̏�E
%    mustab      - ���o�X�g����]�T(mu)
%    muperf      - ���o�X�gHinf���\(mu)
%
% Hinf�̐݌v- �A������
%    msfsyn      - ���ړI��ԃt�B�[�h�o�b�N�݌v
%    hinflmi     - LMI�x�[�X��Hinf�݌v
%    hinfmix     - �ɔz�u���g����H2/Hinf�����݌v
%    lmireg      - �ɔz�u�ɑ΂���LMI�̈�̐ݒ�
%    hinfric     - Riccati�x�[�X��Hinf�݌v
%
% Hinf�̐݌v- ���U����
%    dhinflmi    - LMI�x�[�X��Hinf�݌v
%    dhinfric    - Riccati�x�[�X��Hinf�݌v
%
% ���[�v���`
%    magshape    - ���`�t�B���^�݌v�̂��߂�GUI
%    sconnect    - ��ʓI�Ȑ��䃋�[�v�̐ݒ�
%    frfit       - ���g�������f�[�^�̗L���ߎ�
%
% �Q�C���X�P�W���[�����O
%    hinfgs      - �Q�C���X�P�W���[�����OHinf�݌v
%    pdsimul     - �^����ꂽ�p�����[�^�O���ɉ��������ԉ���
%
% �f��
%    sateldem    - �q���̏�ԃt�B�[�h�o�b�N�R���g���[��
%    radardem    - ���[�_�A���e�i�̃��[�v���`�݌v
%    misldem     - �~�T�C���̃I�[�g�p�C���b�g�̃Q�C���X�P�W���[�����O��
%                  ��
%
%
%          B. �s�m�������`�V�X�e��
%          -------------------------------------------
%
% ���`���s�σV�X�e��
%    ltisys      - ��ԋ�ԃ��f����SYSTEM�s��Ƃ��Ċi�[
%    ltiss       - SYSTEM�s�񂩂��ԋ�ԃf�[�^�𒊏o
%    ltitf       - SISO�V�X�e���̓`�B�֐��̌v�Z
%    islsys      - SYSTEM�s�񂩂ǂ������e�X�g
%    sinfo       - �V�X�e���̏��
%    sresp       - �V�X�e���̎��g������
%    spol        - �V�X�e���̋ɂ̎Z�o
%    ssub        - �T�u�V�X�e���̒��o
%    sinv        - �t�V�X�e�����v�Z
%    sbalanc     - ��ԋ�Ԏ����̐��l�I���t��
%    splot       - ���ԉ����Ǝ��g�������̃v���b�g
%
% �|���g�s�b�N�V�X�e���A�܂��́A�p�����[�^�ˑ��V�X�e��(P-�V�X�e��)
%    psys        - P-�V�X�e���̐ݒ�
%    psinfo      - P-�V�X�e���Ɋւ�����̏o��
%    ispsys      - P-�V�X�e���ł��邩�ǂ������e�X�g
%    pvec        - �s�m�����A�܂��́A���σp�����[�^�̃x�N�g���̐ݒ�
%    pvinfo      - �p�����[�^�x�N�g���̋L�q�̓ǂݍ���
%    polydec     - �p�����[�^�{�b�N�X�̒[�_���w�肷��|���g�s�b�N���W
%    aff2pol     - P-�V�X�e���ɑ΂���A�t�B��/�|���g�s�b�N�ϊ�
%    pdsimul     - �p�����[�^�O���ɉ�����P-�V�X�e�����V�~�����[�V����
%
% ���I�s�m����
%    ublock      - �s�m�����u���b�N�̐ݒ�
%    udiag       - �u���b�N�Ίp�ȕs�m�����̐ݒ�
%    uinfo       - �u���b�N�Ίp�ȕs�m�����̋L�q��\��
%    aff2lft     - �A�t�B��P-�V�X�e���̐��`�����\��
%
% �V�X�e���̑��ݐڑ�
%    sdiag       - ���`�V�X�e���̕t��
%    sderiv      - ���-������
%    sadd        - �V�X�e���̕��񌋍�
%    smult       - �V�X�e���̒��񌋍�
%    sloop       - �t�B�[�h�o�b�N���[�v
%    slft        - ���`�����t�B�[�h�o�b�N���ݐڑ�
%    sconnect    - �W�����䃋�[�v�̌���
%



% Copyright 1995-2004 The MathWorks, Inc. 
