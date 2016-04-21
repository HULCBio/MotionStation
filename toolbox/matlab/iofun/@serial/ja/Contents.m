% Serial Port�֐��ƃv���p�e�B
%
% serial port�I�u�W�F�N�g�\��
%   serial        - serial port�I�u�W�F�N�g�̍쐬
%
% �p�����[�^�̎擾�Ɛݒ�
%   get           - serial port �I�u�W�F�N�g�v���p�e�B�̒l�̎擾
%   set           - serial port �I�u�W�F�N�g�v���p�e�B�̒l�̐ݒ�
%
% ��Ԃ̕ύX
%   fopen         - �I�u�W�F�N�g���f�o�C�X�ɐڑ�
%   fclose        - �f�o�C�X����I�u�W�F�N�g�̐ؒf 
%   record        - serial port session ����f�[�^���L�^
%
% �ǂݍ��݊֐��Ə������݊֐�
%   fprintf       - �f�o�C�X�Ƀe�L�X�g����������
%   fgetl         - �I�[�q�𖳎����ăf�o�C�X����e�L�X�g��1�s���ǂݍ���
%   fgets         - �I�[�q�𖳎����Ȃ��ăf�o�C�X����e�L�X�g��1�s���ǂݍ���
%   fread         - �f�o�C�X���炩��o�C�i���f�[�^�̓ǂݍ���
%   fscanf        - �f�o�C�X���炩��t�H�[�}�b�g�t���f�[�^�̓ǂݍ���
%   fwrite        - �f�o�C�X�Ƀo�C�i���f�[�^����������
%   readasync     - �f�o�C�X����񓯊��Ńf�[�^��ǂݍ���
%
% serial port �֐�
%   serialbreak   - �u���[�N���f�o�C�X�ɑ���
%
% ��ʓI�Ȏ���
%   delete        - ���������� serial port �I�u�W�F�N�g���폜
%   inspect       - �C���X�y�N�^���I�[�v������ instrument �I�u�W�F�N�g��
%                   �v���p�e�B�𒲂ׂ�
%   instrcallback - �C�x���g�ɑ΂���C�x���g���̕\��
%   instrfind     - �w�肵���v���p�e�B�l������ serial port �I�u�W�F�N�g�̌���
%   instrfindall  - ObjectVisibility�Ɉ˂炸�ɁA���ׂĂ� instrument 
%                   �I�u�W�F�N�g�̌���
%   isvalid       - serial port �I�u�W�F�N�g���f�o�C�X�ɐڑ��ł��邩�𔻒�
%   stopasync     - �񓯊��̓ǂݍ��݂Ə������ݑ���̒�~
%
% serial port �v���p�e�B
%   BaudRate                  - �f�[�^�r�b�g���]������銄���̎w��
%   BreakInterruptFcn         - �C���^���v�g���������Ƃ��ɁA���s����
%                               �R�[���o�b�N�֐�
%   ByteOrder                 - �f�o�C�X�̃o�C�g��
%   BytesAvailable            - �ǂݍ��݂ɗ��p����o�C�g���̎w��
%   BytesAvailableFcn         - �o�C�g�����w�肳�ꂽ�Ƃ��Ɏ��s�����
%                               �R�[���o�b�N�֐�
%   BytesAvailableFcnCount    - BytesAvailableAction �����s����O�ɗ��p
%
%   BytesAvailableFcnMode     - BytesAvailableAction ���A�o�C�g�����x�[�X
%
%   BytesToOutput             - ���ݓ]�������E�G�C�e���O��Ԃ̃o�C�g��
%   DataBits                  - �]�������f�[�^�r�b�g��
%   DataTerminalReady         - DataTerminalReady �s���̏��
%   ErrorFcn                  - �G���[���������ꍇ�Ɏ��s�����
%                               �R�[���o�b�N�֐�
%   FlowControl               - �g�p�̂��߂̃f�[�^�t���[�R���g���[��
%                               ���\�b�h�̎w��
%   InputBufferSize           - ���̓o�b�t�@�̃g�[�^���T�C�Y
%   Name                      - serial port �I�u�W�F�N�g�̋L�q��
%   ObjectVisibility          - �R�}���h���C���� GUI �ɂ��A�I�u�W�F�N�g�ւ�
%�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@ �A�N�Z�X���R���g���[��
%   OutputBufferSize          - �o�̓o�b�t�@�̃g�[�^���T�C�Y
%   OutputEmptyFcn            - �o�̓o�b�t�@����̂Ƃ��ɁA���s����
%                               �R�[���o�b�N�֐�
%   Parity                    - �G���[���o���J�j�Y��
%   PinStatus                 - �n�[�h�E�F�A�s���̏��
%   PinStatusFcn              - PinStatus �\���̓��̃s�����l��ύX����
%                               �Ƃ��Ɏ��s�����R�[���o�b�N�֐�
%   Port                      - �n�[�h�E�F�A�[�q�̋L�q
%   ReadAsyncMode             - �񓯊��̓ǂݍ��ݑ��삪�A�����}�j���A����
%                               �ǂ��炩���w��
%   RecordDetail              - �f�B�X�N�ɋL�^�������
%   RecordMode                - �f�[�^����̃f�B�X�N�t�@�C���ɃZ�[�u
%                               ���邩�A�����̃f�B�X�N�t�@�C���ɃZ�[�u
%                               ���邩���w��
%   RecordName                - �f�[�^�̑��M�Ǝ�M���L�^����f�B�X�N
%                               �t�@�C���̖��O
%   RecordStatus              - �f�[�^���f�B�X�N�ɏ������܂ꂽ���𔻒�
%   RequestToSend             - RequestToSend �s���̏��
%   Status                    - serial port �I�u�W�F�N�g�� serial port ��
%                               �ڑ����Ă��邩�𔻒�
%   StopBits                  - �f�[�^�]���̏I�����������߂ɓ]�����ꂽ
%                               �r�b�g��
%   Tag                       - �I�u�W�F�N�g�p���x��
%   Terminator                - Serial port �ɑ���R�}���h���I��������

%   Timeout                   - �f�[�^����M���邽�߂̑҂�����
%   TimerFcn                  - timer �C�x���g�����������Ƃ��Ɏ��s�����
%                               �R�[���o�b�N�֐�
%   TimerPeriod               - timer �C�x���g�Ԃ̕b�P�ʂŕ\�킵������
%   TransferStatus            - �񓯊��̓ǂݍ��݁A�܂��͏������ݑ����
%                               �i�s������
%   Type                      - �I�u�W�F�N�g�^�C�v
%   UserData                  - �I�u�W�F�N�g�p���[�U�f�[�^
%   ValuesReceived            - �f�o�C�X����ǂݍ��ޒl�̐�
%   ValuesSent                - �f�o�C�X�ɏ������ޒl�̐�
%
% �Q�l : SERIAL.
%


% MP 7-13-99
% Copyright 1999-2004 The MathWorks, Inc. 
