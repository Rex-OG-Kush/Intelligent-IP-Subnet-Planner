# ==============================================================================
# PROJECT: AUTOMATED VLSM NETWORK SUBNET PLANNER
# AUTHOR: MATUTUZELA JABULANI NDLOVU
# PURPOSE: Automatically calculates optimized subnet structures minimizing IP waste
# ==============================================================================

# Function to calculate the required host bits for a given number of usable hosts
calculate_host_bits <- function(required_hosts) {
  # Add 2 for network and broadcast addresses
  total_needed <- required_hosts + 2
  bits <- ceiling(log2(total_needed))
  return(bits)
}

# Core Subnetting Simulation Engine
plan_network_subnets <- function(base_ip, departments, host_requirements) {
  cat("=== ENTERPRISE IP ADDRESS ALLOCATION PLAN ===\n")
  cat("Base Network Space:", base_ip, "/24\n\n")
  
  # Sort requirements in descending order (Standard VLSM Rule)
  order_idx <- order(host_requirements, decreasing = TRUE)
  sorted_deps <- departments[order_idx]
  sorted_hosts <- host_requirements[order_idx]
  
  current_third_octet <- 0
  
  # Loop through sorted departments to compute addressing schemas
  for (i in 1:length(sorted_deps)) {
    hosts_needed <- sorted_hosts[i]
    host_bits <- calculate_host_bits(hosts_needed)
    subnet_size <- 2^host_bits
    cidr_mask <- 32 - host_bits
    
    # Calculate boundaries
    network_addr <- paste0("192.168.1.", current_third_octet)
    first_usable <- paste0("192.168.1.", current_third_octet + 1)
    last_usable  <- paste0("192.168.1.", current_third_octet + subnet_size - 2)
    broadcast    <- paste0("192.168.1.", current_third_octet + subnet_size - 1)
    
    # Calculate IP efficiency metric
    allocated_ips <- subnet_size
    efficiency <- round(((hosts_needed + 2) / allocated_ips) * 100, 1)
    
    # Output the structural breakdown for the admin team
    cat(paste0("📍 Department: ", sorted_deps[i], "\n"))
    cat(paste0("   - Required Hosts: ", hosts_needed, " | Allocated: ", allocated_ips, "\n"))
    cat(paste0("   - Subnet Mask:    /", cidr_mask, "\n"))
    cat(paste0("   - Network Range:  ", network_addr, " to ", broadcast, "\n"))
    cat(paste0("   - Usable Range:   ", first_usable, " to ", last_usable, "\n"))
    cat(paste0("   - IP Efficiency:  ", efficiency, "%\n\n"))
    
    # Shift to the next available block boundary
    current_third_octet <- current_third_octet + subnet_size
  }
}

# Execute the planner with mock corporate structure parameters
departments <- c("Sales Team", "Core Server Infrastructure", "Guest Wi-Fi", "Finance HQ")
host_requirements <- c(24, 58, 12, 6) # Varied structural needs

plan_network_subnets("192.168.1.0", departments, host_requirements)
