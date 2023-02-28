import os
import sys
from plotly.subplots import make_subplots
import plotly.graph_objects as go
import numpy as np
np.set_printoptions(suppress=True)
np.set_printoptions(linewidth=200)
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
pd.options.display.float_format = '{:.3g}'.format
sns.set(font_scale = 1.0, rc={"grid.linewidth": 1,'grid.color': '#b0b0b0', 'axes.edgecolor': 'black',"lines.linewidth": 3.0}, style = 'whitegrid')

import argparse
parser = argparse.ArgumentParser(description="parameter settings")
parser.add_argument("--Delta",type=float,default=1000.)
parser.add_argument("--fraction",type=float,default=0.005)
parser.add_argument("--gamma",type=float,default=8.0)
parser.add_argument("--rho",type=float,default=1.00001)
parser.add_argument("--dataname",type=str,default="tests")
args = parser.parse_args()

Delta = args.Delta
fraction = args.fraction
gamma = args.gamma
rho = args.rho
dataname = args.dataname

symmetric_returns    = 1
state_dependent_xi   = 0
optimize_over_ell    = 0
compute_irfs         = 0                    # need to start julia with "-p 5"


if symmetric_returns == 1:
    if state_dependent_xi == 0:
        filename = "model_sym_HS.npz"
    elif state_dependent_xi == 1:
        filename = "model_sym_HSHS.npz"
    elif state_dependent_xi == 2:
        filename = "model_sym_HSHS2.npz"
elif symmetric_returns == 0:
    if state_dependent_xi == 0:
        filename = "model_asym_HS.npz"
    elif state_dependent_xi == 1:
        filename = "model_asym_HSHS.npz"
    elif state_dependent_xi == 2:
        filename = "model_asym_HSHS2.npz"

filename_ell = "./output/"+dataname+"/gamma_"+str(gamma)+"_rho_"+str(rho)+"/"
npz = np.load(filename_ell + filename)
figname = "./figure/"+dataname+"/gamma_"+str(gamma)+"_rho_"+str(rho)+"/"
os.makedirs(figname,exist_ok=True)

def trans(x):
    return np.exp(x)/(np.exp(x)+1)
def read_csv(name):
    h1 = pd.DataFrame(npz[name])
    h1.index = trans(np.linspace(-18,18,1001))
    h1.columns = np.linspace(-1,1,201)
    return h1
d1 = read_csv('d1')
d2 = read_csv('d2')
h1 = read_csv('h1')
h2 = read_csv('h2')
hz = read_csv('hz')
V = read_csv('V')

fig, ax = plt.subplots(1,1,figsize = (4,4))
sns.lineplot(data = h1[0],label = r"$-H_1$")
sns.lineplot(data = h2[0],label = r"$-H_2$")
sns.lineplot(data = hz[0],label = r"$-H_z$")
ax.set_ylim([-0.01,0.18])
ax.set_ylabel(r'$-H$')
ax.set_xlabel(r'$R$')
ax.set_title(r'$\gamma=$'+str(gamma)+', '+'$\rho$ ='+str(rho))
fig.tight_layout()
fig.savefig(figname+'/h.png', dpi = 400)
plt.close()

fig, ax = plt.subplots(1,1,figsize = (4,4))
sns.lineplot(data = d1[0],label = r"$d_1$")
sns.lineplot(data = d2[0],label = r"$d_2$")
ax.set_ylim([-0.01,0.05])
ax.set_ylabel(r'$d$')
ax.set_xlabel(r'$R$')
ax.set_title(r'$\gamma=$'+str(gamma)+', '+'$\rho$'+'='+str(rho))
fig.tight_layout()
fig.savefig(figname+'/d.png', dpi = 400)
plt.close()

fig, ax = plt.subplots(1,1,figsize = (4,4))
sns.lineplot(data = V[0],label = r"$V$")
# sns.lineplot(data = V0[0],label = r"$V0$")
# ax.set_ylim([-0.01,0.05])
ax.set_ylabel(r'$V$')
ax.set_xlabel(r'$R$')
ax.set_title(r'$\gamma=$'+str(gamma)+', '+'$\rho$'+'='+str(rho))
fig.tight_layout()

fig.savefig('doc/' + figname+'/v.png', dpi = 400)
plt.close()


res = npz
W1 = trans(np.linspace(-18,18,1001))
W2 = np.linspace(-1,1,201)
var_name = ['Investment over Capital', 'Consumption over Capital', 'Log Value Function']

plot_row_dims      = 1
plot_col_dims      = 3

plot_color_style   = ['Viridis', 'Plasma']
plot_color_style   = ['blues','reds', 'greens']

subplot_titles = []
subplot_types = []
for row in range(plot_row_dims):
    subplot_type = []
    for col in range(plot_col_dims):
        subplot_titles.append(var_name[col])
        subplot_type.append({'type': 'surface'})
    subplot_types.append(subplot_type)
spacing = 0.1
fig = make_subplots(rows=plot_row_dims, cols=plot_col_dims, horizontal_spacing=spacing, vertical_spacing=spacing, subplot_titles=(subplot_titles), specs=subplot_types)
fig.add_trace(go.Surface(z=res['d1'].T, x=W1, y=W2, colorscale=plot_color_style[0], showscale=False, name= 'd1', showlegend=True), row = 1, col = 1)
fig.add_trace(go.Surface(z=res['d2'].T, x=W1, y=W2, colorscale=plot_color_style[1], showscale=False, name= 'd2', showlegend=True), row = 1, col = 1)
fig.update_scenes(dict(xaxis_title='r', yaxis_title='z', zaxis_title='d', zaxis = dict(nticks=4, range=[0.0,0.06], tickformat= ".2f")), row = 1, col = 1)

fig.add_trace(go.Surface(z=res['cons'].T, x=W1, y=W2, colorscale=plot_color_style[2], showscale=False, name= 'c', showlegend=True), row = 1, col = 2)
fig.update_scenes(dict(xaxis_title='r', yaxis_title='z', zaxis_title='c', zaxis = dict(nticks=4, range=[0.0,0.06], tickformat= ".2f")), row = 1, col = 2)
fig.update_scenes(dict(aspectmode = 'cube'), row = 1, col = 2)

fig.add_trace(go.Surface(z=res['V'].T, x=W1, y=W2, colorscale=plot_color_style[2], showscale=False, name= 'V', showlegend=True), row = 1, col = 3)
fig.update_scenes(dict(xaxis_title='r', yaxis_title='z', zaxis_title='V', zaxis = dict(nticks=4, tickformat= ".2f")), row = 1, col = 3)
fig.update_scenes(dict(aspectmode = 'cube'), row = 1, col = 3)
fig.update_layout(title= 'Policy Function, Value Function <br><span style="font-size: 12px;"> gamma = '+ str(gamma)+', rho = '+ str(rho)+'</span>',\
              title_x = 0.5, title_y = 0.97, height=500, width=1200, title_yanchor = 'top')
fig.update_layout(margin=dict(t=75))
fig.write_json(figname+"/3d.json")
fig.write_image(figname+"/3d.png")
        