% SIMSET   SIM �̓��͂ɑ΂���OPTIONS�\���̂��쐬/�ύX
%
% OPTIONS  =  SIMSET('NAME1',VALUE1,'NAME2',VALUE2,...) �́A�w�肳�ꂽ�v���p
% �e�B���w�肵���l�����ASimulink sim�I�v�V�����\���� OPTIONS ���쐬���܂��B
% ����́A�v���p�e�B����ӓI�Ɏ��ʂ��铪��������͂��邾���ō\���܂���B�v��
% �p�e�B���ɂ��ẮA�啶���Ə������̋�ʂ͖�������܂��B
%
% OPTIONS  =  SIMSET(OLDOPTS,'NAME1',VALUE1,...) �́A�����̃I�v�V�����\����
% OLDOPTS ��ύX���܂��B
%
% OPTIONS  =  SIMSET(OLDOPTS,NEWOPTS) �́A�����̃I�v�V�����\���� OLDOPTS�ƐV
% �K�̃I�v�V�����\���� NEWOPTS ��g�ݍ��킹�܂��B�V�K�̃v���p�e�B�́A�Ή�����
% �Â��v���p�e�B���㏑�����܂��B
%
% SIMSET �́A�������w�肵�Ȃ��ꍇ�A���ׂẴv���p�e�B���Ƃ����̎�蓾��l��
% �\�����܂��B
%
% SIMSET �̃v���p�e�B�̃f�t�H���g
%
% �w�肳��Ă��Ȃ��v���p�e�B�̃f�t�H���g�́A���݂���΁A�V�~�����[�V�����p�����[
% �^�_�C�A���O�{�b�N�X���瓾���܂��B�V�~�����[�V�����p�����[�^�_�C�A���O�{�b
% �N�X�Ŏw�肳�ꂽ�l��"auto"�ł���ꍇ�́A���L�Ŏw�肷��f�t�H���g�l���p����
% ��܂��B
%
% SIMSET �v���p�e�B
%
% Solver - ���Ԑi�s���@   [ VariableStepDiscrete | ode45 | ode23 | ode113
%          | ode15s | ode23s | FixedStepDiscrete | ode5 | ode4 | ode3 | o
%          de2 | ode1 ] ���̃v���p�e�B�́A���Ԃ�i�߂邽�߂ɂǂ̃\���o���g�p���邩���w�肵�܂��B
%
% RelTol - ���΋��e�덷�l�@[ ���̃X�J���@{1e-3} ] ���̃X�J���l�́A��ԃx�N�g��
%          �̂��ׂĂ̗v�f�ɓK�p����܂��B
% �e�ϕ��X�e�b�v�ł̐���덷�́A�ȉ��𖞑����܂��B
% e(i) < =  max(RelTol*abs(x(i)),AbsTol(i)).  RelTol�́A�σX�e�b�v�\���o��
% �݂ɓK�p����A�f�t�H���g��1e-3�ł�(���x0.1%)�B
%
% AbsTol - ��΋��e�덷�l�@[ ���̃X�J���@{1e-6} ] ���̃X�J���l�́A��ԃx�N�g��
%          �̂��ׂĂ̗v�f�ɓK�p����܂��B
% AbsTol �́A�σX�e�b�v�\���o�݂̂ɓK�p����A�f�t�H���g��1e-6�ł��B
%
% Refine - �o�̓��t�@�C���t�@�N�^�@[ ���̐����@{1} ] ���̃v���p�e�B�́A�w�肵
%          ���t�@�N�^�����o�͓_���𑝉������A��芊�炩�ȏo�͂𐶐����܂��B
% ���t�@�C�����Ƀ\���o�̓[���N���b�V���O���`�F�b�N���܂��B
% Refine�́A�σX�e�b�v�\���o�݂̂ɓK�p����A�f�t�H���g��1�ł��B
% Refine �́A�o�͎��Ԃ��w�肳��Ă���ꍇ�́A��������܂��B
%
% MaxStep - ?X?e?b?v?T?C?Y?I?a?A [ ?3?I?X?J?��?@{auto} ] MaxStep ?I?A��A?I?
%           X?e?b?v?\???o?I?Y?E"K-p?3?e?A?f?t?H???g?I?V?~?...???[?V?��?"?a
%           ?O?I50?a?I1?E?Y'e?3?e?U?�E?B
%
% MinStep - ?X?e?b?v?T?C?Y?I��o?A [ ?3?I?X?J?��?@{auto} ] ?U?1/2?I [ ?3?I?X
%           ?J?��, "n?��?(r)?"] Minstep?I?A��A?I?X?e?b?v?\???o?I?Y?E"K-p?3?e
%           ?A?f?t?H???g?I?}?V?"?I?�C"x?E?i?A?-'l?A?�E?B
%
% InitialStep - ���������X�e�b�v�T�C�Y [ ���̃X�J���@{auto} ] InitialStep
%               �́A�σX�e�b�v�\���o�݂̂ɓK�p����܂��B
% �\���o�́A�܂�InitialStep �̃X�e�b�v�T�C�Y�����݂܂��B
% �f�t�H���g�ł́A�\���o�������I�ɏ����X�e�b�v�T�C�Y�����肵�܂��B
%
% MaxOrder - ODE15S�̍ō����� [ 1 | 2 | 3 | 4 | {5} ] MaxOrder �́AODE15S��
%            �݂ɓK�p����A�f�t�H���g��5�ł��B
%
% FixedStep - �Œ�X�e�b�v�T�C�Y [ ���̃X�J��] FixedStep �́A�Œ�X�e�b�v�\
%             ���o�݂̂ɓK�p����܂��B
% ���U�n�������܂܂�Ă���ꍇ�́A�f�t�H���g�͊�{�I�T���v�����Ԃł��B ������
% �Ȃ��ꍇ�A�f�t�H���g�̓V�~�����[�V������Ԃ�50����1�ł��B
%
% ExtrapolationOrder - ODE14X?A?I?O'}?I???" [ 1 | 2 | 3 | {4} ]  ODE14X?A
%                      -p?��?e?O'}-@?I???"?B
% �f�t�H���g��4.
%
% NumberNewtonIterations - ODE14X?INewton?J?e?O?�ʁ�n?" [ {1} ] ODE14X?A?A
%                          ?s?�E?e?J?e?O?�ʁ�n?"
% �f�t�H���g��1.
%
% OutputPoints - �o�͓_�̌��� [ {specified} | all ] OutputPoints �̃f�t�H��
%                �g��'specified'�ł��B
% ���Ȃ킿�A�\���o�́ATIMESPAN �Ŏw�肵�����Ԃł̂ݏo�� T, X, Y �𐶐����܂��B
% OutputPoints ��'all' �ɐݒ肳���ƁAT, X, Y �ɂ́A�\���o���g�������ԃX�e�b
% �v���܂܂�܂��B
%
% OutputVariables - �o�͕ϐ��̐ݒ� [ {txy} | tx | ty | xy | t | x | y ] O
%                   utputVariables �������'t','x'�A�܂��́A'
%                   y'���Ȃ��ꍇ�́A�\���o�͑Ή�����o��T, X, Y�ɋ�s��𐶐����܂��B
% ���̃v���p�e�B�́A���ӈ������Ȃ��ꍇ�ɂ͖�������܂��B
%
% SaveFormat - �ۑ��t�H�[�}�b�g�̐ݒ� [{'Matrix'} | 'Structure' | 'Structu
%              reWithTime'] ���̃v���p�e�B�́A��ԂƏo�͂̕ۑ��̃t�H�[�}�b�g���w�肵�܂��B
% ��ԍs��́A�A����ԂƂ���ɑ������U��Ԃ��܂݂܂��B
% �ۑ��t�H�[�}�b�g��'Structure'�A�܂��́A'StructureWithTime'�ł���ꍇ�́A���
% �Əo�͂́A���ԃt�B�[���h�ƐM���t�B�[���h�����\���̔z��ɕۑ�����܂��B�M��
% �t�B�[���h�́A�t�B�[���h'values', 'label', 'blockName'���܂݂܂��B 'values'
% , 'label', and 'blockName'.
% �ۑ��t�H�[�}�b�g��'StructureWithTime'�ł���ꍇ�́A�Ή�����\���̂ɃV�~�����[
% �V�������Ԃ��ۑ�����܂��B
%
% MaxDataPoints - ?f?[?^"_?"?I?��?A ["n?��?I?(r)?" {0}] 'MaxDataPoints'?I?A
%                 ?]-??I'MaxRows'?A?��??-1/4'O?A?��?1/2?B
% ���̃v���p�e�B�́AT, X, ?E?o-I?3?e?e?f?[?^"_?"?d?A?a?(c)?cMaxDataPoints"
% _?I?f?[?^???O?E?��?A?��?U?�E?B0���w�肵���ꍇ�́A�����͓K�p����܂���B
% MaxDataPoints?I?f?t?H???g?I0?A?�E?B
%
% Decimation - �o�͕ϐ��ɑ΂���Ԉ��� [ ���̐����@{1} ] �Ԉ����t�@�N�^�́A�o
%              �͕ϐ� T, X, Y �ɓK�p����܂��B
% �Ԉ����t�@�N�^1�́A���ԗ�̂��ׂẴf�[�^���O���o�͂��A�Ԉ����t�@�N�^2�́A��
% �ԗ��1�����̃f�[�^���O���o�͂��܂��BDecimation �̃f�t�H���g��1�ł��B
%
% InitialState - �����A����Ԃ���я������U��� [ �x�N�g���@{[]} ] �������
%                �x�N�g���́A(���݂���ꍇ��)�A����ԂƁA(����
%                ����ꍇ��)����ɑ������U��Ԃ���\������܂��B
% ���f�����Ŏw�肳��鏉����Ԃ�InitialState �Œu���������܂��B
% �f�t�H���g�̋�s�� [] �ł́A���f�����Ŏw�肳�ꂽ������Ԓl���p�����܂��B
%
% FinalStateName - �ŏI��ԕϐ��� [ ������@{''} ] ���̃v���p�e�B�́A�V�~�����[
%                  �V�����̏I�����Ƀ��f���̏�Ԃ�ۑ�����ϐ��̖��O���w�肵�܂��B
% FinalStateName �̃f�t�H���g�́A�󕶎��� '' �ł��B
%
% Trace - �J���}�ŋ�؂������X�g [ 'minstep', 'siminfo', 'compile' {''} ]
%         ���̃v���p�e�B�́A�V�~�����[�V�����̃g���[�X�@�\���\�ɂ��܂��B
% o 'minstep' �g���[�X�t���O�́A���̕ω����]��ɂ��ˑR�ŉσX�e�b�v�\���o��
% �X�e�b�v�T�C�Y�ŋ��e�덷�l�𖞑������邱�Ƃ��ł��Ȃ��悤�ȏꍇ�ɃV�~�����[
% �V�������~����悤�Ɏw�肵�܂��B�f�t�H���g�ł́ASimulink�̓��[�j���O���b�Z�[
% �W���o�͂��āA�V�~�����[�V�����𑱍s���܂��Bo 'siminfo' �g���[�X�t���O�́A�V�~��
% ���[�V�����̊J�n���ɗL���ȃV�~�����[�V�����p�����[�^�̊ȒP�ȗv���񋟂��܂��B
% o 'compile' �g���[�X�t���O�́A�u���b�N���}���f���̃R���p�C���i�K��\������
% ���Bo 'compilestats' �g���[�X�t���O�́A�u���b�N���}���f���̃R���p�C���i�K�p
% �ɁA���Ԃƃ������e�ʂ�\�����܂��B
%
% SrcWorkspace - ����]�����郏�[�N�X�y�[�X [ {base} | current | parent ]
%                ���̃v���p�e�B�́A���f�����Œ�`����Ă���MATL
%                AB�\����]�����郏�[�N�X�y�[�X���w�肵�܂��B
% �f�t�H���g�́A�x�[�X���[�N�X�y�[�X�ł��B
%
% DstWorkspace - �ϐ������蓖�Ă郏�[�N�X�y�[�X [ base | {current} | parent
%                ] ���̃v���p�e�B�́A���f�����Œ�`����Ă����
%                �������蓖�Ă郏�[�N�X�y�[�X���w�肵�܂��B
% �f�t�H���g�́A�J�����g�̃��[�N�X�y�[�X�ł��B
%
% ZeroCross - �[���N���b�V���O�̌��o�̗L��/���� [ {on} | off ]  ZeroCross
%             �́A�σX�e�b�v�\���o�݂̂ɓK�p����A�f�t�H���g��'on'�ł��B
%
% Debug - Simulink?f?o?b?K?d?N"(r)��A"\/?s��A"\?E?�E?e [ on | {off} ] ?�}?I?v
%         ???p?e?B?don?E?Y'e?�E?e?A?ASimulink?f?o?b?K?d?N"(r)?��?U?�E?B
%
% �Q�l : SIM, SIMGET.


% Copyright 1990-2004 The MathWorks, Inc.
