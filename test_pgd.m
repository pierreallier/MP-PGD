% Cleaning
clear all;
close all;

% Import the library 
import mesh.*
import formulation.*
import pgd.*
import postprocessing.*

% Mesh creation
disp('Mesh construction');
x = Mesh(2,1);
nodes = x.addNodes([0 0;1 0;2 0;0 1;1 1;2 1;0 2;1 2;2 2]);
% elem = x.addElems({Triangle3(nodes([1 2 4])), Triangle3(nodes([4 2 5])), ...
%                    Triangle3(nodes([2 3 5])), Triangle3(nodes([5 3 6])), ...
%                    Triangle3(nodes([4 5 7])), Triangle3(nodes([7 5 8])), ...
%                    Triangle3(nodes([5 6 8])), Triangle3(nodes([8 6 9]))});
elem = x.addElems({Quadrangle4(nodes([1 2 5 4])), Quadrangle4(nodes([2 3 6 5])), ...
                   Quadrangle4(nodes([4 5 8 7])), Quadrangle4(nodes([5 6 9 8]))});

t = SegmentMesh(0:1/10:1);
k1 = SegmentMesh(10.^(0:4/20:4));
k2 = SegmentMesh(0.1*10.^(0:4/20:4));

% Matrix computation
disp('Formulation construction');
a = cell(3,4);
a{1,1} = BilinearForm(x, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{1,2} = BilinearForm(t, @(a,x,N1,N2) N1.exp(a)'*N2.globalDiff(a));
a{1,3} = BilinearForm(k1, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{1,4} = BilinearForm(k2, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));

a{2,1} = BilinearForm(x.extract(@(x) x(1) <= 1), @(a,x,N1,N2) N1.globalDiff(a)'*N2.globalDiff(a));
a{2,2} = BilinearForm(t, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{2,3} = BilinearForm(k1, @(a,x,N1,N2) x(1)*N1.exp(a)'*N2.exp(a));
a{2,4} = BilinearForm(k2, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));

a{3,1} = BilinearForm(x.extract(@(x) x(1) >= 1), @(a,x,N1,N2) N1.globalDiff(a)'*N2.globalDiff(a));
a{3,2} = BilinearForm(t, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{3,3} = BilinearForm(k1, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{3,4} = BilinearForm(k2, @(a,x,N1,N2) x(1)*N1.exp(a)'*N2.exp(a));

b = cell(1,4);
b{1,1} = LinearForm(x, @(a,x,N1) N1.exp(a)'*x(2));
b{1,2} = LinearForm(t, @(a,x,N1) N1.exp(a)'*x(1));
b{1,3} = LinearForm(k1, @(a,x,N1) N1.exp(a)');
b{1,4} = LinearForm(k2, @(a,x,N1) N1.exp(a)');

% Cl
u0 = cell(1,4);
u0{1} = ones(x.nbNodes(),1); u0{1}(1:3) = 0;
u0{2} = ones(t.nbNodes(),1); u0{2}(1) = 0;
u0{3} = ones(k1.nbNodes(),1);
u0{4} = ones(k2.nbNodes(),1);

% Resolution
disp('Solving PGD');
u = pgdSolver(a,b,u0,20,4);

% Postprocessing
pgdplot({x,t,k1,k2},u,'Xlabel',{'x','t','k1','k2'},'Ylabel','sol','Title','plot');

figure;
    subplot(2,2,1);
        plot(cell2mat(cellfun(@(node) node.coor,t.nodes,'UniformOutput',false)),u{2});
        xlabel('t');
        ylabel('\lambda');
    subplot(2,2,2);
        plot(cell2mat(cellfun(@(node) node.coor,k1.nodes,'UniformOutput',false)),u{3});
        xlabel('k_1');
        ylabel('\gamma');
    subplot(2,2,3);
        plot(cell2mat(cellfun(@(node) node.coor,k2.nodes,'UniformOutput',false)),u{4});
        xlabel('k_2');
        ylabel('\gamma');
