#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd
from tqdm import tqdm
import numpy as np

from bokeh.palettes import Viridis256
from bokeh.layouts import layout
from bokeh.models import ColumnDataSource, CustomJS, Div, HoverTool, Scatter, ColorMapper, ColorBar
from bokeh.plotting import figure, output_notebook, show, output_file
from bokeh.models.tickers import FixedTicker

output_notebook()
output_file("index.html")


# In[2]:


# define some important params
downsample = 13
max_n_spikes = 400
max_T_PD = 2 # seconds, above this is clipper


# In[3]:


# read data 

# the reason to use pandas instead of directly reading into a numpy array
# is because numpy's genfromtext is abysmally slow
df_LP = pd.read_csv("/Users/srinivas/Desktop/stg/LP.csv",header=None)
df_PD = pd.read_csv("/Users/srinivas/Desktop/stg/PD.csv",header=None)
nrows = len(df_LP.index)

T_PD = pd.read_csv("/Users/srinivas/Desktop/stg/T_PD.csv",header=None)
T_PD = np.array(T_PD[0])


R = pd.read_csv("/Users/srinivas/Desktop/stg/R.csv",header=None)
Rx = np.array(R[0])
Ry = np.array(R[1])


# In[4]:


# to save space in the final figure, we will only
# plot data points that have < 200 spikes

keep = np.array((df_LP.count(axis=1) < max_n_spikes) & (df_PD.count(axis=1) < max_n_spikes))

# throw away data points with lots of spikes
df_LP = df_LP.iloc[keep,0:max_n_spikes]
df_PD = df_PD.iloc[keep,0:max_n_spikes]
T_PD = T_PD[keep]
Rx = Rx[keep]
Ry = Ry[keep]


# In[5]:


Rx = Rx[::downsample]
Ry = Ry[::downsample]
T_PD = T_PD[::downsample]

# convert into list of arrays 
PD = []
LP = []

nrows = len(df_LP.index)
for i in tqdm(np.arange(nrows)[::downsample]):
    this_LP = df_LP.iloc[i,:]
    #this_LP = this_LP[~np.isnan(this_LP)]
    
    this_PD = df_PD.iloc[i,:]
    #this_PD = this_PD[~np.isnan(this_PD)]
    
    offset = np.nanmin([np.nanmin(this_PD),np.nanmin(this_LP)])
    this_LP = this_LP - offset
    this_PD = this_PD - offset
    PD.append(this_PD)
    LP.append(this_LP)


# In[6]:


PD_y = np.zeros_like(PD[0])
LP_y = np.zeros_like(PD[0]) + 1


# In[7]:


# make colors
n = len(Rx)
pallete = Viridis256

c_PD = np.copy(T_PD)

# clip PD burst periods > max 
c_PD[c_PD>max_T_PD] = max_T_PD
c_PD -= np.nanmin(c_PD)
c_PD /= np.nanmax(c_PD)
c_PD[np.isnan(c_PD)] = -2

idx = np.ceil(255 * c_PD).astype(
    int
)
colors = np.repeat("#969696", n)
for i in np.arange(n):
    if idx[i] < 0:
        continue
    colors[i] = pallete[idx[i]]

colors = tuple(colors)


# In[30]:


scatter_size=7
plot_size=700

raster_data = ColumnDataSource(data=dict(
        PD = PD[0],
        PD_y = PD_y,
        LP = LP[0],
        LP_y = LP_y,
    ))



marker_data = ColumnDataSource(data=dict(
        x = [Rx[0]],
        y = [Ry[0]],
    ))


tsne_plot = figure(
        sizing_mode="stretch_width",
        height=plot_size,
        width=plot_size,
        tools=[],
        toolbar_location=None,
        x_axis_label="t-SNE 1",
        y_axis_label="t-SNE 2",
    )

tsne_plot.circle(
        Rx,
        Ry,
        size=scatter_size,
        color=colors,
        alpha=0.5,
        hover_alpha=1,
    )
tsne_plot.circle(
    "x",
    "y",
    size=scatter_size * 2,
    fill_color=None,
    color="red",
    source=marker_data,
    line_width=3,
)

color_mapper = ColorMapper(palette="Viridis256",
                          )
color_bar = ColorBar(color_mapper=color_mapper, 
                     label_standoff=12,
                    location=(0,0),

                    )


# make another scatter plot showing the rasters 
raster_plot = figure(
        sizing_mode="stretch_width",
        height=100,
        max_width=plot_size,
        tools=[],
        toolbar_location=None,
        x_axis_label="Time (s)",
        y_axis_label="Neuron",
        y_range=(-.5,1.5),
        x_range=(0,20),
    )

raster_plot.yaxis.major_label_overrides = {
        0: "PD",
        1: "LP"
    }

raster_plot.yaxis.ticker = FixedTicker(ticks=[0,1])

LP_glyph = Scatter(x="LP", 
                y="LP_y", 
                size=20,
                marker="dash",
                line_color="red",
                angle=1.57)

PD_glyph = Scatter(x="PD", 
                y="PD_y", 
                size=20,
                marker="dash",
                line_color="blue",
                angle=1.57)


raster_plot.add_glyph(raster_data,PD_glyph)
raster_plot.add_glyph(raster_data,LP_glyph)

# add a hover tool that sets the link data for a hovered circle
code = """
    if (cb_data.index.indices.length > 0) {
        if (cb_data.index.indices[0] > 0) { 
        // dirty hack to ignore the zero index of the marker
            const idx = (cb_data.index.indices[0]);
            
            raster_data.data.PD = PD[idx];
            raster_data.data.LP = LP[idx];
            //console.log(idx);
            raster_data.change.emit();
            
            marker_data.data.x[0] = Rx[idx];
            marker_data.data.y[0] = Ry[idx];
            marker_data.change.emit();
            }
    };

"""

callback = CustomJS(args=dict(
                        raster_data=raster_data,
                        marker_data=marker_data,
                        PD=PD,
                        LP=LP,
                        Rx=Rx,
                        Ry=Ry,
                        ), 
                    code=code)

tsne_plot.add_tools(HoverTool(tooltips=[], callback=callback))
#tsne_plot.add_layout(color_bar, 'right')

div = Div(
        text=f"""
        <h1 style="color: #4d4d4d;;">
        Pyloric circuit dynamics explorer  🦀</h1> 
        
        <p style="color: #4d4d4d;;">
        Scatter plot shows embedding of pyloric circuit 
        dynamics. Color indicates time period of PD oscillations. 
        Hover over each point to see the spike pattern from LP and PD
        neurons for that point. </p>
        """,
        width=500,
        height=130,
        margin=(0, 10, 0, 40),
    )


footer = Div(
        text="""
        
        <div style="color:#8d8e8f;">
        
        <h3>Details</h3> 
        
        
        <p>
        This visualization was created to accompany 
        <a href = "https://www.biorxiv.org/content/10.1101/2021.07.06.451370v1">
        Gorur-Shandilya <i>et al</i>.</a> and full details about the method
        are contained there. Briefly, the scatter plot shows 
        a two-dimensional visualization of a large dataset collected
        from the pyloric circuit in the crab. Two identified neurons,
        the LP and PD neurons are recorded from and their spikes
        are measured. </p>
        
        <p>
        The top panel shows a raster plot of spikes from these two neurons. 
        The rasters shown in this panel correspond to the point currently
        highlighted in the scatter plot with a red circle. Hover over 
        different points in the scatter plot to look at spike patterns
        for that data point.</p>
        
        <p>
        The colors of the scatter plot correspond to the burst period of
        the PD neuron. When the burst period is not defined, because 
        the PD neuron has no well defined bursts, dots are colored gray.
        </p>
        
        <h4>Differences from visualization in the paper</h4>
        
        <p>
        The following modifications have been made to create this interactive 
        visualization:
        </p>
        
         <ol>
          <li>Only data segments with <400 spikes are shown, to reduce file size.</li>
          <li>Only 1 in 13 data points have been shown, to reduce file size.</li>
          <li>The colors corresponding to PD neurons with periods above 2s 
              have been clipped to 2s.</li>
        </ol> 
        
        
        <h4>Code</h4>
        
        <p>The code to generate this visualization, together with all code
        for this project, is available 
        <a href = "https://github.com/sg-s/stg-embedding/">here</a>.</p>
        
        </div>
        
        """,
        width=500,
        margin=(0, 10, 0, 40),
    )


show(
    layout(
        [
            [div],
            [raster_plot],
            [tsne_plot],
            [footer],
            
        ]
    )
)


# In[ ]:




