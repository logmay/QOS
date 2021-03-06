function reFitRamsey(path,fitType,T1)
if nargin<3 && nargin>0
    if fitType==2
        warning('No T1 provided. Use fit Type 1 instead.')
    end
    fitType=1;
    T1=10;
end
if nargin==0
    Data=evalin('base','Data');
    Config=evalin('base','Config');
    Ramsey_data0=Data{1,1};
    Ramsey_time=Config.args.time/2;
    fcn=Config.fcn;
    detuning=Config.args.detuning;
    dosave=false; % No path provided thus cannot save
else
    e=load(path);
    Ramsey_data0=e.Data{1,1};
    Ramsey_time=e.Config.args.time/2;
    fcn=e.Config.fcn;
    detuning=e.Config.args.detuning;
    dosave=e.Config.args.save;
end
loopn=size(Ramsey_data0,1);
T2=NaN(1,loopn);
T2_err=NaN(1,loopn);
detuningf=NaN(1,loopn);
for II=1:loopn
    Ramsey_data=Ramsey_data0(II,:);
%     Ramsey_data=Ramsey_data(1:140);
%     Ramsey_time=Ramsey_time(1:140);
    [T2(II),T2_err(II),detuningf(II),fitramsey_time,fitramsey_data]=toolbox.data_tool.fitting.ramseyFit(Ramsey_time,Ramsey_data,fitType,T1*1000);
end
if size(Ramsey_data0,1)==1
    hf=figure(17);
    plot(Ramsey_time,Ramsey_data,'o',fitramsey_time,fitramsey_data,'linewidth',2,'MarkerFaceColor','r');
    title(['T_2^*=' num2str(T2/1e3,'%.2f') '\pm' num2str(T2_err/1e3,'%.1f') 'us, \delta f=' num2str(1e3*detuningf,'%.2f') 'MHz'])
    xlabel('Pulse delay (ns)');
    ylabel('P');
else
    hf=figure(17);
    h1=errorbar(detuning,T2/1e3,T2_err/1e3);
    ylim([0,Ramsey_time(end)*2/1e3])
    ylabel('T2* (us)')
    if fcn=='data_taking.public.xmon.ramsey_dz'
        xlabel('Detune Amp')
    else
        xlabel('Detuning Freq (Hz)')
    end
    title(['Fit average T_2^* = ' num2str(mean(T2)/1e3,'%.2f') '\pm' num2str(std(T2)/1e3,'%.1f') ' us'])
    set(h1,'LineStyle','-','Marker','o','MarkerFaceColor','b')
end
if dosave
    refile=replace(path,'.mat','_fit.fig');
    saveas(hf,refile);
end
end