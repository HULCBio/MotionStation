% ANFIS   ����^�C�vFIS�̓K���j���[���t�@�W�[�P��
%
% ANFIS�͐���^�C�v�t�@�W�[���_�V�X�e��(FIS)�̒P�o�͂̃����o�V�b�v�֐�
% �p�����[�^�̓���ɁA�n�C�u���b�h�Ȋw�K�A���S���Y���𗘗p���܂��B
% �^����ꂽ���o�̓f�[�^�Ɋ�Â��A�ŏ����@�ƃo�b�N�v���p�Q�[�V�����ŋ}
% �~���@��g�ݍ�������@�Ń��f����FIS�����o�V�b�v�֐��̃p�����[�^�P����
% �s���܂��B
% 
% [FIS,ERROR] = ANFIS(TRNDATA) ��TRNDATA�ɃX�g�A���ꂽ���o�͊w�K�f�[�^��
% �p����FIS�p�����[�^���`���[�j���O���܂��BN���͂�FIS�̏ꍇ�ATRNDATA��
% N+1��̍s��ŁA�ŏ���N���FIS���́A�Ō�̗�ɏo�̓f�[�^�������܂��B
% ERROR�͊e�G�|�b�N�ɂ�����P���덷�iFIS�o�͂ƌP���f�[�^�̏o�͂Ƃ̍��j��
% ���ϓ�捪�̔z��ł��BANFIS��ANFIS�P���̊J�n�_�ɗ��p�����f�t�H���g
% FIS�쐬��GENFIS1��p���܂��B
%
% [FIS,ERROR] = ANFIS(TRNDATA,INITFIS) ��FIS�\���̂𗘗p���܂��BINITFIS��
% ANFIS�P���̊J�n�_�ł��B
%
% [FIS,ERROR,STEPSIZE] = ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,[],OPTMETHOD)
% �͌P���I�v�V�����̎w��̂��߂�TRNOPT�x�N�g����p���܂��B
%       TRNOPT(1): �P���G�|�b�N��                (�f�t�H���g: 10)
%       TRNOPT(2): �P���덷�̖ڕW                  (�f�t�H���g: 0)
%       TRNOPT(3): �����X�e�b�v�T�C�Y              (�f�t�H���g: 0.01)
%       TRNOPT(4): �X�e�b�v�T�C�Y�̌�����          (�f�t�H���g: 0.9)
%       TRNOPT(5): �X�e�b�v�T�C�Y�̑�����          (�f�t�H���g: 1.1)
% �w�K�v���Z�X�́A�w�肳�ꂽ�G�|�b�N���A�܂��́A�P���덷�̖ڕW�l�ɓ��B����
% �n�_�ŏI�����܂��BSTEPSIZE�̓X�e�b�v�T�C�Y�̔z��ł��B�X�e�b�v�T�C�Y��
% �����͊w�K�I�v�V�����Ŏw�肳�ꂽ�����A�܂��͌����X�e�b�v�T�C�Y�����悶��
% ���ƂŌ��܂�܂��B�f�t�H���g�̒l�𗘗p����ɂ�NaN���w�肵�܂��B
%
% DISPOPT�x�N�g���͊w�K���̕\���I�v�V�����̎w��ɗ��p���܂��B1�͏���
% �\�����A0�͔�\�����Ӗ����܂�:
%
%    DISPOPT(1)   :��ʓI��ANFIS���              (�f�t�H���g: 1)
%    DISPOPT(2)   :�G���[                         (�f�t�H���g: 1)
%    DISPOPT(3)   :�e�p�����[�^�̍X�V���̃X�e�b�v�T�C�Y(�f�t�H���g: 1)
%    DISPOPT(4)   :�ŏI����                       (�f�t�H���g: 1)
%
% OPTMETHOD�͊w�K�ɗ��p����œK����@���w�肵�܂��B1�̓f�t�H���g�̃n�C�u���b�h
% �@��I�����܂��B����͍ŏ���搄��ƃo�b�N�v���p�Q�[�V�����̌���������@�ł��B
% 0�̓o�b�N�v���p�Q�[�V�����@�𗘗p���܂��B
%
% [FIS,ERROR,STEPSIZE,CHKFIS,CHKERROR] = ...
% ANFIS(TRNDATA,INITFIS,TRNOPT,DISPOPT,CHKDATA) �̓`�F�b�N�i�]���j�f�[�^
% CHKDATA���w�K�f�[�^�Z�b�g�̃I�[�o�[�t�B�b�f�B���O�̂��߂Ɏw�肵�܂��BCHKDATA��
% TRNDATA�Ɠ����t�H�[�}�b�g�ł��B�I�[�o�[�t�B�b�f�B���O�́A�w�K�G���[���������Ă���
% �ԂɁA�`�F�b�L���O�G���[(CHKFIS����̏o�͂ƃ`�F�b�N�f�[�^�Ƃ̍��j���������Ă���
% ���ۂ����m�ł��܂��BCHKFIS�̓`�F�b�L���O�f�[�^�G���[���ŏ��ɂȂ����Ƃ���FIS��
% �X�i�b�v�V���b�g�ł��BCHKERROR�͏����G�|�b�N�̃`�F�b�L���O�f�[�^�G���[�̕���
% ���a���̔z��ł��B
% 
%   ��
%       x = (0:0.1:10)';
%       y = sin(2*x)./exp(x/5);
%       epoch_n = 20;
%       in_fis  = genfis1([x y],5,'gbellmf');
%       out_fis = anfis([x y],in_fis,epoch_n);
%       plot(x,y,x,evalfis(x,out_fis));
%       legend('Training Data','ANFIS Output');
%
% �Q�l GENFIS1, ANFISEDIT.


%   Copyright 1994-2002 The MathWorks, Inc. 
