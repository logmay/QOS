% circuit=['[["rz90","h","cz1","h","rz90","h","","","","","","","","","","","","cz1","h","",""],',...
% '["h","cz1","cz2","rz90","h","","","","","","","cz1","h","cz1","h","cz1","h","cz2","h","cz1",""],',...    
% '["h","cz2","cz3","rz90","","","cz1","h","cz1","h","cz1","cz2","h","cz2","h","cz2","h","","","cz2","h"],',...    
% '["h","cz3","cz4","h","rz-90","h","cz2","h","cz2","h","cz2","h","","","","","","","","",""],',...    
% '["h","cz4","rz90","","","","","","","","","","","","","","","","","",""]]'];


% %{
% >>>longstr
% [[
% "rz90","h"   ,"cz1" ,"h"   ,"rz90","h"   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ,"cz1" ,"h"   ," "   ," "   
% ],[
% "h"   ,"cz1" ,"cz2" ,"rz90","h"   ," "   ," "   ," "   ," "   ," "   ," "   ,"cz1" ,"h"   ,"cz1" ,"h"   ,"cz1" ,"h"   ,"cz2" ,"h"   ,"cz1" ," "   
% ],[
% "h"   ,"cz2" ,"cz3" ,"rz90"," "   ," "   ,"cz1" ,"h"   ,"cz1" ,"h"   ,"cz1" ,"cz2" ,"h"   ,"cz2" ,"h"   ,"cz2" ,"h"   ," "   ," "   ,"cz2" ,"h"   
% ],[
% "h"   ,"cz3" ,"cz4" ,"h"   ,"rz-90","h"   ,"cz2" ,"h"   ,"cz2" ,"h"   ,"cz2" ,"h"   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   
% ],[
% "h"   ,"cz4" ,"rz90"," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   ," "   
% ]]
% %}
% jsonstr=qes.util.stringlines('longstr',mfilename('fullpath'));
% %disp(jsonstr);
% result=sqc.simulation.qbitstatesimulate(jsonstr)





result=sqc.simulation.qbitstatesimulate({'file','E:\Data\matlab\simulte\qeccorignal.csv'})