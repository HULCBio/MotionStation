% GETXPCPCI �́A�^�[�Q�b�g PC �ɃC���X�g�[������Ă��� PCI �{�[�h���`�F�b
% �N���܂��B
% 
% GETXPCPCI �́A�C���X�g�[�����ꂽ PCI �f�o�C�X(�{�[�h)�����^�[�Q�b�g��
% ��擾���A�R�}���h�E�C���h�E�ɁA���o���ꂽ PCI �f�o�C�X�Ɋւ������\
% �����܂��BxPC Target �u���b�N���C�u�����̃h���C�o�u���b�N�ɂ��T�|�[�g
% ����Ă���f�o�C�X�̂ݕ\������܂��B���́APCI �o�X�ԍ� �A�X���b�g�ԍ�
% ���蓖�Ă�ꂽ IRQ �ԍ��A�x���_�[���A�f�o�C�X(�{�[�h)���A�f�o�C�X�^�C�v
% �x���_�[ PCI Id�A�f�o�C�X PCI Id ���g���܂�ł��܂��B�z�X�g�ƃ^�[�Q�b�g
% �̒ʐM�����N���@�\���Ă���ꍇ(xpctargetping �́AGETXPCPCI ���ǂݍ��܂�
% ��O�ɁASUCCESS ���o��)�̂݁A��񂪎擾�ł��܂��BTarget �A�v���P�[�V����
% �����[�h����Ă���A�܂��́A���[�_���A�N�e�B�̏ꍇ �̂݁AGETSPCPCI �́A
% ���s����܂��B��҂̏ꍇ�A�ŗL�� PCI �f�o�C�X�Ɋ��蓖�Ă�ꂽ���\�[�X��
% ����擾����ɂ́APCI �f�o�C�X�����f���r���h�v���Z�X���O�Ƀh���C�o�[�u
% ���b�N�_�C�A���O�{�b�N�X�֒񋟂���Ȃ���΂Ȃ�܂���B����́APCI�o�X��
% ���A�X���b�g�ԍ��A���蓖�Ă�ꂽ IRQ �ԍ����܂�ł��܂��B
% 
% PCIDEVS = ETXPCPCI �́A�������ʂ��A�\�����邩���ɁA�\���� PCIDEVS �ɏo
% �͂��܂��BPCIDEVS �́A���o���ꂽ�A�e�X�� PCI �f�o�C�X�ɑ΂��āA��̗v
% �f�����\���̔z��ł��B�e�v�f�́A�t�B�[���h���̃Z�b�g�ŏ���g�ݍ��킹
% �Ă��܂��B�\���̂́A�\�����ꂽ���X�g�Ɣ�ׁA���蓖�Ă�ꂽ�x�[�X�A�h���X
% ��x�[�X�N���X�A�T�u�N���X���́A��葽���̏����܂�ł��܂��B
% 
% GETXPCPCI('all') �́AxPC Target �u���b�N���C�u�����ŃT�|�[�g����Ă���f
% �o�C�X�����łȂ��A���ׂ�ꂽ���ׂĂ� PCI �f�o�C�X�ɂ��Ă̏���\����
% �܂��B����́AGraphics Controller �� Neywork Cards �� SCSI �J�[�h���܂�
% �ł��āA�}�U�[�{�[�h�̃`�b�v�Z�b�g�̈ꕔ�������܂�ł��܂�(���Ƃ��΁APCI
% -to-PCI �u���b�W)�B
% 
% PCIDEVS = GETXPCPCI('all') �́A�������ʂ�\���������ɁA�\���̂̒���
% �o�͂��܂��B
% 
% GETXPCPCI('supported') �́AxPC Target �u���b�N���C�u�����ŃJ�����g�ɃT�|
% �[�g����Ă��� PCI �f�o�C�X�̂��ׂĂ�\�����܂��BGETXPCPCI �́A���̏ꍇ
% �^�[�Q�b�g PC ���A�N�Z�X���܂���B���̂��߁A�z�X�g�|�^�[�Q�b�g�Ԃ̒ʐM��
% ���̓_�E���̏�ԂɂȂ�܂��B
% 
% PCIDEVS = GETXPCPCI('supported') �́A�T�|�[�g����Ă��� PCI �f�o�C�X��\
% ���������ɁA�\���̂Ƃ��ďo�͂��܂��B

%   Copyright 1994-2002 The MathWorks, Inc.
