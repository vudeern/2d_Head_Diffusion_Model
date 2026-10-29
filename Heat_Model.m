%   % Udeern Varanasi BME 313L, Lab 10
%   Function Name: evolveHeat.m
%
%   Author: Udeern Varanasi
%   Course: BME 313L, Lab 10
%   This script evolves the temperature distribution on a 2D unit square
%   using an explicit finite-difference scheme. A uniform grid with spacing
%   dx is used, and the boundary values are determined from input vector
%   BCvals = [L, R, B, T]. These boundary values remain fixed for all time
%   steps, while only interior grid nodes are updated by applying the
%   discrete Laplacian. A surface plot is generated every 10 iterations to
%   visualize the diffusion process.
%   For numerical stability in 2D, the ratio q = dt/dx^2 must satisfy
%   q <= 1/4. This ensures that round-off and truncation errors do not grow
%   exponentially over time, i.e., the amplification factor must remain
%   below unity. In 1D, the condition relaxes to q <= 1/2.

function Udeern_Varanasi_heatEvolve(BCvals)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all;

% Spatial step size
dx = 0.05;

% Build grid
xgrid = 0:dx:1; 
ygrid = xgrid; 
N = length(xgrid);

% Initialize temperature matrix
Temp = zeros(N, N);

% Apply boundary conditions
Temp(:, 1)   = BCvals(1);
Temp(:, end) = BCvals(2);
Temp(1,   :) = BCvals(3);
Temp(end, :) = BCvals(4);

% Time step determined by stability
dtstep = (dx^2) / 4;

% Time discretization
timeVec = 0:dtstep:0.25; 
timeCount = length(timeVec);

% Time evolution loop
for k = 1:timeCount

    % New temperature matrix for updated solution
    TempNext = Temp;

    % Update only interior nodes
    for ii = 2:N-1
        for jj = 2:N-1
            TempNext(ii, jj) = Temp(ii, jj) + dtstep * ...
                (Temp(ii+1, jj) + Temp(ii-1, jj) + Temp(ii, jj+1) + Temp(ii, jj-1) ...
                - 4*Temp(ii, jj)) / dx^2;
        end
    end

    % Replace old solution
    Temp = TempNext;

    % Plot every 10 iterations
    if mod(k, 10) == 0
        surf(xgrid(2:N-1), ygrid(2:N-1), Temp(2:N-1, 2:N-1));
        axis([0 1 0 1 0 1]);
        pause(0.1);
    end
end

% Final plot
surf(xgrid(2:N-1), ygrid(2:N-1), Temp(2:N-1, 2:N-1));
axis([0 1 0 1 0 1]);
title(sprintf(': Time = %.6f', timeVec(k)));

end