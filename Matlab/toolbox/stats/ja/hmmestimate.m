% HMMESTIMATE   HMM �ɗ^����ꂽ��ԏ��ɑ΂���p�����[�^����
%
% [TR, E] = HMMESTIMATE(SEQ,STATES) �́A���m�̏�� STATES �Ƃ��āA�n�� 
% SEQ �ɑ΂��� HMM �̊m���ł���J�� TR �ƃG�~�b�V���� E �̍Ŗސ����
% �v�Z���܂��B
%
% HMMESTIMATE(...,'SYMBOLS',SYMBOLS) �́A�G�~�b�g(emit)�����V���{����
% �w�肷�邱�Ƃ��ł��܂��BSYMBOLS �́A���l�z��A�܂��̓V���{���̖��O��
% �Z���z��ł��BN ���\�ȃG�~�b�V�����̐��ł���ꍇ�A�f�t�H���g��
% �V���{���́A1���� N �̊Ԃ̐����ł��B
%
% HMMESTIMATE(...,'STATENAMES',STATENAMES) �́A��Ԗ����w�肷�邱�Ƃ�
% �ł��܂��BSTATENAMES �́A���l�z��A�܂��͏�Ԃ̖��O�̃Z���z��ł��B
% �f�t�H���g�̏�Ԗ��́AM ����Ԑ��̏ꍇ�A1���� M �̊ԂɂȂ�܂��B
%
% HMMESTIMATE(...,'PSEUDOEMISSIONS',PSEUDOE) �́A�[���J�E���g(pseudocount)
% �G�~�b�V�����̒l���w�肷�邱�Ƃ��ł��܂��B�����́A�W�{�n�����
% ������Ȃ����ɒႢ�m�������G�~�b�V�����ɑ΂���[���̊m�������
% �����邽�߂Ɏg�p����܂��BPSEUDOE �́AM��MHH �̏�Ԑ��ŁAN ���\��
% �G�~�b�V�����̐��ł���ꍇ�AM�sN��̑傫���̍s��ł��B
%
% HMMESTIMATE(...,'PSEUDOTRANSITIONS',PSEUDOTR) �́A�[���J�E���g
% (pseudocount)�J�ڂ̒l���w�肷�邱�Ƃ��ł��܂��B�����́A�W�{�n�����
% ������Ȃ����ɒႢ�m�������G�~�b�V�����ɑ΂��ă[���̊m�������
% �����邽�߂Ɏg�p����܂��BPSEUDOTR �́AM �� HMM ���̏�Ԑ��̏ꍇ�A
% M�sM��̑傫���̍s��ł��B
%
% ��Ԃ����m�łȂ��ꍇ�A���f���p�����[�^�𐄒肷�邽�߂ɁAHMMTRAIN��
% �g�p���Ă��������B
%
% ���̊֐��́A��ɏ��1�̃��f������n�܂�A���ɑJ�ڍs��̍ŏ��̍s��
% ����m�����g���čŏ��̃X�e�b�v�ɑJ�ڂ��܂��B�]���āA�ȉ��ŗ^����ꂽ
% ���ɂ����āA��Ԃ̏o�͂̍ŏ��̗v�f�́A0.95�̊m����1�ɁA0.05�̊m����
% 2�ɂȂ�܂��B
%
% ���:
%
% 		tr = [0.95,0.05;
%             0.10,0.90];
%           
% 		e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
%            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
%
%       [seq, states] = hmmgenerate(1000,tr,e);
%       [estimateTR, estimateE] = hmmestimate(seq,states);
%
%
% �Q�l : HMMGENERATE, HMMDECODE, HMMVITERBI, HMMTRAIN.


%   Copyright 1993-2003 The MathWorks, Inc. 
%   $Revision: 1.3 $  $Date: 2003/01/28 19:08:20 $
