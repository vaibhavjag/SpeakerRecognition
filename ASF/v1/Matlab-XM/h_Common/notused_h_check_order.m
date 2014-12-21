function [n_out, w, trivalwin] = h_check_order(n_in)
%CHECK_ORDER Checks the order passed to the window functions.
% [N,W,TRIVALWIN] = h_CHECK_ORDER(N_ESTIMATE) will round N_ESTIMATE to the
% nearest integer if it is not alreay an integer. In special cases (N is [],
% 0, or 1), TRIVALWIN will be set to flag that W has been modified.

%   Copyright 1988-2000 The MathWorks, Inc.
%   $Revision: 1.4 $  $Date: 2000/06/09 20:50:37 $

w = [];
trivalwin = 0;

% Special case of negative orders:
if n_in < 0,
   error('Order cannot be less than zero.');
end

% Check if order is already an integer or empty
% If not, round to nearest integer.
if isempty(n_in) | n_in == floor(n_in),
   n_out = n_in;
else
   n_out = round(n_in);
   warning('Rounding order to nearest integer.');
end

% Special cases:
if isempty(n_out) | n_out == 0,
   w = zeros(0,1);               % Empty matrix: 0-by-1
   trivalwin = 1; 
elseif n_out == 1,
   w = 1;
   trivalwin = 1;   
end
