% IDPOLY �́AIDPOLY ���f���\���̂��쐬���܂��B
%       
%   M= IDPOLY(A,B,C,D,F,LAM,T)
%
% M: ���̃��f�����L�q���郂�f���\���̂Ƃ��ďo��
%   A(q) y(t) = [B(q)/F(q)] u(t-nk) + [C(q)/D(q)] e(t)
%   
% A, B, C, D, F �́A�������Ƃ��ē��͂��܂��BA, C, D, F �́A1����n�܂�
% B �́A���U���ԃ��f���̒x����������߂ɐ擪�Ƀ[����t�����܂��B�����̓V
% �X�e���ɑ΂��āAB �� F �́A���͐����s���Ƃ���s��ł��B���n��f�[�^�ɑ�
% ���āAB �� F �́A��[]�Ƃ��ē��͂��܂��BPOLY2TH �́ATH2POLY �̋t�ł��B
%
% LAM �̓m�C�Y�̕��U�ŁAT �̓T���v�����O�Ԋu�ł��BT �ɕ��̒l��ݒ肷���
% �A�����f���Ɖ��߂��܂��B�܂��A�������́A���̍~�x�L�̏��ɓ��͂��܂��B��
% �Ƃ��΁AA = 1,B = [1 2;0 3],C = 1,D = 1,F = [1 0;0 1],T = -1 �́AY = 
% (s+2)/s U1 + 3 U2 ��A���V�X�e���ŕ\�������̂ł��B
%
% ���͈����ŁA��Ɉʒu����C, D, F, LAM, T ���ȗ������ꍇ�A1�Ɖ��߂���AB 
% = [] �̏ꍇ�A F = [] �ƂȂ�܂��B
%
% M = IDPOLY ���g�ł́A��I�u�W�F�N�g���쐬���܂��B
%
% IDPOLY �I�u�W�F�N�g�̂��ׂẴv���p�e�B������ɂ́ASET(IDPOLY) ���g����
% ���B����ȊO�̃v���p�e�B��ݒ肷��ɂ́ASET�A�܂��́A���̃X�e�[�g����
% �g���g���܂��B
% 
%   M= IDPOLY(A,B,C,D,F,LAM,T,Property,Value,Property,Value,...)
%
% GET/SET �ň�����v���p�e�B�́A���̂��̂ł��B
%   a,b,c,d,f: ������
%   Ts: ���f���̃T���v�����O���ԁBTs = 0 �́A�A�����ԃ��f�����Ӗ����܂��B
%   NoiseVariance: �m�C�Y�̕��U(�C�m�x�[�V����)
%   ParameterVector: ���肵�����f��/�m�~�i�����f���̃p�����[�^�x�N�g��
%   CovarianceMatrix: ���ɁA���肳��Ă���ꍇ�AParameterVector �̋����U
%                     �s��
%   
%   MODEL STRUCTURE �v���p�e�B:
%   ModelStructure: ���̃t�B�[���h���܂ލ\����(���ꂼ��ASET/GET �ŃA�N
%                   �Z�X)
%     na: A-�������̎���
%     nb: B-�������̎���
%     nc: C-�������̎���
%     nd: D-�������̎���
%     nf: F-�������̎���
%     InputDelay: �e���͂̒x���ݒ肷��s�x�N�g���B�f�t�H���g��1�ł��B
%     InitialState: �t�B���^�̏�����Ԃ̎�舵���@�̌���
%          'Zero': �����������[���ɌŒ�
%          'Estimate': ���������𐄒�
%          'Backcast': �����������t�����̃v���Z�X�ɂ��A�I�ɐ���
%          'Default': �f�[�^�⃂�f���\���̌���̂��߂ɁA��q�̂ǂ��炩��
%                     ��@�𗘗p
%
%   ALGORITHM �v���p�e�B             
%   Algorithm: ���̃t�B�[���h�����\����(���ꂼ��ASET/GET �ŃA�N�Z�X)
%     Approach: 'Pem', 'Subspace', 'Arx', 'IV' �̂����ꂩ
%     Focus: ���̒�����I��
%          'Prediction': �\���̂��߂ɍœK�����ꂽ���f���̍쐬
%          'Simulation': �V�~�����[�V�����̂��߂ɍœK�����ꂽ���f���̍쐬
%                        �������A�\���̃v���p�e�B�ɏ]���ăm�C�Y���f������
%                        ��
%          'Prefilter': ????? �Őݒ肳���t�B���^�ɂ�苭���������g��
%                       �ш�ɍ��킹���v���t�B���^���f�[�^�ɓK�p
%          'Normfit': ???? �Œ�`�����d�݊֐����g���āA���g���̈�ŁAL2
%                     �m�����ɓK��������悤�Ƀ_�C�i�~�N�X������
%     MaxIter: �J��Ԃ��T�[�`��@�ł̍ő�J��Ԃ���
%     Tolerance: �J��Ԃ��T�[�`�ɑ΂���I���K�́B�J��Ԃ��ɂ����ǂ����
%                ������ Tolerance �ȉ��̏ꍇ�A�J��Ԃ��͒�~���܂��B 
%     LimitError: �K���ɑ΂��āA���o�X�g�����ꂽ�m�����̒�`�BLimitError*
%                 (�W���΍�)���傫���덷�́A���m�����������`�m����
%                 �ŉe�����傫���Ȃ�܂��B
%     MaxSize: �A���S���Y���́AMaxSize �v�f���������̗v�f�����s�����
%              ����������A���[�v���g���悤�ɂ��܂��B
%     SearchDirection: ���[�J���T�[�`�̒�`�B���̒�����ݒ肵�܂��B
%          Lm: Levenberg-Marquard �@
%          Gn: Gauss-Newton �T�[�`
%          Gns: ���ɏ����̗ǂ��w�V�A�������T�u��ԂɌ��肵�� Gauss-
%               Newton �T�[�`
%     FixedParameters: �T�[�`�̊ԁAFixedParameters �̒��̃C���f�b�N�X�ɑ�
%                      �������p�����[�^���Œ肳��܂��B�Ή����鏇�ԂɊւ�
%                      �ẮA�}�j���A�����Q�Ƃ��Ă��������B
%     Trace: 'On'�A�܂��́A'Off'�ł��B�I���󋵂��X�N���[����ɕ\�����邩
%             �ۂ��̌���
%     Auxord: SubSpace �A���S���Y���ɁA�A���S���Y���I�ɏڍׂ�^����x�N�g
%             ��
%     Advanced: �T�[�`�Ɋւ���ڍׂ������\����
%
%   ESTIMATION ���
%   EstimationInfo: ����v���Z�X�ƌ��ʂɊւ�������܂񂾍\����

% $Revision: 1.2 $ $Date: 2001/03/01 22:54:29 $
%   Copyright 1986-2001 The MathWorks, Inc.
