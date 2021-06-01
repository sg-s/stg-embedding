% plots a matrix of states using imagesc

function stateMatrix(X)

arguments
	X categorical
end

C = display.colorscheme(X);
cats = categories(X);
CC = zeros(length(cats),3);

for i = 1:length(cats)
	CC(i,:) = C.(cats{i});
end

X = double(X);
X(isnan(X)) = length(cats)+1;
CC = [CC; 1 1 1];

imagesc(X)
colormap(CC)
