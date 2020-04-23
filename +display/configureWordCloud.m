function configureWordCloud(w,colors)

assert(isa(w,'matlab.graphics.chart.WordCloudChart'),'First argument should be a wordcloud')
assert(isa(colors,'dictionary'),'2nd arg should be a dict')
w.SizePower = 1;

N = length(w.WordData);
w.Color = zeros(N,3);

% color them correctly
for i = N:-1:1
    this_color = colors(char(w.WordData(i)));
    if ~isempty(this_color)
        w.Color(i,:) = this_color;
    end
end
w.Box = 'on';