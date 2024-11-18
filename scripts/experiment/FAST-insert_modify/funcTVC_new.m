function [predictedcritvals] = funcTVC_new(params, xs);

predictedcritvals = params{1} + (params{2}-params{1}).* (1-(30-xs)/30).^(params{3});

% t0+(t30-t0)*(1-(30-tc)/30)^alpha

%1-t0
%2-t30
%3-alpha
