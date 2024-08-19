function [outputArg1, outputArg2] = quadraticInterpolate1(A,Y)
%Interpolate data points with 1 independent variable and 1 response variable for a quadratic model
%   Takes 2 matrices as arguments:
%   A : N x 1 matrix containing, at each row, values for the independent variable in the
%       data points
%   Y : N x 1 matrix containing, at each row, a value for the response
%       variable
%   Returns [B, R2] where B is an array containig the parameters for the model:
%   y(x) = B(1) + B(2)*x + B(3)*x^2
%   and R2 the determination coefficient of the model

X = ones(length(A),1);
Ax = A(:,1);  % column matrix containing all values for x 
Ax2 = Ax.^2;  % column matrix containing all values for x^2
X = [X Ax Ax2];

B = (inv(X' * X))*(X')*Y;

y = @(x)B(1) + B(2)*x + B(3)*(x.^2);

ym = sum(Y)/length(Y);
Ymodel = y(A);
R2 = (sum((Ymodel - ym).^2))/(sum((Y - ym).^2));

outputArg1 = B;
outputArg2 = R2;
end