clc, clearvars, close all

%z = x^2 + y^2 + y;

X = [0 0; 0 0; 0 0; 1 1; -1 1; 1 -1; -1 -1; sqrt(2) 0; 0 sqrt(2); 0 -sqrt(2); -sqrt(2) 0];
Z = [0.02; 0.03; -0.01; 3.1; 3.08; 1.07; 0.97; 1.97; 2.09 + sqrt(2); 2.06 - sqrt(2); 1.95];

[Bl, Rl] = linearInterpolate2(X, Z);
[Bq, Rq] = quadraticInterpolate2(X, Z);

zl = @(x, y) Bl(1) + Bl(2)*x + Bl(3)*y;
zq = @(x, y) Bq(1) + Bq(2)*x + Bq(3)*y + Bq(4)*(x.*y) + Bq(5)*(x.^2) + Bq(6)*(y.^2);

x = linspace(-2, 2, 100);
y = x;
[Xm, Ym] = meshgrid(x, y);
Zl = zl(Xm, Ym);
Zq = zq(Xm, Ym);

subplot(1, 2, 1)
surf(Xm, Ym, Zl), title('Linear'), xlabel('x'), ylabel('y'), zlabel('z')
grid on
colormap hsv

subplot(1, 2, 2)
surf(Xm, Ym, Zq), title('Quadratic'), xlabel('x'), ylabel('y'), zlabel('z')
grid on
colormap hsv
