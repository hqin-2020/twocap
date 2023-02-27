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
parser.add_argument("--symmetric_returns",type=int,default=0)
parser.add_argument("--state_dependent_xi",type=int,default=0)
parser.add_argument("--optimize_over_ell",type=int,default=0)
parser.add_argument("--ell_ex",type=float,default=0.05)
parser.add_argument("--alpha_z_tilde_ex",type=float,default=0.05)
args = parser.parse_args()

symmetric_returns = args.symmetric_returns
state_dependent_xi = args.state_dependent_xi
optimize_over_ell = args.optimize_over_ell
ell_ex = args.ell_ex
alpha_z_tilde_ex = args.alpha_z_tilde_ex

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

if optimize_over_ell == 0:
    filename_ell = "azt_"+str(alpha_z_tilde_ex).replace(".","")[:5]+"_ell_ex_"+str(ell_ex).replace(".","")[:3]+"3_"
elif optimize_over_ell == 1:
    filename_ell = "azt_"+str(alpha_z_tilde_ex).replace(".","")[:5]+"_ell_opt_"

npz = np.load("output/" + filename_ell + filename)
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
if optimize_over_ell == 0:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell$'+'='+str(npz['ell_star'])[:8])
elif optimize_over_ell == 1:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell^\star$'+'='+str(npz['ell_star'])[:8])
fig.tight_layout()

if optimize_over_ell == 0:
    figname = "azt_"+str(alpha_z_tilde_ex)+"_ell_"+str(ell_ex)+"_H1H2Hz/h.png"
elif optimize_over_ell == 1:
    figname =  "azt_"+str(alpha_z_tilde_ex)+"_ell_opt_H1H2Hz/h.png"

fig.savefig('doc/' + figname, dpi = 400)
plt.close()

fig, ax = plt.subplots(1,1,figsize = (4,4))
sns.lineplot(data = d1[0],label = r"$d_1$")
sns.lineplot(data = d2[0],label = r"$d_2$")
ax.set_ylim([-0.01,0.05])
ax.set_ylabel(r'$d$')
ax.set_xlabel(r'$R$')
if optimize_over_ell == 0:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell$'+'='+str(npz['ell_star'])[:8])
elif optimize_over_ell == 1:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell^\star$'+'='+str(npz['ell_star'])[:8])
fig.tight_layout()

if optimize_over_ell == 0:
    figname = "azt_"+str(alpha_z_tilde_ex)+"_ell_"+str(ell_ex)+"_H1H2Hz/d.png"
elif optimize_over_ell == 1:
    figname =  "azt_"+str(alpha_z_tilde_ex)+"_ell_opt_H1H2Hz/d.png"

fig.savefig('doc/' + figname, dpi = 400)
plt.close()

fig, ax = plt.subplots(1,1,figsize = (4,4))
sns.lineplot(data = V[0],label = r"$V$")
# sns.lineplot(data = V0[0],label = r"$V0$")
# ax.set_ylim([-0.01,0.05])
ax.set_ylabel(r'$V$')
ax.set_xlabel(r'$R$')
if optimize_over_ell == 0:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell$'+'='+str(npz['ell_star'])[:8])
elif optimize_over_ell == 1:
    ax.set_title(r'$\tilde{\alpha}_z=$'+str(alpha_z_tilde_ex)[:8]+', '+'$\ell^\star$'+'='+str(npz['ell_star'])[:8])
fig.tight_layout()

if optimize_over_ell == 0:
    figname = "azt_"+str(alpha_z_tilde_ex)+"_ell_"+str(ell_ex)+"_H1H2Hz/v.png"
elif optimize_over_ell == 1:
    figname =  "azt_"+str(alpha_z_tilde_ex)+"_ell_opt_H1H2Hz/v.png"

fig.savefig('doc/' + figname, dpi = 400)
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

fig.update_layout(margin=dict(t=75))
if optimize_over_ell == 0:
    figname = "azt_"+str(alpha_z_tilde_ex)+"_ell_"+str(ell_ex)+"_H1H2Hz/v.png"
elif optimize_over_ell == 1:
    figname =  "azt_"+str(alpha_z_tilde_ex)+"_ell_opt_H1H2Hz/v.png"
fig.write_json('doc/' + figname+"/3d.json")
fig.write_image('doc/' + figname+"/3d.png")
        