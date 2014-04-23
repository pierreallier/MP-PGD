import mesh.*
import formulation.*
import pgd.*
import postprocessing.*

% Mesh creation
x = Mesh(2,1);
nodes = x.addNodes([0 0;2 0;0 2;2 2]);
elem = x.addElems({Triangle3(nodes(1:3)), Triangle3(nodes([3 2 4]))});

t = SegmentMesh(0:1/10:1);
k = SegmentMesh(10.^(0:4/20:4));

% Matrix computation
a = cell(2,3);
a{1,1} = BilinearForm(x, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{1,2} = BilinearForm(t, @(a,x,N1,N2) N1.exp(a)'*N2.globalDiff(a));
a{1,3} = BilinearForm(k, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));

a{2,1} = BilinearForm(x, @(a,x,N1,N2) N1.globalDiff(a)'*N2.globalDiff(a));
a{2,2} = BilinearForm(t, @(a,x,N1,N2) N1.exp(a)'*N2.exp(a));
a{2,3} = BilinearForm(k, @(a,x,N1,N2) x(1)*N1.exp(a)'*N2.exp(a));

b = cell(1,3);
b{1,1} = LinearForm(x, @(a,x,N1) N1.exp(a)'*x(1)*x(2));
b{1,2} = LinearForm(t, @(a,x,N1) N1.exp(a)'*x(1));
b{1,3} = LinearForm(k, @(a,x,N1) N1.exp(a)');

% Cl
u0{1} = ones(x.nbNodes(),1); u0{1}(1:2) = 0;
u0{2} = ones(t.nbNodes(),1); u0{2}(1) = 0;
u0{3} = ones(k.nbNodes(),1);

% Resolution
u = pgdSolver(a,b,u0,10,4);

% Postprocessing
pgdplot({x,t,k},u,'Xlabel',{'x','t','k'},'Ylabel','sol','Title','plot');

figure;
    subplot(2,1,1);
        plot(cell2mat(cellfun(@(node) node.coor,t.nodes,'UniformOutput',false)),u{2});
        xlabel('t');
        ylabel('\lambda');
    subplot(2,1,2);
        plot(cell2mat(cellfun(@(node) node.coor,k.nodes,'UniformOutput',false)),u{3});
        xlabel('k');
        ylabel('\gamma');
