#=============================================================================#
#  Economy with TWO CAPITAL STOCKS
#
#  Author: Balint Szoke
#  Date: Sep 2018
#=============================================================================#

using Pkg
using Optim
using Roots
using NPZ
using Distributed
using CSV
using Tables
using ArgParse

function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--gamma"
            help = "gamma"
            arg_type = Float64
            default = 8.0
        "--rho"
            help = "rho"
            arg_type = Float64
            default = 1.00001    
        "--fraction"
            help = "fraction"
            arg_type = Float64
            default = 0.01   
        "--Delta"
            help = "Delta"
            arg_type = Float64
            default = 1000.   
        "--dataname"
            help = "dataname"
            arg_type = String
            default = "output"
    end
    return parse_args(s)
end

#==============================================================================#
# SPECIFICATION:
#==============================================================================#
@show parsed_args = parse_commandline()
gamma                = parsed_args["gamma"]
rho                  = parsed_args["rho"]
fraction             = parsed_args["fraction"]
Delta                = parsed_args["Delta"]
dataname             = parsed_args["dataname"]
ell_ex = 1/(gamma-1)
symmetric_returns    = 1
state_dependent_xi   = 0
optimize_over_ell    = 0
compute_irfs         = 0                    # need to start julia with "-p 5"

if compute_irfs == 1
    @everywhere include("newsets_utils_rho.jl")
elseif compute_irfs ==0
    include("newsets_utils_rho.jl")
end

println("=============================================================")
if symmetric_returns == 1
    println(" Economy with two capital stocks: SYMMETRIC RETURNS          ")
    if state_dependent_xi == 0
        println(" No tilting (xi is NOT state dependent)                      ")
        filename = (compute_irfs==0) ? "model_sym_HS.npz" : "model_sym_HS_p.npz";
    elseif state_dependent_xi == 1
        println(" With tilting (change in kappa)                        ")
        filename = (compute_irfs==0) ? "model_sym_HSHS.npz" : "model_sym_HSHS_p.npz";
    elseif state_dependent_xi == 2
        println(" With tilting (change in beta)                        ")
        filename = (compute_irfs==0) ? "model_sym_HSHS2.npz" : "model_sym_HSHS2_p.npz";
    end
elseif symmetric_returns == 0
    println(" Economy with two capital stocks: ASYMMETRIC RETURNS         ")
    if state_dependent_xi == 0
        println(" No tilting (xi is NOT state dependent)                      ")
        filename = (compute_irfs==0) ? "model_asym_HS.npz" : "model_asym_HS_p.npz";
    elseif state_dependent_xi == 1
        println(" With tilting (change in kappa)                        ")
        filename = (compute_irfs==0) ? "model_asym_HSHS.npz" : "model_asym_HSHS_p.npz";
    elseif state_dependent_xi == 2
        println(" With tilting (change in beta)                        ")
        filename = (compute_irfs==0) ? "model_asym_HSHS2.npz" : "model_asym_HSHS2_p.npz";
    end
end

if optimize_over_ell == 0
    filename_ell = "azt_"*replace(string(round(alpha_z_tilde_ex,digits=3)),"." => "")*"_ell_ex_"*replace(string(round(ell_ex,digits=3)),"." => "");
elseif optimize_over_ell == 1
    filename_ell = "azt_"*replace(string(round(alpha_z_tilde_ex,digits=3)),"." => "")*"_ell_opt";
end

#==============================================================================#
#  PARAMETERS
#==============================================================================#
delta = .002;

# (0) Single capital economy
alpha_c_hat = .484;
beta_hat = 1.0;
sigma_c = [.477, .0];

#===========================  CALIBRATION  ====================================#
# consumption_investment = 3.1;
#A_1cap, phi_1cap, alpha_k_hat, investment_capital = calibration2(15.,
#                                             consumption_investment,
#                                             alpha_c_hat, delta, sigma_c)
# A_1cap, phi_1cap, alpha_k_hat = calibration3(investment_capital,
#                                   consumption_investment,
#                                   alpha_c_hat, delta, sigma_c)
#

A_1cap = .05
phi_1cap = 28.
investment_capital, consumption_investment, alpha_k_hat = calibration3(phi_1cap,
                                            A_1cap, delta, alpha_c_hat, sigma_c)

println("  Calibrated values: A:", A_1cap,
        "  phi_1cap: ", phi_1cap,
        "  alpha_k : ", alpha_k_hat,
        "  C/I : ", consumption_investment,
        "  I/K : ", investment_capital)
println("=============================================================")
#==============================================================================#

# (1) Baseline model
alpha_z_hat = .0;
kappa_hat = .014;
zbar = alpha_z_hat/kappa_hat;
sigma_z_1cap = [.011, .025];

sigma_z =  [.011*sqrt(.5)   , .011*sqrt(.5)   , .025];


if symmetric_returns == 1

    beta2_hat = beta1_hat = 0.5;

    # (2) Technology
    phi2 = phi1 = phi_1cap;
    A2 = A1 = A_1cap;

    if state_dependent_xi == 0
        # Constant tilting function
        scale = 1.754;
        scale = 1.32;
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat;

        # Worrisome model
        alpha_z_tilde  = alpha_z_tilde_ex#-.0075
        kappa_tilde    = kappa_hat;
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat

        ell_star = ell_ex#0.055594409575544096

    elseif state_dependent_xi == 1
        # State-dependent tilting function (fixed kappa, alpha targets q)
        scale = 1.62
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat;

        alpha_z_tilde  = alpha_z_tilde_ex#-.0075;
        kappa_tilde    =  .005
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat

        ell_star = ell_ex#0.13852940062708508

    elseif state_dependent_xi == 2
        # State-dependent tilting function
        scale = 1.568
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat;

        alpha_z_tilde  = alpha_z_tilde_ex#-.0075;
        kappa_tilde    = kappa_hat
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat + .1941
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat + .1941

        ell_star = ell_ex#0.18756641482672026

    end


elseif symmetric_returns == 0

    beta1_hat = 0.0;
    beta2_hat = 0.5;

    # (2) Technology
    phi2 = phi1 = phi_1cap;
    A2 = A1 = A_1cap;

    if state_dependent_xi == 0
        # Constant tilting function
        scale = 1.307
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat;

        # Worrisome model
        alpha_z_tilde  = alpha_z_tilde_ex#-.0075;
        kappa_tilde    = kappa_hat;
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat

        ell_star = ell_ex#0.026320287107624605

    elseif state_dependent_xi == 1
        # State-dependent tilting function (fixed kappa, alpha targets q)
        scale = 1.14
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat + .035; #.034;

        alpha_z_tilde  = alpha_z_tilde_ex#-.0075
        kappa_tilde    = .005;
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat;
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat

        ell_star = ell_ex#0.04226404306515605

    elseif state_dependent_xi == 2
        # State-dependent tilting function (fixed beta1, alpha targets q)
        scale = 1.27
        alpha_k2_hat = alpha_k1_hat = alpha_k_hat

        alpha_z_tilde  = alpha_z_tilde_ex#-.0075
        kappa_tilde    = kappa_hat
        alpha_k1_tilde = alpha_k1_hat
        beta1_tilde    = beta1_hat + .194 #.195
        alpha_k2_tilde = alpha_k2_hat
        beta2_tilde    = beta2_hat + .194 #.195

        ell_star = ell_ex#0.06678494013273199

    end

end

sigma_k1 = [.477*sqrt(scale),               .0,   .0];
sigma_k2 = [.0              , .477*sqrt(scale),   .0];


# (3) GRID
# For analysis
if compute_irfs == 1
    II, JJ = 7001, 501;     # number of r points, number of z points
    rmax = 4.;
    rmin = -rmax;
    zmax = .7;
    zmin = -zmax;
elseif compute_irfs == 0
    II, JJ = 1001, 201;
    rmax =  18.;
    rmin = -rmax       #-25.; #-rmax;
    zmax = 1.;
    zmin = -zmax;
end

# For the optimization (over ell)
II_opt, JJ_opt = 501, 201;     # number of r points, number of z points
rmax_opt = 18.;
rmin_opt = -rmax_opt;
zmax_opt = 1.2;
zmin_opt = -zmax_opt;


# (4) Iteration parameters
maxit = 500;        # maximum number of iterations in the HJB loop
crit  = 10e-6;      # criterion HJB loop
Delta = 1000.;      # delta in HJB algorithm


# Initialize model objects -----------------------------------------------------
baseline = Baseline(alpha_z_hat, kappa_hat, sigma_z_1cap,
                    alpha_c_hat, beta_hat, sigma_c, delta);
baseline1 = Baseline(alpha_z_hat, kappa_hat, sigma_z,
                        alpha_k1_hat, beta1_hat, sigma_k1, delta);
baseline2 = Baseline(alpha_z_hat, kappa_hat, sigma_z,
                        alpha_k2_hat, beta2_hat, sigma_k2, delta);
technology = Technology(A_1cap, phi_1cap);
technology1 = Technology(A1, phi1);
technology2 = Technology(A2, phi2);
model = TwoCapitalEconomy(baseline1, baseline2, technology1, technology2);

worrisome = TwoCapitalWorrisome(alpha_z_tilde, kappa_tilde,
                                alpha_k1_tilde, beta1_tilde,
                                alpha_k2_tilde, beta2_tilde);
worrisome_noR = TwoCapitalWorrisome(alpha_z_hat, kappa_hat,
                                    alpha_k1_hat, beta1_hat,
                                    alpha_k2_hat, beta2_hat);

grid = Grid_rz(rmin, rmax, II, zmin, zmax, JJ);
grid_opt = Grid_rz(rmin_opt, rmax_opt, II_opt, zmin_opt, zmax_opt, JJ_opt);
params = FinDiffMethod(maxit, crit, Delta);

xi0, xi1, xi2 = tilting_function(worrisome, model);

if symmetric_returns == 0
    if state_dependent_xi == 0
        params.Delta = 14.;
    elseif state_dependent_xi == 1
        params.Delta = 17.;
    elseif state_dependent_xi == 2
        params.Delta = 9.5
    end
end

#==============================================================================#
# WITH ROBUSTNESS
#==============================================================================#

println(" (3) Compute value function WITH ROBUSTNESS")
A, V, val, d1_F, d2_F, d1_B, d2_B, h1_F, h2_F, hz_F, h1_B, h2_B, hz_B,
        mu_1_F, mu_1_B, mu_r_F, mu_r_B, mu_z, V0, rr, zz, pii, dr, dz =
        value_function_twocapitals(ell_star, rho, fraction, model, worrisome,
                                    grid, params, symmetric_returns);
one_pii = 1 .- pii
println("=============================================================")

# Define Policies object
policies  = PolicyFunctions(d1_F, d2_F, d1_B, d2_B,
                            -h1_F/ell_star, -h2_F/ell_star, -hz_F/ell_star,
                            -h1_B/ell_star, -h2_B/ell_star, -hz_B/ell_star);

# Construct drift terms under the baseline
mu_1 = (mu_1_F + mu_1_B)/2.;
mu_r = (mu_r_F + mu_r_B)/2.;
# ... under the worst-case model
h1_dist = (policies.h1_F + policies.h1_B)/2.;
h2_dist = (policies.h2_F + policies.h2_B)/2.;
hz_dist = (policies.hz_F + policies.hz_B)/2.;

# local uncertainty prices
h1, h2, hz = -h1_dist, -h2_dist, -hz_dist;

d1 = (policies.d1_F + policies.d1_B)/2;
d2 = (policies.d2_F + policies.d2_B)/2;
cons     = one_pii .* (model.t1.A .- d1) + pii .* (model.t2.A .- d2);

# filename_ell = replace(string(round(ell_ex,digits=3)),"." => "")

# CSV.write("./output/para_" * filename_ell*"_"*"g.csv",  Tables.table(g), writeheader=false)
# CSV.write("./output/para_" * filename_ell*"_"*"d1.csv",  Tables.table(d1), writeheader=false)
# CSV.write("./output/para_" * filename_ell*"_"*"d2.csv",  Tables.table(d2), writeheader=false)
# CSV.write("./output/para_" * filename_ell*"_"*"h1.csv",  Tables.table(h1), writeheader=false)
# CSV.write("./output/para_" * filename_ell*"_"*"h2.csv",  Tables.table(h2), writeheader=false)
# CSV.write("./output/para_" * filename_ell*"_"*"hz.csv",  Tables.table(hz), writeheader=false)

results = Dict("delta" => delta,
# Single capital
"alpha_c_hat" => alpha_c_hat, "beta_hat" => beta_hat,
"alpha_z_hat" => alpha_z_hat, "kappa_hat" => kappa_hat,
"sigma_c" => sigma_c, "sigma_z_1cap" => sigma_z_1cap,
"zbar" => zbar, "cons_1cap" => cons_1cap, "stdev_z_1cap" => stdev_z_1cap,
"H0" => H0, "H1" => H1,
# Two capital stocks
"alpha_k1_hat" => alpha_k1_hat, "alpha_k2_hat" => alpha_k2_hat,
"beta1_hat" => beta1_hat, "beta2_hat" => beta2_hat,
"sigma_k1" => sigma_k1, "sigma_k2" => sigma_k2,
"sigma_z" =>  sigma_z, "A1" => A1, "A2" => A2, "phi1" => phi1, "phi2" => phi2,
"alpha_z_tilde" => alpha_z_tilde, "kappa_tilde" => kappa_tilde,
"alpha_k1_tilde" => alpha_k1_tilde, "beta1_tilde" => beta1_tilde,
"alpha_k2_tilde" => alpha_k2_tilde, "beta2_tilde" => beta2_tilde,
"xi0" => xi0, "xi1" => xi1, "xi2" => xi2,
"I" => II, "J" => JJ,
"rmax" => rmax, "rmin" => rmin, "zmax" => zmax, "zmin" => zmin,
"rr" => rr, "zz" => zz, "pii" => pii, "dr" => dr, "dz" => dz, "T" => hor,
"maxit" => maxit, "crit" => crit, "Delta" => Delta, "inner" => inner,
# Without robustness
# "V_noR" => V_noR, "val_noR" => val_noR,
# "d1_F_noR" => d1_F_noR, "d2_F_noR" => d2_F_noR,
# "d1_B_noR" => d1_B_noR, "d2_B_noR" => d2_B_noR,
# "d1_noR" => d1_noR, "d2_noR" => d2_noR,
# "g_noR_dist" => g_noR_dist, "g_noR" => g_noR,
# "mu_1_noR" => mu_1_noR, "mu_r_noR" => mu_r_noR, "mu_z_noR" => mu_z_noR,
# Robust control under baseline
"V0" => V0, "V" => V, "val" => val, "ell_star" => ell_star,
# "d1_F" => d1_F, "d2_F" => d2_F,
# "d1_B" => d1_B, "d2_B" => d2_B,
"d1" => d1, "d2" => d2,
# "h1_F" => policies.h1_F, "h2_F" => policies.h2_F, "hz_F" => policies.hz_F,
# "h1_B" => policies.h1_B, "h2_B" => policies.h2_B, "hz_B" => policies.hz_B,
# "h1_dist" => h1_dist, "h2_dist" => h2_dist, "hz_dist" => hz_dist,
"h1" => h1, "h2" => h2, "hz" => hz,
# "g_dist" => g_dist, "g" => g,
# "mu_1" => mu_1, "mu_r" => mu_r, "mu_z" => mu_z,
# Robust control under worst-case
# "g_wc_dist" => g_wc_dist, "g_wc" => g_wc,
# "mu_1_wc" => mu_1_wc, "mu_r_wc" => mu_r_wc, "mu_z_wc" => mu_z_wc,
# Non-robust control under worst-case
# "g_wc_noR_dist" => g_wc_noR_dist, "g_wc_noR" => g_wc_noR,
# # Distortion measures
# "re" => re, "q" => q,
# "chernoff" => chernoff, "halflife" => halflife,
# # Local uncertainty prices (stationary distributions)
# "h12_vec" => h12_vec, "h12_density" => h12_density,
# "hz_vec" => hz_vec, "hz_density" => hz_density,
# # Risk-free rate (stationary distributions)
# "riskfree" => riskfree,
# "rf_vec" => rf_vec, "rf_density" => rf_density,
# Consumption (stationary distributions)
# "cons_noR" => cons_noR, 
"cons" => cons,
# "cons_noR_vec" => cons_noR_vec, "cons_noR_density" => cons_noR_density,
# "cons_vec" => cons_vec, "cons_density" => cons_density,
# "cons_wc_vec" => cons_wc_vec, "cons_wc_density" => cons_wc_density,
# Consumption (drift and volatilities)
# "logC_mu_noR" => logC_mu_noR, "logC_sigma_noR" => logC_sigma_noR,
# "logC_mu" => logC_mu, "logC_sigma" => logC_sigma,
# "logC_mu_wc" => logC_mu_wc, "logC_sigma_wc" => logC_sigma_wc,
# # Impulse Response Functions
# "R_irf" => pii_irf, "Z_irf" => z_irf,
# # Expected future uncertainty prices
# "shock_price_12" => price_12, "shock_price_z" => price_z,
# Calibration
"A_1cap" => A_1cap, "phi_1cap" => phi_1cap, "alpha_k_hat" => alpha_k_hat)
# "consumption_investment" => consumption_investment, "investment_capital" => investment_capital)

npzwrite("./output/" * filename_ell*"_"*filename, results)