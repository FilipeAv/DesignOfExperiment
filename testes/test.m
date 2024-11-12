clc, clearvars, close all

model = @(X1, X2, X3)900 - 8*X1 + X2 - 7*X3 + 2*X1.^2  + X2.^2 + X3.^2 + X1.*X2 - X1.^3 + X2.^3 + X3.^3 + 0.5*(X1.^2).*X2 - 3*X1.*(X3.^2) - 10*X1.*X2.*X3;

X1 = linspace(-1, 1, 200);
X2 = linspace(-1, 1, 200);
X3 = linspace(-1, 1, 200);

[X1_grid, X2_grid, X3_grid] = ndgrid(X1, X2, X3);

Y = model(X1_grid, X2_grid, X3_grid);

[aux, optP] = min(min(min(Y)));

            
data = [ -1 -1 -1 model(-1, -1, -1);
         -1 -1 1 model(-1, -1, 1);
         1 -1 -1 model(1, -1, -1);
         1 -1 1 model(1, -1, 1);
         1 1 -1 model(1, 1, -1);
         1 1 1 model(1, 1, 1);
         -1 1 -1 model(-1, 1, -1);
         -1 1 1 model(-1, 1, 1);
         0 0 -1 model(0, 0, -1);
         0 0 1 model(0, 0, 1);
         1 0 0 model(1, 0, 0);
         -1 0 0 model(-1, 0, 0);
         0 1 0 model(0, 1, 0);
         0 -1 0 model(0, -1, 0);
         0.5 0.5 0.5 model(0.5, 0.5, 0.5);
         0.5 -0.5 0.5 model(0.5, -0.5, 0.5);
         0.5 0.5 -0.5 model(0.5, 0.5, -0.5);
         -0.5 0.5 0.5 model(-0.5, 0.5, 0.5);
         0.5 0.3 0.2 model(0.5, 0.3, 0.2);
         0.5 0 0.1 model(0.5, 0, 0.1);
         -0.5 0.4 -0.5 model(-0.5, 0.4, -0.5);
         0 0 0 model(0, 0, 0);
        ];
 

data(:,4) = normrnd(data(:,4), 0.1);