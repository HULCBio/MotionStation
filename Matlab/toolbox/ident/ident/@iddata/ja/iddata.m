% IDDATA �́A���胋�[�`���p�Ɏg�p�ł��� DATA �I�u�W�F�N�g���쐬���܂��B
%  
% �ł���{�I�Ȏg�p�F
% DAT = IDDATA(Y,U,Ts) �́A�o�� Y �Ɠ��� U �ŃT���v�����O�Ԋu Ts �̃f�[�^
% �I�u�W�F�N�g���쐬���܂��B�f�t�H���g�́ATs = 1 �ł��BU = []�A�܂��́A��
% �肳��Ă��Ȃ��ꍇ�ADAT �́A�M���܂��͎��n����`���܂��BY = []�̏ꍇ�A
% DAT �͓��͂��̂��̂ɂȂ�܂��B
% Y �́A�f�[�^�� N �� �o�̓`�����l���� Ny ����Ȃ� N �s Ny ��̍s��ł��B
% U �����l�Ȍ^�̍s��ɂȂ�܂��BY �� U �́A�����s���������Ă��Ȃ���΂Ȃ�
% �܂���BDAT.y�ADAT.u�ADAT.Ts �Ńf�[�^��\���ł��܂��B�܂��A�����I�ɑI��
% ����ɂ́ADAT1 = DAT(1:300) ���Ŏg�p���܂��B
%
% ��{�I�Ȏg�p�F
% DAT = IDDATA(Y,U,Ts,'OutputName',String,....)�A�܂��́ASET(DAT,'Outpu-
% tName',String,....)�́A�L������v���b�g�p�ɁA�f�[�^�I�u�W�F�N�g�Ƀv���p
% �e�B��t�����܂��B�v���p�e�B�̊��S�ȃ��X�g�𓾂�ɂ́ASET(IDDATA) �ƃ^
% �C�v���Ă��������B
% 
% �������̊�{�I�Ȃ��̂������܂��B
%          OutputData, InputData �́A��ɋL�q���� Y �� U ���Q��
%          OutputName �́A������ł��B�����͂ɑ΂��āA�Z���z��A���Ƃ��΁A
%                        {'Speed','Voltage'}�Ƃ��Ďg�p���܂��B
%          OuputUnit �́A������ŁA�����͂ɑ΂��āA�Z���z��A���Ƃ��΁A
%                        {'mph','volt'} �Ƃ��Ďg�p���܂��BInputName, 
%                        InputUnit �����l�ł��B
%          Tstart �́A�T���v�����O�̃X�^�[�g���Ԃł��B
%          TimeUnit �́A������ł��B
% 
% �v���p�e�B�́ASET �� GET�A�܂��́A�T�u�t�B�[���h�Őݒ��擾���邱�Ƃ�
% �ł��܂��B
%          GET(DAT,'OutputName')�A�܂��́ADAT.OutputName
%          SET(DAT,'OutputName','Current')�A�܂��́A
%          DAT.OutputName = {'Current'};
% �Q�ƃt�B�[���h���́A�啶���A�������̋�ʂ��s���܂���B�܂��A'y' ��'Ou-
% tput'�ŁA'u'��'Input'�ł��B�����āA�v���p�e�B�����ʂ���t�����łȂ��A��
% �����ł��\���܂���B���Ƃ��΁ADAT.yna �́ADAT.OutputName �Ɠ��������ł��B
% �ݒ肵���`�����l���ւ̖��O��P�ʂ����蓖�Ă�ɂ́A���̂悤�ɂ��܂��B
%          DAT.un(3)={'Speed'}�A�܂��́ADAT.uu([3 7])={'Volt','m^3/s'}
%
% �`�����l���̎�舵���F
% �`�����l���v���p�e�B��ݒ肵����A�擾����ȒP�ȕ��@�́A�T�u�X�N���v�g
% �@���g�p���邱�Ƃł��B�T�u�X�N���v�g�́A���̂悤�ɒ�`���܂��B
% DAT(SAMPLES,OUTPUTS,INPUTS) �ɂ����āADAT(:,3,:) �́A���ׂĂ̓��̓`����
% �l������o�̓`�����l��3�܂ł́ADAT ���瓾����f�[�^�I�u�W�F�N�g������
% �܂�(���̕\�L�@�ŁA�O�Ԗڂ�:�͏ȗ��ł��ADAT(:,3,:)=DAT(:,3) �ɂȂ�܂�)�B
% �`�����l���́A���O���w�肵�ēǂݍ��ނ��Ƃ��ł��܂��B����ŁADAT(:,{'s-
% peed','flow'},[]) �́A�w�肵���o�̓`�����l�����I������āA���̓`�����l
% �����I������Ă��Ȃ��f�[�^�I�u�W�F�N�g�ł��B����ɁA
% 
%     DAT1(101:200,[3 4],[1 3]) = DAT2(1001:1100,[1 2],[6 7])
% 
% �́Aiddata �I�u�W�F�N�g DAT1 �̏o�̓`�����l��3��4�A���̓`�����l��1��3��
% �T���v��101����200��iddata �I�u�W�F�N�g DAT2 ����ݒ肳���l�ɕύX����
% ���B�����̃`�����l���̖��O�ƒP�ʂ́A�K�X�A�ύX������܂��B
%
% �V�����`�����l����t�����āAIDDATA �I�u�W�F�N�g�̐����A�����g���܂��B
% 
%     DAT =[DAT1, DAT2];
% 
% �܂��́A���ځA�f�[�^���R�[�h��t�����܂��BDAT.u(:,5) = U �́A�ܔԖڂ̓�
% �͂� DAT �ɕt�����܂��B
% 
% �Q�l�FIDDATA/SUBSREF, IDDATA/SUBSASGN, IDDATA/HORZCAT
%
% �T���v�����O���������Ȃ�����
% �v���p�e�B'SamplingInstants' �́A�f�[�^�_�̃T���v�������O���s���_��^��
% �܂��B����́Aget(DAT,'SamplingInstants')�A�܂��́ADAT.s �ł������A
% DAT.Ts �� DAT.Tstart ����v�Z����܂��B'SamplingInstants' �́A�f�[�^��
% �Ɠ��������̔C�ӂ̃x�N�g���ɐݒ肷�邱�Ƃ��ł��܂��B����ŁA�T���v����
% �O���������Ȃ����̂���舵�����Ƃ��ł��܂��BTs �́A�����I�� [] �ɐݒ肳
% ��܂��B
%
% �����̎����̎�舵���F
% IDDATA �I�u�W�F�N�g�́A�ʁX�̎������瓾��ꂽ�f�[�^���X�g�A�ł��܂��B�v
% ���p�e�B'ExperimentName' �́A��������ʂ��邽�߂Ɏg�p������̂ł��B�T��
% �v�����O�v���p�e�B�Ɠ��l�Ƀf�[�^�����������ɕύX�ł��܂����A���̓`����
% �l���Əo�̓`�����l���͓����łȂ���΂Ȃ�܂���(��������̒��ŁA����ł�
% �Ă��Ȃ��`�����l���� NaN ���g���Ă�������)�B
% 
% �f�[�^���R�[�h�́A�Z���z��ŁA�Z���ɂ́A�e�������瓾��ꂽ�f�[�^���܂�
% �ł��܂��B�����̎����́A�Z���z��ł���'Ts'��'Tstart'�Ɠ��l��'y'��'u'��
% �g���Ē��ڒ�`���邱�Ƃ��ł��܂��B
% 
% ���̂悤�ɂ��āA��̎������}�[�W���邱�Ƃ��ł��܂��B
% 
%     DAT = MERGE(DAT1,DAT2)   (HELP IDDATA/MERGE ���Q��)
%
% �}�[�W���ꂽ�����́A�R�}���h GETEXP �Œ��o���܂�:
% GETEXP(DAT,3) �́A�����ԍ� 3 �𒊏o���AGETEXP(DAT,{'Day1','Day4') �́A
% �w�肵�����O������2�̎����𒊏o���܂��B�����́ADAT��4�̃C���f�b�N�X
% �^���Ď������Ƃ��ł��A���̂悤�ɋL�q���܂��B
%
%     DAT1 = DAT(Samples,Outputs,Inputs,Experiments)
%
% �Q�l: IDDATA/SUBSREF, IDDATA/SUBSASGN




%   Copyright 1986-2001 The MathWorks, Inc.
