function result=qbitstatesimulate(celljsonorfile)
% zhaouv https://zhaouv.github.io/
% qutip��circuit��ʶ����ŵ��б�
% ["RX","RY","RZ","SQRTNOT","SNOT","PHASEGATE","CRX","CRY","CRZ","CPHASE","CNOT","CSIGN",
% "BERKELEY","SWAPalpha","SWAP","ISWAP","SQRTSWAP","SQRTISWAP","FREDKIN","TOFFOLI","GLOBALPHASE"]

% warning('�滻Ϊ qutipenv=localconfig.pythonconfig.qutipenv;ͳһ����?����������qos�л���������ֲʱ��bug')
qutipenv='C:\ProgramData\Anaconda3\envs\qutip-env\python.exe';
% [~,qutipenv,~]=pyversion;%���Ĭ�ϵ�python������qutip,ʹ�ô˾伴��

%{
%example1
jsonstr=['[["h","cz1","rx90"],',...
    '["h","cz3","cz5"],',...
    '["h","cz2","cz6"],',...
    '["h","cz4","ry-90"]]'];
result=sqc.simulation.qbitstatesimulate(jsonstr)

%>>result = 
%>>
%>>  ���������ֶε� struct:
%>>
%>>    real: [16��1 double]
%>>    imag: [16��1 double]
%%

%example2
tempcell='[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]';
tempcell=jsondecode(tempcell);
len=size(tempcell{1},1);
result=cell(len,1);
for index=1:size(tempcell{1},1)
    result{len+1-index}=sqc.simulation.qbitstatesimulate(tempcell);
    tempcell={{tempcell{1}{1:end-1}}';{tempcell{2}{1:end-1}}'};
end
result

%>>result =
%>>
%>>  12��1 cell ����
%>>
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]
%>>    [1��1 struct]

%Ŀǰֻ֧��cell��json��֧���ļ�
%}

if ~nargin
    celljsonorfile='[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]';
end

if iscell(celljsonorfile)
    stringorfile=tempcell2str(celljsonorfile);
else
    celljsonorfile=jsondecode(celljsonorfile);    
    stringorfile=tempcell2str(celljsonorfile);
end
%stringorfile=',,ry90,cz1,rx-90,ry-90,,rx-90,cz1,,ry90,rx90#rx-90,ry90,rx90,cz2,,ry90,x,ry-90,cz2,rx-90,ry-90,rx90';

mpath = mfilename('fullpath');
i=findstr(mpath,'\'); %#ok<FSTR>
mpath=mpath(1:i(end));

command=[qutipenv,' ',mpath,'qbitstatesimulate.py ',stringorfile];
[status, result]=system(command);
if ~(status==0)
    error(result)
end

result=jsondecode(result);
result=-result.real-1j*result.imag;
end

function str=tempcell2str(tempcell)
%tempcell=jsondecode('[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]');
str='';
for line = tempcell'
    for onegate = line{1}'
        str=[str,onegate{1},','];
    end
    str=[str(1:end-1),'#'];
end
str=str(1:end-1);
end