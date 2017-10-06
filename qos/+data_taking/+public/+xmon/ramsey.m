function varargout = ramsey(varargin)
% ramsey
% mode: df01,dp,dz
% df01(default): detune by detuning iq frequency(sideband frequency)
% dp: detune by changing the second pi/2 pulse tracking frame
% dz: detune by z detune pulse
% 
% <_o_> = ramsey('qubit',_c&o_,'mode',m...
%       'time',[_i_],'detuning',<_f_>,'phaseOffset',<_f_>,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.


% Yulin Wu, 2016/12/27
    
    import qes.util.processArgs
    import data_taking.public.xmon.*
    args = processArgs(varargin,{'mode', 'df01','dataTyp','P','phaseOffset',0,'fit',false...
        'gui',false,'notes','','detuning',0,'save',true});
    switch args.mode
        case 'df01'
            e = ramsey_df01('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        case 'dp'
            e = ramsey_dp('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        case 'dz'
            e = ramsey_dz('qubit',args.qubit,'dataTyp',args.dataTyp,'phaseOffset',args.phaseOffset,...
                'time',args.time,'detuning',args.detuning,...
                'notes',args.notes,'gui',args.gui,'save',args.save);
        otherwise
            throw(MException('QOS_spin_echo:illegalModeTyp',...
                sprintf('available modes are: df01, dz and dp, %s given.', args.mode)));
    end
    varargout{1} = e;
    if args.fit % Add by GM, 170623
        Ramsey_data0=e.data{1,1};
        Ramsey_time=args.time/2;
        loopn=size(Ramsey_data0,1);
        T2=NaN(1,loopn);
        T2_err=NaN(1,loopn);
        detuningf=NaN(1,loopn);
        for II=1:loopn
            Ramsey_data=Ramsey_data0(II,:);
            T1=args.T1;
            fitType=2;
            [T2(II),T2_err(II),detuningf(II),fitramsey_time,fitramsey_data]=toolbox.data_tool.fitting.ramseyFit(Ramsey_time,Ramsey_data,fitType,T1*1000);
        end
        if size(Ramsey_data0,1)==1
            hf=figure(21);
            plot(Ramsey_time,Ramsey_data,'o',fitramsey_time,fitramsey_data,'linewidth',2,'MarkerFaceColor','r');
            title(['T_2^*=' num2str(T2/1e3,'%.2f') '\pm' num2str(T2_err/1e3,'%.1f') 'us, \Deltaf=' num2str(1e3*detuningf,'%.2f') 'MHz'])
            xlabel('Pulse delay (ns)');
            ylabel('P');
        else
            hf=figure(21);
            h1=errorbar(args.detuning,T2/1e3,T2_err/1e3);
            ylim([0,Ramsey_time(end)*2/1e3])
            ylabel('T2* (us)')
            if args.mode=='dz'
                xlabel('Detune Amp')
            else
                xlabel('Detuning Freq (Hz)')
            end
            title(['Fit average T_2^* = ' num2str(mean(T2)/1e3,'%.2f') '\pm' num2str(std(T2)/1e3,'%.1f') 'us'])
            set(h1,'LineStyle','-','Marker','o','MarkerFaceColor','b')
        end
        if args.save
            QS = qes.qSettings.GetInstance();
            dataSvName = fullfile(QS.loadSSettings('data_path'),...
                [args.qubit '_T2_fit_',datestr(now,'yymmddTHHMMSS'),...
                num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
            saveas(hf,dataSvName);
        end
        varargout{2} = T2;
        varargout{3} = T2_err;
    end
end