% Fuzzy Logic Toolbox
% Version 2.1.3 (R14) 05-May-2004
%
% GUI �G�f�B�^
% anfisedit  - ANFIS �P���ƌ��ؗp��UI�c�[��
% findcluster- �N���X�^�����O UI �c�[��
% fuzzy      - ��{��FIS�G�f�B�^
% mfedit     - �����o�V�b�v�֐��G�f�B�^
% ruleedit   - ���[���G�f�B�^�ƕ��@�̎g����
% ruleview   - ���[���r���[�A�ƃt�@�W�B���_�_�C�A�O����
% surfview   - �o�̓T�[�t�F�X�r���[�A
%
% �����o�V�b�v�֐�
% dsigmf     - 2�̃V�O���C�h�����o�V�b�v�֐��̍�
% gauss2mf   - 2�̃K�E�X�Ȑ������킹�������o�V�b�v�֐�
% gaussmf    - �K�E�X�Ȑ������o�V�b�v�֐�
% gbellmf    - ��ʉ����ꂽ�x���Ȑ������o�V�b�v�֐�
% pimf       - �Ό^�Ȑ������o�V�b�v�֐�
% psigmf     - 2�̃V�O���C�h�����o�V�b�v�֐��̐�
% smf        - S�^�Ȑ������o�V�b�v�֐�
% sigmf      - �V�O���C�h�Ȑ������o�V�b�v�֐�
% trapmf     - ��`�����o�V�b�v�֐�
% trimf      - �O�p�`�����o�V�b�v�֐�
% zmf        - Z�^�Ȑ������o�V�b�v�֐�
%
% �R�}���h���C��FIS�֐�
% addmf      - �����o�V�b�v�֐���FIS�ɒǉ�
% addrule    - ���[���� FIS �ɒǉ�
% addvar     - �ϐ��� FIS �ɒǉ�
% defuzz     - �����o�V�b�v�֐��̔�t�@�W�B��
% evalfis    - �t�@�W�B���_�v�Z�̎��s
% evalmf     - ��{�I�ȃ����o�V�b�v�֐��v�Z
% gensurf    - FIS �o�̓T�[�t�F�X�̌v�Z
% getfis     - �t�@�W�B�V�X�e���v���p�e�B�̎擾
% mf2mf      - �֐��Ԃł̃p�����[�^�̕ϊ�
% newfis     - �V���� FIS �̍쐬
% parsrule   - �t�@�W�B���[���̕��@����
% plotfis    - FIS �̓��́|�o�̓_�C�A�O�����̕\��
% plotmf     - 1�̕ϐ��Ɉˑ����邷�ׂẴ����o�V�b�v�֐��̕\��
% readfis    - �f�B�X�N���� FIS �̓ǂݍ���
% rmmf       - �����o�V�b�v�֐��� FIS ����폜
% rmvar      - �ϐ��� FIS ����폜
% setfis     - �t�@�W�B�V�X�e���v���p�e�B�̐ݒ�
% showfis    - ���ߕt���� FIS �̕\��
% showrule   - FIS ���[���̕\��
% writefis   - FIS ���f�B�X�N�ɕۑ�
%
% �A�h�o���X�g��@
% anfis      - ����^�C�v�� FIS �̌P�����[�`�� (MEX �̂�)
% fcm        - �t�@�W�B c-means �N���X�^�����O��p�����N���X�^�̌��o
% genfis1    - ��ʓI�Ȏ�@�ɂ�� FIS �s��̍쐬
% genfis2    - ���o�N���X�^�����O��p���� FIS �s��̍쐬
% subclust   - ���o�N���X�^�����O��p�����N���X�^�Z���^�̌��o
%
% ���̑��̊֐�
% convertfis - v1.0�t�@�W�B�s�񂩂�v2.0�t�@�W�B�\���̂ւ̕ϊ�
% discfis    - �t�@�W�B���_�V�X�e���̗��U��
% evalmmf    - �����̃����o�V�b�v�֐��̕]��
% fstrvcat   - �l�X�ȃT�C�Y�̍s��̘A��
% fuzarith   - �t�@�W�B���Z�֐�
% findrow    - ���͕�����ƈ�v����s���s�񂩂猟�o
% genparam   - ANFIS �w�K�̂��߂̏����̑O���p�����[�^�̍쐬
% probor     - �m���I OR
% sugmax     - ����V�X�e���̍ő�o�͔͈�
%
% GUI�⏕�֐�
% cmfdlg     - �J�X�^�}�C�Y���ꂽ�����o�V�b�v�֐���ǉ�����_�C�A���O
% cmthdlg    - �J�X�^�}�C�Y���ꂽ���_���@��ǉ�����_�C�A���O
% fisgui     - Fuzzy Logic Toolbox �̈�ʓI��GUI�̃n���h�����O
% gfmfdlg    - �O���b�h�ɂ���؂�@���g���� FIS �̐݌v�_�C�A���O
% mfdlg      - �����o�V�b�v�֐���ǉ�����_�C�A���O
% mfdrag     - �}�E�X���g���������o�V�b�v�֐��̃h���b�O
% popundo    - �Ō�� FIS �ύX�̎������X�^�b�N����̃|�b�v�I�t
% pushundo   - �J�����g�� FIS �̎������X�^�b�N�ւ̃v�b�V��
% savedlg    - �_�C�A���O�����O�ɕۑ�
% statmsg    - �X�e�[�^�X�t�B�[���h�ւ̃��b�Z�[�W�̕\��
% updtfis    - Fuzzy Logic Toolbox GUI �c�[���̍X�V
% wsdlg      - ���[�N�X�y�[�X�Ƀf�[�^��ǂݍ��񂾂�A�f�[�^���Z�[�u����
%              �_�C�A���O�̃I�[�v��


%   Copyright 1994-2004 The MathWorks, Inc.



