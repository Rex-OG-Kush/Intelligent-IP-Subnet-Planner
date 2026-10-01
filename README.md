# Intelligent IP Subnet Planner 📊🛡️

An algorithmic infrastructure planning engine written in R that automates Variable Length Subnet Masking (VLSM) calculations to optimize enterprise IPv4 address allocations and eliminate subnet waste.

## 📋 Project Overview
In large-scale networking, manually carving out subnets for departments with fluctuating host demands leads to human error and massive IP address waste. This software application takes an engineering approach to infrastructure planning. It accepts a list of company departments and their host requirements, automatically sorts them by structural scale according to standard VLSM architectural practices, and outputs a complete, boundary-perfect IP addressing blueprint.

## 🛠️ Technical Capabilities Demonstrated
*   **Algorithmic Networking Logic:** Implementing ceiling log base-2 loops to dynamically solve host bit requirements per subnet block.
*   **Variable Length Subnet Masking (VLSM):** Programmatically mapping network addresses, usable host boundaries, broadcast vectors, and CIDR masks.
*   **Resource Efficiency Analytics:** Calculating IP utilization efficiency percentages to ensure maximum optimization of address limits.

## ⚙️ How the Architecture Operates
1.  **Sorting Phase:** The engine processes operational inputs and automatically sorts departments from largest host requirement to smallest (crucial for valid VLSM boundaries).
2.  **Bit-Allocation Calculation:** Resolves the exact binary exponent constraint required to safely encapsulate `Hosts Needed + 2` (Gateway & Broadcast overhead).
3.  **Boundary Stacking:** Dynamically updates and increments network boundaries to stack subnets sequentially, leaving zero dead space between departmental blocks.

## 💼 Intended Business Impact
By shifting from manual calculations to an automated subnet layout planning engine, network architects can instantly scale enterprise branch topologies, reduce addressing design times by over 90%, and strictly enforce zero-waste network layout baselines.
