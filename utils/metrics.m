function [mae, rmse, acc] = metrics(true_vals, pred_vals)
% Syntax:       [mae, rmse, acc] = metrics(true_vals, pred_vals)
%
% Inputs:       true_vals is the true values of the subjects signals
%
%               pred_vals is the predicted values of the subjects signals
%
% Outputs:      mae is the resulting mean absolute error value
%
%               rmse is the resulting root means square error value
%
%               acc is the resulting accuracy value
%               
% Description:  Print the resulting metrics
%               
% Author:       Renato Avellar Nobre
%               renato.avellarnobre@studenti.unimi.it
%               
% Date:         Februrary 24, 2023
%
    n = length(true_vals);
    error = true_vals - pred_vals;
    mae = sum(abs(error))/n;
    rmse = sqrt(sum(error.^2)/n);
    acc = sum(true_vals == pred_vals,'all') / n;
end