function [rr, hr_min, hr_max] = regexName(data_file_name)
% Syntax:       [rr, hr_min, hr_max] = regexName(data_file_name)
%
% Inputs:       data_file_name
%
% Outputs:      rr is the true respiratory rate extracted from 
%               the file name
%
%               hr_min is the true minimum heart rate extracted 
%               from the file name
%
%               hr_max is the true maximum heart rate extracted  
%               from the file name
%               
% Description:  Extract the ground true values in the file name
%               through a regex match rule.
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    matchStr = regexp(data_file_name, "([0-9]+)",'match');
    rr = str2double(matchStr(1));
    hr_min = str2double(matchStr(2));
    hr_max = str2double(matchStr(3));
end