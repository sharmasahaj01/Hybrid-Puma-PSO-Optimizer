# Hybrid PUMA–PSO Optimizer

This repository contains the implementation of a hybrid metaheuristic optimizer
based on the **PUMA Optimizer (PO)** integrated with **Particle Swarm Optimization (PSO)** 
to enhance exploitation performance and improve convergence accuracy.

## 📘 Overview
The original PUMA algorithm exhibits strong exploration but poor exploitation.
This project introduces a hybrid PUMA–PSO variant that applies PSO refinement
after each exploitation step. The approach significantly improves local search
capability and convergence stability across benchmark functions (F1–F7).

## 🧠 Features
- Implementation of original and hybrid PUMA optimizers
- Benchmark testing (F1–F7 functions)
- Statistical and convergence analysis
- Comparison with 7 algorithms: SCA, GWO, WOA, TSA, FHO, PSO, and PO
- Ready-to-run Octave/MATLAB scripts
- LaTeX-formatted research paper and results

## 🧮 Requirements
- MATLAB R2021a / GNU Octave 8.3+
- Statistics toolbox (for ranksum test)
- Figures generated automatically to `/results` folder
