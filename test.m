clearvars, clc, close all
x = linspace(0, 2*pi, 100);
y = linspace(0, 2*pi, 100);
[X, Y] = meshgrid(x, y);
Z = sin(X).*sin(Y);
Z = Z.^2;
surf(X, Y, Z)
