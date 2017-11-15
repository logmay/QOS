%%
% ustcadda tester
%%
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('C:\Users\fortu\Documents\GitHub\QOS\qos\settings');
%% not needed unless you want to reconfigure the DACs and ADCs during the measurement
% a DACs and ADCs reconfiguration is only needed when the hardware settings
% has beens changed, a reconfiguration will update the changes to the
% hardware.
ustcaddaObj = ustcadda_v1.GetInstance();
%%
ustcaddaObj.close()
%% run all channels
numChnls = 44;
numRuns = 10000;
t=1:4000;
wavedata=32768+32768/2*cos(2*pi*t/40);
ustcaddaObj.runReps = 1e3;
tic
for jj = 1:numRuns
    for ii = 1:numChnls
        ustcaddaObj.SendWave(ii,wavedata);
%         ustcaddaObj.SendWave(ii,wavedata);
    end
    [datai,dataq] = ustcaddaObj.Run(false);
    t = toc;
    disp(sprintf('%0.0f, elapsed time: %0.1fs',jj,t));
    pause(0.5)
end
%% sync test, and use the mimimum oscillascope vertical range to check zero offset
ustcaddaObj.runReps = 1e4;
ustcaddaObj.SendWave(37,[32768*ones(1,200),33768*ones(1,200)]+0); % 620
ustcaddaObj.SendWave(38,[32768*ones(1,200),33768*ones(1,200)]+0); % 750
ustcaddaObj.SendWave(39,[32768*ones(1,200),33768*ones(1,200)]+0); % -230
ustcaddaObj.SendWave(40,[32768*ones(1,200),33768*ones(1,200)]+0); % -400
ustcaddaObj.Run(false);
%% Amp test
clc
t=1:4000;
wave1=[32768*ones(1,200),45000*ones(1,200)];
wave2=[32768*ones(1,200),45000*ones(1,200)];
ustcaddaObj.runReps = 1000;
ustcaddaObj.adRecordLength = 500;
ustcaddaObj.SendWave(1,wave1); % 620
ustcaddaObj.SendWave(2,wave2); % 750
[datai,dataq] = ustcaddaObj.Run(true);
% plot(mean(datai,1));hold on;plot(datai(1,:));hold off;
% figure(11);
% plot(datai,dataq,'.',mean(datai),mean(dataq),'o')
% title([num2str(mean(datai)) ' ' num2str(mean(dataq))])
figure(12);
plot(mean(datai));hold on
plot(mean(dataq));hold off
legend('3','4')
%%

for ii=1:1
    disp(ii)
t=1:2000;
wave1=32768+32768*sin(2*pi*t/40);
wave2=32768+32768*cos(2*pi*t/40);
ustcaddaObj.runReps = 1000;
ustcaddaObj.SendWave(2,wave1); % 620
ustcaddaObj.SendWave(1,wave2); % 750
ustcaddaObj.adRecordLength = 1100;
[datai,dataq] = ustcaddaObj.Run(true);
figure(11);
subplot(2,1,1)
hold on;plot(mean(datai,1))
subplot(2,1,2)
hold on;plot(mean(dataq,1))
% figure;plot(datai(1,:));hold on;plot(dataq(1,:))
% figure;plot(datai(end,:));hold on;plot(dataq(end,:))
% figure;hold on;
% for ii=1:1000
% plot(dataq(ii,:))
% end
end
%%
t=1:4000;
wave1=32768+32768/2*cos(2*pi*t/10);
wave2=32768+32768/2*sin(2*pi*t/10);
ustcaddaObj.SendContinuousWave(10,wave1)
ustcaddaObj.SendContinuousWave(9,wave2)
%% sin wave
for ii = 10
    ustcaddaObj.SendWave(ii,32768+32768*sin((1:8000)/1000*2*pi));
end
ustcaddaObj.Run(false);
%% test da -> ad
clc
wvLn = 4e3; % 2us
wvData = 32768+1000*ones(1,wvLn);
ustcaddaObj.runReps = 1000;
% ustcaddaObj.setDAChnlOutputDelay(1,100);
% ustcaddaObj.setDAChnlOutputDelay(2,100);
% ustcaddaObj.setDAChnlOutputDelay(3,100);
% ustcaddaObj.setDAChnlOutputDelay(4,100);
ustcaddaObj.SendWave(15,wvData); % 620
% ustcaddaObj.SendWave(2,wvData); % 750
% ustcaddaObj.SendWave(3,wvData); % 620
% ustcaddaObj.SendWave(4,wvData); % 750
tic
data = ustcaddaObj.Run(true);
toc
%%
ustcaddaObj.runReps = 10;
for ii = 0:200:20e3
    clc;
    disp(sprintf('waveform code: %d',ii));
    wvData = (32768+ii)*ones(1,2000);   
%     ustcaddaObj.SendWave(15,wvData);
    ustcaddaObj.SendWave(16,wvData);
%     ustcaddaObj.SendWave(21,wvData); 
    data = ustcaddaObj.Run(true);
end
%%
N = 10;
runReps = ceil(logspace(1,4,30));
wvLn = 4e3; % 2us
T = nan*ones(1,N);
for ii = 1:N
    tic
    ustcaddaObj.runReps = runReps(ii);
    ustcaddaObj.SendWave(2,65535*ones(1,wvLn));
    ustcaddaObj.SendWave(1,65535*ones(1,wvLn));
    data = ustcaddaObj.Run(true);
    T(ii) = toc;
end
figure();
semilogx(runReps,T-runReps/5e3);
xlabel('Number of samples');
ylabel('Time taken(s)');
title('Repetition 5kHz,waveform length 4000pts(da), 2000pts(ad).');
%%
wvLn = 4e3; % 2us
N = 20;
T = nan*ones(1,N);
for ii = 1:N
    tic
    ustcaddaObj.runReps = 1000;
    ustcaddaObj.SendWave(3,65535*ones(1,wvLn));
    ustcaddaObj.SendWave(4,65535*ones(1,wvLn));
    data = ustcaddaObj.Run(true);
    T(ii) = toc;
end
figure();
plot(1:N,T);
xlabel('Number of runs');
ylabel('Time taken(s)');
%%