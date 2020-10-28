% defines a universal colorscheme
% for the categories
% the returned object is a dictionary object

function colors = colorscheme(cats)


if iscategorical(cats)
	cats = categories(cats);
end

% make a colorscheme

C = colormaps.dcol(length(cats));

colors = dictionary;
for i = 1:length(cats)
    colors.(cats(i)) = C(i,:);
end

colors('normal') = color.aqua('blue');
colors('LP-weak-skipped') = color.aqua('brown');
colors('PD-weak-skipped') = color.aqua('green');
colors('sparse-irregular') = color.aqua('indigo');
colors('LP-silent-PD-bursting') = color.aqua('orange');
colors('LP-silent') = color.aqua('pink');
colors('irregular') = color.aqua('gray');
colors('slow-weak-bursting') = color.aqua('lime');

colors('silent') = color.aqua('teal');


colors('LP') = color.aqua('red');
colors('PD') = color.aqua('indigo');

%  'purple'
% 	C = [175 82 222]/255;
% case 'red'
% 	C = [255 59 48]/255;
% case 'teal'
% 	C = [90 200 250]/255;
% case 'yellow'
% 	C = [255 204 0]/255;
