% SLDIAGNOSTICS   ���f���̃R���p�C���ɗv����u���b�N�A�傫���A���ԁA ��������
% �J�E���g
%
%
% SLDIAGNOSTICS(MDL) �́A���f���̒��̃u���b�N�^�C�v���J�E���g���A���f���̍\��
% �����߂��܂��B �\�����߂ł́A���f�����s�O�̏����̊e�i�K�ŗv������鎞�Ԃƃ�
% �����̗ʂ��e�L�X�g���|�[�g�Ƃ��ďo�͂��܂��B���f���́AMATLAB�p�X��ɑ��݂���
% ����A�J�����g�Ƀ��[�h����Ă�����̂łȂ��Ă��\���܂���B�������̎g�p������
% ���߁A���[�U�́A-check_malloc�t���O�t���ŁAMATLAB�����s���Ă��������B
% Windows�v���b�g�t�H�[����ł́A"�X�^�[�g���j���[" ���� "�t�@�C�������w�肵��
% ���s" ��I�����Amatlab.exe -check_malloc �Ɠ��͂��܂��BUnix�v���b�g�t�H�[��
% �ŁA�A�N�e�B�u�Ƀ������ǐՂ��s�Ȃ��ɂ́A'matlab -check_malloc' ���g���܂��B
% 'matlab -check_malloc'.
%
% SLDIAGNOSTICS(MDL,OPTIONS) �́AOPTIONS �̒��Ƀ��X�g�����e��������s����
% ���B OPTIONS �́A'CountBlocks', 'CompileStats', 'Sizes', 'Verbose', 'All'
% �̂����ꂩ�ŁA���̈Ӗ��������܂��B
%
% 'All'         - ���ׂĂ̐f�f���s�Ȃ��܂��B
%
% 'CountBlocks' - �V�X�e�����ɑ��݂��郆�j�[�N�ȃu���b�N���ƃ}�X�N�^�C�v�Ɋ�
%                 ����e�L�X�g���|�[�g���o�͂��܂��B
%  �V�X�e���́AMATLAB�p�X��ɑ��݂������A�J�����g�Ƀ��[�h�������̂łȂ���
% ���\���܂���B�}�X�N���ꂽ�T�u�V�X�e���̔C�ӂ̊K�w�܂Ō������邱�Ƃ��ł���
% ���B
%
% 'CountBlocks' - �V�X�e�����ɑ��݂��郆�j�[�N�ȃu���b�N���ƃ}�X�N�^�C�v�Ɋ�
%                 ����e�L�X�g���|�[�g���o�͂��܂��B
%
% 'CompileStats'- MDL �̊e�R���p�C���i�K�Ŏg�p�����t���I�ȃ������Ǝ��Ԃ�
% �e�L�X�g���|�[�g���o�͂��܂��B���f�����s�O�� ���߂� CompileStats �����s����
% ���ɂ́A��葽���� ��������K�v�Ƃ��܂����A����ȍ~�Ɏ��s�������ɂ́A MDL
% �̍����Ƃ��ėv������郁�����ʂł���A��菭�Ȃ��������ʂƂȂ�܂��B
%
%  �R���p�C�����ꂽstatics (CStat's) ���ASimulink �u���b�N���}�̃R���p�C����
% �d�v�Ȓi�K�̂��ꂼ��ŕ\������܂��B���̏��́A �J�X�^�}�̃��f���� �R���p
% �C�����x�̃g���u���V���[�g���w���v����ꍇ�A �����/���邢�̓������̖���
% �ꍇ�ɁAMathWorks�ɒ񋟂���܂��B���ʂƂ��ďo�͂���郁�����g�p�ʂ̏��ɂ�
% ��A���f���R���p�C���̓���̒i�K�ŁA�ǂ̒��x�̃��������g�p���Ă���̂�����
% ����܂��B
%
% 'Sizes'       - ��Ԑ��A���́A�o�́A�T���v�����ԁA���ڃt�B�[�h�X���[������ fl
%                 ag�A�Ȃǂ̃e�L�X�g�̕񍐂��o�͂��܂��B
%
% 'Libs'        - MDL �ŎQ�Ƃ���郉�C�u�����̃e�L�X�g�̕񍐂��o�͂��܂��B
%
% 'Verbose'     - �R���p�C���̎��s���ɃR�}���h�E�B���h�E�ɕ\������A���̌�e
%                 �L�X�g�o�͂𐶐����܂��B
% ���̕��@�́A�R���p�C�����g�ɕs���Ɏ��Ԃ�v������A�R���p�C�����Ƀn���O����
% �悤�ȃP�[�X�̐f�f�̍ۂɗL���ł��B
%
% [TXTRPT, SRPT] = SLCOUNTBLOCKS(MDL,'CountBlocks') �́A�e�L�X�g���|�[�g�ƃu
% ���b�N�J�E���g�v�Z�p�̃t�B�[���h 'ismask', 'type', 'count' �����\���̔z
% ����쐬���܂��B�u���b�N�J�E���g�́A�u���b�N�̃��j�[�N�ȃ^�C�v�̐��A�܂��́A
% �V�X�e���̒��Ɍ�������}�X�N�̂����ꂩ���o�͂��܂��B�V�X�e���́A
% MATLAB�p�X��ɑ��݂������A�J�����g�Ƀ��[�h�������̂łȂ��Ă��\���܂���B
% �T�[�`�́A�}�X�N���ꂽ�T�u�V�X�e���̔C�ӂ̊K�w�܂ő������܂��BStateflow�u
% ���b�N����ёg�ݍ���MATLAB �u���b�N�ɂ��ẮA����Ȍv�Z���p�����܂��B
%
% �Q�l : FIND_SYSTEM, GET_PARAM, SIMGET, SIMSET, SIM


% Copyright 1990-2004 The MathWorks, Inc.
