% function Test_NAE5071C
clear all
obj.interfaceobj=visa('agilent','TCPIP::10.0.0.201::INSTR');
obj.timeout=30;
obj.interfaceobj.Timeout=30; 
obj.interfaceobj.InputBufferSize = 2000000;
fopen(obj.interfaceobj)
% fprintf(obj.interfaceobj,'*RST');
% setup start freq
fprintf(obj.interfaceobj,':SENS1:FREQ:STAR 5E9');
% setup stop freq
fprintf(obj.interfaceobj,':SENS1:FREQ:STOP 7E9');
% setup power
fprintf(obj.interfaceobj,':SOUR1:POW 0');
% setup bandwidth
fprintf(obj.interfaceobj,':SENS1:BAND 10E3');
% setup sweep point
fprintf(obj.interfaceobj,':SENS1:SWE:POIN 2001');
% setup measurement type: S21
fprintf(obj.interfaceobj,':CALC1:PAR1:SEL');
fprintf(obj.interfaceobj,':CALC1:PAR1:DEF S21');
% setup trig mode
fprintf(obj.interfaceobj,':TRIG:SEQ:SOUR BUS');
fprintf(obj.interfaceobj,':TRIG:AVER ON');
% setup average count
fprintf(obj.interfaceobj,':SENS1:AVER:CLE');
fprintf(obj.interfaceobj,':SENS1:AVER:COUN 10');
fprintf(obj.interfaceobj,':SENS1:AVER:STAT ON');
% start measurement
fprintf(obj.interfaceobj,':INIT:CONT ON');
fprintf(obj.interfaceobj,':TRIG:SING');
% wait until data ready
tic
while toc < obj.timeout
    status = str2double(query(obj.interfaceobj,'*OPC?'));
    if status == 1
        break;
    end
    pause(0.1);
end
% fetch data
fprintf(obj.interfaceobj,':CALC1:PAR1:SEL');
fprintf(obj.interfaceobj,':FORM:DATA ASC');

textdata = query(obj.interfaceobj, ':CALC1:DATA:SDAT?');
S = eval(['[',textdata,']']);
S = S(1:2:end) + 1i*S(2:2:end);

freq_data=query(obj.interfaceobj, ':SENS1:FREQ:DATA?');
Freq=eval(['[',freq_data,']']);

figure;
plot(Freq,abs(S))

fclose(obj.interfaceobj)

