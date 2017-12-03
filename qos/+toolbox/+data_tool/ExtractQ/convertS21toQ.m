clear all
path='E:\Data\matlab\test\resonatorQ\resonatorQ\q1';
files=dir(path);
for ii=3:numel(files)
    data0=load([files(ii).folder '\' files(ii).name]);
    Power(ii-2)=data0.SweepVals{1,1}{1,1};
    tt=data0.Data{1,1}{1,1};
    S21(ii-2,:)=tt(1,:);
    Freq=tt(2,:);
end

calibrate21=toolbox.data_tool.fitting.QFit1.calibrate(Freq,S21);

for ipower=1:length(Power)
    [ c(ipower,:),dc(ipower,:) ]=toolbox.data_tool.fitting.QFit1.qfit1(Freq,calibrate21(ipower,:),false);
end
h=toolbox.data_tool.fitting.QFit1.showfittingresult(path,Power,Freq,calibrate21,c,dc);