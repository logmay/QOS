classdef signalCore5511a < qes.hwdriver.icinterface_compatible
    % icinterface compatible interface for signalCore 5511a mw source
    
% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties (Dependent = true) 
        numChnls
        
    end
	properties (SetAccess = private)
		freqlimits
        powerlimits
        devicehandle
    end
    properties (SetAccess = private, GetAccess = private)
		chnlName
    end
	
	properties (GetAccess = private,Constant = true)
        driver  = 'sc5511a'
        driverh = 'sc5511a.h'
    end
    methods
		function val = get.numChnls(obj)
			val = numel(obj.chnlName);
		end
		function setFrequency(obj, f, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_freq',obj.devicehandle{chnl},f);
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii}); 
		end
		function f = getFrequency(obj, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s] = calllib('sc5511a','sc5511a_get_rf_parameters',obj.devicehandle{chnl},{});
			f = s.rf1_freq;
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii}); 
		end
		function setPower(obj, p, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_level',obj.devicehandle{chnl},p); 
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii}); 
		end
		function f = getPower(obj, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s] = calllib('sc5511a','sc5511a_get_rf_parameters',obj.devicehandle{chnl},{});
			f = s.rf_level;
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii}); 
		end
		function setOnOff(obj, onoff, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			calllib('sc5511a','sc5511a_set_output',obj.devicehandle{chnl},onoff);
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{chnl}); 
		end
		function val = getOnOff(obj, chnl)
% 			obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{chnl}); 
			[~,~,s]=calllib('sc5511a','sc5511a_get_device_status',obj.devicehandle{chnl},{});
			val = s.operate_status.rf1_out_enable;
% 			calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii}); 
		end
    end
    methods (Access = private)
        function obj = signalCore5511a()
			QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('signalCore5511a_bknd');
			obj.chnlName = s.chnlName;
			if(~libisloaded(obj.driver))
                driverfilename = [obj.driver,'.dll'];
                loadlibrary(driverfilename,obj.driverh);
            end
			for ii = 1:numel(obj.chnlName)
				obj.devicehandle{ii} = calllib('sc5511a','sc5511a_open_device',obj.chnlName{ii}); 
				calllib('sc5511a','sc5511a_set_clock_reference',obj.devicehandle{ii},0,1);
% 				calllib('sc5511a','sc5511a_close_device',obj.devicehandle{ii});
			end
			
			obj.freqlimits = ...
				cell2mat(cellfun(@cell2mat,s.freq_limits(:),'UniformOutput',false));
            obj.powerlimits =...
				cell2mat(cellfun(@cell2mat,s.power_limits(:),'UniformOutput',false));
			
			obj.cmdList = {'*IDN?'};
			obj.ansList = {'SIGNALCORE,SC5511A,170410,1.0'};
            obj.fcnList = {{}};
        end
    end
    
    methods (Static = true)
        function obj = GetInstance()
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.signalCore5511a();
                objlst = obj;
            else
                obj = objlst;
            end
        end
    end
end