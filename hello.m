%% Some MATLAB code in here
clc;

fprintf('Hello world...\n');

N = 1000;

A = eye(N);

b = ones(N,1);

x = A\b;

fprintf('Norm of x = %g\n', norm(x));

%% Comparison between for loop and vectorised code (simple)
fprintf('For loop: ');
tic;
sqrd = zeros(N, 1);
for i = 1:N
    sqrd(i, 1) = i^2;
end
toc

fprintf('Vectorised: ');
tic;
sqrd2 = ((1:N).^2)';
toc

%% Calculate CV volumes
Nx = 10000;
Nz = 10000;
x = linspace(0, 100, Nx);
z = linspace(0, 10, Nz);
dx = diff(x);
dz = diff(z);
Dx = [dx(1)/2, dx(2:end), dx(end)/2];
Dz = [dz(1)/2, dz(2:end), dz(end)/2];
tic
cv_vol_mat = zeros(Nz, Nx);
for i = 1:Nz
    for j = 1:Nx
        cv_vol_mat(i, j) = Dx(j) * Dz(i);
    end
end
toc

tic
cv_vol_vec = Dz' * Dx;
toc

% figure; 
% imagesc(cv_vol_vec./max(max(cv_vol_vec)))
%% Arrayfun can be slower than for loop
fprintf('For loop: ');
tic;
some_func = @(x)(sqrt(x) + 1.5);
func_array = zeros(N, 1);
for i = 1:N
    func_array(i, 1) = some_func(i);
end
toc

fprintf('Arrayfun: ');
tic;
func_array2 = linspace(1, N, N);
func_array2 = arrayfun(some_func, func_array2(:));
toc

%% Setup parallel pool
try
    c = parcluster('local');
    % must change the Job data location to a unique directory
    % per job ... tempdir command achieves this
    c.JobStorageLocation = tempdir;
    % a batch job may not use more than 8 workers
    if (ispc())
        p = parpool(c,4);
    else
        p = parpool(c,8);
    end
catch e
    fprintf('Error setting up parallel pool!\n');
end

%% Example where sequential is faster than parallel
fprintf('Sequential for loop: ')
tic;
sqrd = zeros(N, 1);
for i = 1:N
    sqrd(i, 1) = i^2;
end
toc

fprintf('Parallel for loop: ')
tic;
sqrd = zeros(N, 1);
parfor i = 1:N
    sqrd(i, 1) = i^2;
end
toc

%% Example where parallel is faster than sequential
fprintf('Sequential for loop: ')
tic
n = 200;
A = 500;
a = zeros(n);
for i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
toc

fprintf('Parallel for loop: ')
tic
ticBytes(gcp);
n = 200;
A = 500;
a = zeros(n);
parfor i = 1:n
    a(i) = max(abs(eig(rand(A))));
end
tocBytes(gcp)
toc

%% Added new branch to test some features
vec = rand(1000, 1);

vec(vec > 0.5) = -1;

