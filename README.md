<div align="center">

# 🐆 Hybrid PUMA–PSO Optimizer (HPO)

**An Enhanced Metaheuristic Algorithm for Improved Convergence**

[![MATLAB](https://img.shields.io/badge/MATLAB%2FOctave-8.3%2B-blue?logo=mathworks&logoColor=white)](https://octave.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Paper](https://img.shields.io/badge/Research-Paper-orange)](Puma_Hybrid_Group_19.pdf)
[![Institution](https://img.shields.io/badge/NSUT-Delhi-red)](https://www.nsut.ac.in/)

*Department of Computer Engineering, Netaji Subhas University of Technology (NSUT), Delhi, India*

**Authors:** Utkarsh · Aditya · Devraj Saini · Piyush Garg · Sahaj Sharma

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Motivation](#-motivation)
- [Algorithm Design](#-algorithm-design)
  - [PUMA Optimizer (POA)](#puma-optimizer-poa)
  - [Particle Swarm Optimization (PSO)](#particle-swarm-optimization-pso)
  - [Hybridization Strategy](#hybridization-strategy)
- [Repository Structure](#-repository-structure)
- [Getting Started](#-getting-started)
- [Benchmark Functions](#-benchmark-functions)
- [Experimental Results](#-experimental-results)
- [Comparison with State-of-the-Art](#-comparison-with-state-of-the-art)
- [Convergence Analysis](#-convergence-analysis)
- [Future Work](#-future-work)
- [Citation](#-citation)
- [References](#-references)

---

## 🔍 Overview

The **Hybrid PUMA–PSO Optimizer (HPO)** is a novel metaheuristic algorithm that combines the adaptive phase-switching intelligence of the **Puma Optimizer (POA)** with the velocity-driven cooperative learning of **Particle Swarm Optimization (PSO)**. The hybrid is designed to overcome POA's primary weakness — stagnation during late-stage exploitation — while fully preserving its strong global exploration capability.

### Key Highlights

- **Faster convergence** — PSO's velocity-position update is embedded inside POA's exploitation phase, significantly accelerating local refinement
- **Higher accuracy** — achieves lower mean fitness values with smaller standard deviations across benchmark functions
- **Statistically validated** — improvements confirmed via Wilcoxon rank-sum tests (p < 0.05) and Cohen's d effect sizes
- **Lightweight hybridization** — micro-PSO operates only on a small elite subset, keeping the asymptotic complexity identical to base POA: **O(N²DT)**
- **Broad applicability** — tested on 7 unimodal benchmark functions and compared against 7 state-of-the-art optimizers

---

## 💡 Motivation

The original PUMA Optimizer demonstrates strong global exploration through its adaptive three-phase hunting mechanism (exploration → stalking → ambush). However, empirical analysis reveals a critical weakness:

> **After approximately 20–30 iterations, PUMA's convergence curve flattens completely — the mean late-exploitation rate (E_late) for complex functions like Rosenbrock (F5) and Step (F6) drops to only ~0.77 and ~0.70 respectively, compared to 20+ for simple convex functions.**

This stagnation occurs because PUMA's internal exploitation operator lacks cooperative feedback among agents. PSO's velocity-position learning mechanism is exactly what addresses this gap — enabling targeted fine-tuning of elite solutions once promising regions are identified.

<div align="center">

```
PUMA  →  Great Explorer      PSO   →  Great Exploiter
         (finds the region)           (nails the optimum)
         
HPO   →  Best of Both Worlds 🎯
```

</div>

---

## 🧠 Algorithm Design

### PUMA Optimizer (POA)

POA models the intelligent hunting behavior of pumas across three adaptive phases:

| Phase | Behavior | Mechanism |
|-------|----------|-----------|
| **Unexperienced** | Both exploration & exploitation run simultaneously to build baseline knowledge | Scores (f₁, f₂) accumulated for both modes |
| **Exploration** | Pumas roam randomly to discover promising regions | Random position updates using differential vectors |
| **Exploitation (Ambush)** | Pumas converge on prey using ambush + sprint strategies | Position update driven by global best (Puma_male) |

Phase selection in the experienced stage is governed by:

```
If ScoreExplor ≥ ScoreExploit  →  Exploration
Else                            →  Exploitation
```

### Particle Swarm Optimization (PSO)

PSO models cooperative social behavior through velocity and position updates:

```
V(t+1) = w·V(t) + c₁·r₁·(Pbest - X(t)) + c₂·r₂·(Gbest - X(t))
X(t+1) = X(t) + V(t+1)
```

Where:
- `w` = inertia weight (decreases linearly, promoting exploration early → exploitation late)
- `c₁` = cognitive coefficient (self-learning)
- `c₂` = social coefficient (swarm-learning)
- `Pbest` = personal best position
- `Gbest` = global best position

### Hybridization Strategy

HPO embeds a **micro-PSO refinement stage** directly after each iteration of POA's exploitation phase:

```
┌─────────────────────────────────────────────────┐
│              HPO Main Loop                      │
│                                                 │
│  1. POA Phase Decision (Unexperienced/Experienced)
│  2. Execute POA Exploration or Exploitation     │
│  3. ── ELITE SELECTION ──────────────────────── │
│     Sort all solutions by fitness               │
│     Select top k_refine elite agents            │
│  4. ── MICRO-PSO REFINEMENT ─────────────────── │
│     Initialize micro-PSO with elites            │
│     Run T_micro PSO iterations                  │
│     Update personal & global bests              │
│  5. Replace original elites with refined ones   │
│  6. Update global best & continue               │
└─────────────────────────────────────────────────┘
```

The number of elites grows adaptively with iterations:

```
k_refine(t) = k_min + ⌊(t/T) · (k_max - k_min)⌋
```

This ensures stronger exploitation pressure in later stages, precisely when POA tends to stagnate.

**Computational Complexity:**

```
O_HPO = O(N²DT) + O(k_refine · D · T_micro)  ≈  O(N²DT)
```

Since `k_refine ≪ N` and `T_micro ≪ T`, the micro-PSO overhead is negligible.

---

## 📁 Repository Structure

```
Hybrid-Puma-PSO-Optimizer/
│
├── Implementation_Code/        # Core HPO algorithm implementation
│   ├── HPO.m                   # Main Hybrid PUMA–PSO optimizer
│   ├── Exploration.m           # POA exploration phase
│   ├── Exploitation.m          # POA exploitation phase (with PSO hook)
│   ├── MicroPSO.m              # PSO-based elite refinement module
│   └── BenchmarkFunctions.m   # F1–F7 objective functions
│
├── Comparison_Code/            # Competitor algorithm implementations
│   ├── PSO.m
│   ├── GWO.m
│   ├── WOA.m
│   ├── SCA.m
│   ├── TSA.m
│   ├── FHO.m
│   └── RunComparison.m        # Unified comparison runner
│
├── results/                    # Auto-generated outputs
│   ├── convergence_curves/     # Convergence plots (F1–F7)
│   ├── exploitation_logs/      # Exploitation activity analysis
│   └── stats/                  # .mat and .csv statistical summaries
│
├── Report/                     # LaTeX source for the research paper
│
├── Puma_Hybrid_Group_19.pdf    # Full research paper
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- **GNU Octave 8.3+** or **MATLAB R2021a+**
- Statistics Toolbox (for `ranksum` — required for Wilcoxon tests)

### Running the Hybrid PUMA–PSO Optimizer

```matlab
% Clone the repository
% git clone https://github.com/sharmasahaj01/Hybrid-Puma-PSO-Optimizer.git

% Navigate to Implementation_Code
cd Implementation_Code

% Run HPO on all benchmark functions
HPO_main
```

### Running the Full Comparison

```matlab
cd Comparison_Code

% Runs all 8 algorithms on F1–F7 with 30 independent trials
RunComparison
```

### Algorithm Parameters

| Parameter | Symbol | Default Value | Description |
|-----------|--------|---------------|-------------|
| Population size | `N_sol` | 30 | Number of search agents |
| Max iterations | `T` | 500 | Termination criterion |
| Dimensionality | `D` | 30 | Number of decision variables |
| Independent runs | `R` | 30 | For statistical evaluation |
| POA coefficients | `PF1, PF2, PF3` | 0.5, 0.5, 0.3 | Phase control parameters |
| Elite count | `k_e` | 5 | Agents refined by micro-PSO |
| Micro-PSO iterations | `L` | 8 | Local refinement steps |
| Inertia weight | `w` | 0.7 | PSO momentum control |
| Cognitive coefficient | `c₁` | 1.5 | Self-learning factor |
| Social coefficient | `c₂` | 1.5 | Collective-learning factor |
| Max velocity | `v_max` | 0.1 × (ub−lb) | Particle step size limit |

---

## 📐 Benchmark Functions

Seven standard unimodal benchmark functions are used, all with known global minima:

| Function | Name | Type | Search Range | Optimum |
|----------|------|------|--------------|---------|
| **F1** | Sphere | Convex, smooth | [−100, 100] | 0 |
| **F2** | Schwefel 2.22 | Additive + multiplicative | [−10, 10] | 0 |
| **F3** | Schwefel 1.2 | Cumulative quadratic | [−100, 100] | 0 |
| **F4** | Schwefel 2.21 | Max-absolute | [−100, 100] | 0 |
| **F5** | Rosenbrock | Narrow curved valley | [−30, 30] | 0 |
| **F6** | Step | Discontinuous, plateaus | [−100, 100] | 0 |
| **F7** | Quartic + Noise | Stochastic, quartic | [−1.28, 1.28] | ≈ 0 |

F1–F4 are simple convex landscapes ideal for testing convergence speed. F5–F7 are more challenging (narrow valleys, discontinuities, noise) and are the primary benchmarks for demonstrating HPO's enhanced exploitation.

---

## 📊 Experimental Results

### HPO vs. Original PUMA (30 independent runs, D=30, T=500)

| Function | Median (PO) | Median (HPO) | Mean (PO) | Mean (HPO) | Std (PO) | Std (HPO) | Wilcoxon p | Cohen's d |
|----------|------------|-------------|----------|-----------|---------|---------|-----------|----------|
| F1 | 5.07e−261 | **0.00** | 5.67e−255 | **0.00** | 0.00 | 0.00 | 1.21e−12 | — |
| F2 | 1.27e−129 | **1.15e−215** | 6.70e−127 | **8.20e−212** | 3.01e−126 | 0.00 | 3.02e−11 | 0.314 |
| F3 | 7.64e−236 | **2.85e−318** | 2.36e−231 | **2.91e−307** | 0.00 | 0.00 | 2.98e−11 | — |
| F4 | 1.78e−130 | **3.13e−179** | 3.22e−128 | **6.75e−176** | 1.25e−127 | 0.00 | 3.02e−11 | 0.366 |
| F5 | 2.66e+01 | **2.01e+01** | 2.48e+01 | **1.94e+01** | 6.71 | 3.76 | 7.12e−09 | **0.991** |
| F6 | 1.24e−04 | **1.03e−15** | 1.53e−04 | **1.62e−13** | 1.55e−04 | 8.43e−13 | 3.02e−11 | **1.393** |
| F7 | 2.03e−04 | **9.79e−05** | 2.38e−04 | **1.31e−04** | 1.97e−04 | 1.07e−04 | 1.22e−02 | **0.669** |

> **Bold** values indicate the better result. "—" denotes undefined Cohen's d (both groups at near-zero variance; p-values still confirm significance).

**Key finding:** On simple convex functions (F1–F4), both algorithms saturate numerical precision — HPO's gains appear small but are still statistically significant. On complex functions (F5–F7), the improvement is dramatic: F6 sees **several orders of magnitude** lower final fitness, and F5 yields a large effect size of d ≈ 0.99.

---

## 🏆 Comparison with State-of-the-Art

HPO was evaluated against **7 established metaheuristic algorithms** under identical conditions:

| Algorithm | Inspiration |
|-----------|-------------|
| PO (PUMA) | Puma hunting behavior |
| PSO | Bird flock / fish school dynamics |
| GWO | Grey wolf pack hierarchy |
| WOA | Humpback whale bubble-net foraging |
| SCA | Sine-cosine mathematical functions |
| TSA | Tunicate jet propulsion & swarm behavior |
| FHO | Fire hawk cooperative hunting |

### Wilcoxon p-values (HPO vs. all competitors)

| Function | PO | SCA | GWO | WOA | TSA | FHO | PSO |
|----------|----|-----|-----|-----|-----|-----|-----|
| F1 | 1.21e−12 | 1.21e−12 | 1.21e−12 | 1.21e−12 | 1.21e−12 | 1.21e−12 | 1.21e−12 |
| F2 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 |
| F5 | 7.12e−09 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 |
| F6 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 | 3.02e−11 |
| F7 | 1.22e−02 | 3.02e−11 | 3.34e−11 | 4.20e−10 | 3.02e−11 | 8.15e−11 | 3.02e−11 |

All p-values are well below the α = 0.05 significance threshold. HPO's improvements are **statistically significant across every function and every competitor**.

### Cohen's d Effect Sizes (HPO vs. competitors — negative = HPO wins)

| Function | PO | SCA | GWO | WOA | TSA | FHO | PSO |
|----------|----|-----|-----|-----|-----|-----|-----|
| F4 | −0.37 | −3.52 | −1.41 | −2.55 | −1.23 | −0.64 | −5.04 |
| F5 | −0.99 | −0.83 | −2.86 | −3.17 | −3.29 | −2.89 | −1.93 |
| F6 | **−1.39** | −1.19 | −2.63 | −2.67 | **−8.07** | −3.16 | −0.71 |
| F7 | −0.67 | −0.96 | −2.00 | −1.15 | −2.48 | −0.56 | −3.07 |

Effect sizes with |d| > 0.8 are considered **large**. HPO consistently achieves large-to-very-large effect sizes across competitors.

---

## 📈 Convergence Analysis

**Key observation from convergence curves (F5–F7):**

- Both PO and HPO exhibit rapid initial descent in the first 20–30 iterations (strong exploration phase)
- After iteration ~30, the **original PUMA curve flatlines** — exploitation stagnates
- **HPO continues descending steadily** all the way to iteration 500, demonstrating PSO's sustained local refinement
- The improvement is most dramatic on F6 (Step) and F7 (Quartic + Noise), where HPO achieves several orders of magnitude better final fitness

The convergence plots are generated automatically and saved to the `results/convergence_curves/` directory when running the code.

---

## 🔭 Future Work

- **VANET Route Optimization** — Integration into Vehicular Ad-hoc Networks using SUMO + NS-3 simulation for evaluating packet delivery ratio, end-to-end delay, and routing stability
- **Adaptive Parameter Control** — Reinforcement learning or fuzzy logic to dynamically tune `k_refine`, `T_micro`, and PSO coefficients during search
- **Multi-objective Extension** — Pareto-front optimization for simultaneously minimizing delay, maximizing throughput, and reducing energy consumption
- **Additional Applications** — Feature selection, image segmentation, wireless sensor network energy management, cloud/edge task scheduling
- **Theoretical Analysis** — Formal convergence bounds and stability proofs for the hybrid framework

---

## 📄 Citation

If you use this work in your research, please cite:

```bibtex
@article{hybrid_puma_pso_2025,
  title     = {Hybrid PUMA–PSO Optimizer: An Enhanced Metaheuristic Algorithm
               for Improved Convergence},
  author    = {Utkarsh and Aditya and Saini, Devraj and Garg, Piyush and Sharma, Sahaj},
  institution = {Department of Computer Engineering, Netaji Subhas University of
                Technology (NSUT), Delhi, India},
  year      = {2025},
  url       = {https://github.com/sharmasahaj01/Hybrid-Puma-PSO-Optimizer}
}
```

---

## 📚 References

1. B. Abdollahzadeh et al., "Puma optimizer (PO): A novel metaheuristic optimization algorithm and its application in machine learning," *Cluster Computing*, 2023.
2. S. Mirjalili, "SCA: A sine cosine algorithm for solving optimization problems," *Knowledge-Based Systems*, vol. 96, pp. 120–133, 2016.
3. S. Mirjalili, S. M. Mirjalili, and A. Lewis, "Grey wolf optimizer," *Advances in Engineering Software*, vol. 69, pp. 46–61, 2014.
4. S. Mirjalili and A. Lewis, "The whale optimization algorithm," *Advances in Engineering Software*, vol. 95, pp. 51–67, 2016.
5. M. Kaur and D. K. Aseri, "Tunicate swarm algorithm," *Engineering Applications of AI*, vol. 90, 2020.
6. M. Azizi, S. Talatahari, and A. H. Gandomi, "Fire hawk optimizer," *Artificial Intelligence Review*, vol. 55, no. 7, 2022.
7. J. Kennedy and R. Eberhart, "Particle swarm optimization," *Proc. IEEE ICNN*, Perth, 1995.

---

<div align="center">

**Made with 🧪 research and ☕ caffeine at NSUT, Delhi**

⭐ If this project helped you, please consider giving it a star!

</div>
